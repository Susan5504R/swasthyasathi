from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import firebase_admin
from firebase_admin import credentials, firestore

app = FastAPI()

# Initialize Firebase (Using Application Default Credentials or standard init)
try:
    firebase_admin.initialize_app()
except ValueError:
    # App already initialized
    pass

class ProcessRequest(BaseModel):
    uid: str
    docId: str
    storagePath: str

@app.get("/health")
def health():
    return {"status": "ok", "service": "swasthyasathi-api"}

@app.post("/process")
async def process_document(req: ProcessRequest):
    """
    Called by the Firebase Cloud Function when a new document is uploaded.
    Updates the Firestore document status to 'processing'.
    (In Phase 3, this endpoint will continue to trigger the AI OCR & Extraction.)
    """
    try:
        db = firestore.client()
        # Structure in Flutter is: documents/{uid}/docs/{docId} OR users/{uid}/documents/{docId}
        # In flutter code `scan_screen.dart` lines 147 it says: generateDocId(uid) -> `documents` collection
        # Let's write to `documents/{uid}/docs/{docId}` as per `processing_screen.dart` line 132
        
        doc_ref = db.collection('documents').document(req.uid).collection('docs').document(req.docId)
        
        # Update the processing status
        doc_ref.set({
            "processing_status": "processing",
        }, merge=True)
        
        return {"status": "success", "message": "Document status updated to 'processing'", "docId": req.docId}
    
    except Exception as e:
        print(f"Error updating document status: {e}")
        raise HTTPException(status_code=500, detail=str(e))
