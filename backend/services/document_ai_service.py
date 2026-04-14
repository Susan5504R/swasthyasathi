import os
from google.cloud import documentai

def process_document(image_bytes: bytes, mime_type: str) -> tuple[str, float]:
    """
    Sends the document image to Google Cloud Document AI for text extraction.
    Returns a tuple of (extracted_text, average_confidence_score).
    """
    project_id = os.environ.get("GOOGLE_CLOUD_PROJECT")
    processor_id = os.environ.get("DOCUMENT_AI_PROCESSOR_ID")
    location = "us" # Hardcoded to 'us' as per Phase 1 instructions

    if not project_id or not processor_id:
        raise ValueError("Missing GOOGLE_CLOUD_PROJECT or DOCUMENT_AI_PROCESSOR_ID environment variables.")

    client = documentai.DocumentProcessorServiceClient()
    processor_name = client.processor_path(project_id, location, processor_id)

    raw_document = documentai.RawDocument(content=image_bytes, mime_type=mime_type)
    request = documentai.ProcessRequest(name=processor_name, raw_document=raw_document)

    # Process the document
    result = client.process_document(request=request)
    document = result.document

    full_text = document.text
    
    # Calculate average confidence
    confidences = []
    for page in document.pages:
        for token in page.tokens:
            if token.layout and token.layout.confidence:
                confidences.append(token.layout.confidence)
                
    avg_confidence = sum(confidences) / len(confidences) if confidences else 1.0

    return full_text, avg_confidence
