import os
import firebase_admin
from firebase_admin import credentials, firestore, storage as fb_storage
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from dotenv import load_dotenv

from services.document_ai_service import process_document

# Initialize Firebase Admin SDK
load_dotenv()
project_id = os.environ.get("GOOGLE_CLOUD_PROJECT")

if not firebase_admin._apps:
    # Most Firebase projects use {project-id}.firebasestorage.app 
    # or {project-id}.appspot.com
    firebase_admin.initialize_app(options={
        'storageBucket': f"{project_id}.firebasestorage.app"
    })

app = FastAPI()

class ProcessRequest(BaseModel):
    uid: str
    docId: str
    storagePath: str

@app.get("/health")
def health():
    return {"status": "ok", "service": "swasthyasathi-api"}

@app.post("/process")
async def process_new_document(req: ProcessRequest):
    db = firestore.client()
    doc_ref = db.collection('documents').document(req.uid).collection('docs').document(req.docId)
    
    # 1. Update status to 'processing'
    doc_ref.update({"processing_status": "processing"})
    
    try:
        # 2. Download image from Firebase Storage
        # Default bucket name typically looks like: {project-id}.firebasestorage.app
        # We need to find the default bucket name if not explicitly provided, but using bucket() 
        # without args tries to resolve default bucket. If not set, we might need to set it in initialize_app.
        # Ensure your Firebase bucket is set. E.g. 'swasthyasathi-123.appspot.com'
        bucket = fb_storage.bucket()
        blob = bucket.blob(req.storagePath)
        
        if not blob.exists():
            error_reason = "file_not_found"
            doc_ref.update({"processing_status": "failed", "error_reason": error_reason})
            return {"status": "failed", "reason": error_reason}
            
        print(f"Downloading {req.storagePath}...")
        image_bytes = blob.download_as_bytes()
        mime_type = blob.content_type or "image/jpeg"
        
        # 3. Process via Document AI
        print(f"Sending to Document AI...")
        raw_text, avg_confidence = process_document(image_bytes, mime_type)
        print(f"OCR Complete. Average confidence: {avg_confidence:.2f}")
        
        # 4. Check confidence threshold
        CONFIDENCE_THRESHOLD = float(os.environ.get("OCR_CONFIDENCE_THRESHOLD", "0.70"))
        
        if avg_confidence < CONFIDENCE_THRESHOLD:
            doc_ref.update({
                "processing_status": "failed",
                "error_reason": "low_confidence",
                "avg_confidence": avg_confidence
            })
            return {"status": "failed", "reason": "low_confidence", "confidence": avg_confidence}
            
        # 5. Move to extracting stage
        doc_ref.update({
            "processing_status": "extracting",
            "ocr_confidence": avg_confidence,
            "raw_ocr_text": raw_text 
        })
        
        # 6. Extract Medical Entities using Gemini
        print(f"Sending to Gemini for extraction...")
        from services.gemini_service import extract_medical_entities, translate_to_hindi
        from models import CarePlan
        
        extracted_dict = extract_medical_entities(raw_text)
        
        # Validate through Pydantic
        care_plan = CarePlan(**extracted_dict)
        
        # 7. Hindi Translation
        print(f"Translating to Hindi...")
        doc_ref.update({"processing_status": "translating"})
        
        hindi_care_plan_dict = translate_to_hindi(care_plan.model_dump())
        
        # 8. Save final Care Plan and update status to DONE
        print(f"Saving final Care Plan and marking as DONE...")
        
        # Save to the care_plans collection as per implementation plan
        db.collection('care_plans').document(req.uid).collection('plans').document(req.docId).set({
            **hindi_care_plan_dict,
            "created_at": firestore.SERVER_TIMESTAMP,
            "uid": req.uid,
            "doc_id": req.docId,
            "original_doc_id": req.docId
        })
        
        doc_ref.update({
            "processing_status": "done",
            "care_plan_id": req.docId
        })
        
        return {
            "status": "success", 
            "message": "Processing complete", 
            "care_plan": hindi_care_plan_dict
        }
        
    except Exception as e:
        print(f"Pipeline error: {e}")
        doc_ref.update({
            "processing_status": "failed",
            "error_reason": str(e)
        })
        raise HTTPException(status_code=500, detail=str(e))

