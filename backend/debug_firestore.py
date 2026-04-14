import os
import firebase_admin
from firebase_admin import credentials, firestore
from dotenv import load_dotenv

load_dotenv()
project_id = os.environ.get("GOOGLE_CLOUD_PROJECT")

if not firebase_admin._apps:
    firebase_admin.initialize_app()

db = firestore.client()
uid = "8GfbybxRHrXXVM3YrkyYZU0YPmA3"
doc_id = "51GowgoKNRzLC7GgkTi8"

doc = db.collection('documents').document(uid).collection('docs').document(doc_id).get()

if doc.exists:
    data = doc.to_dict()
    print("--- RAW OCR TEXT ---")
    print(data.get('raw_ocr_text'))
    print("\n--- EXTRACTED DATA ---")
    print(data.get('extracted_data'))
else:
    print("Document not found!")
