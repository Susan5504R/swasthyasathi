import os
import firebase_admin
import sys
from firebase_admin import credentials, firestore
from dotenv import load_dotenv

# Ensure the output is UTF-8 to handle medical symbols and Hindi
sys.stdout.reconfigure(encoding='utf-8')

load_dotenv()
project_id = os.environ.get("GOOGLE_CLOUD_PROJECT")

if not firebase_admin._apps:
    firebase_admin.initialize_app()

db = firestore.client()
uid = "8GfbybxRHrXXVM3YrkyYZU0YPmA3"
doc_id = "iopbjRzvhMwHbwyG2lT7"

doc = db.collection('documents').document(uid).collection('docs').document(doc_id).get()

if doc.exists:
    data = doc.to_dict()
    print("--- RAW OCR TEXT ---")
    raw_text = data.get('raw_ocr_text', '')
    print(raw_text)
    print("\n--- EXTRACTED DATA (RAW) ---")
    print(data.get('extracted_data', {}))
else:
    print("Document not found!")
