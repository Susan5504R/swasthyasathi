import os
import json
from google import genai
from google.genai import types

# Initialize the GenAI client
# It will automatically use the GEMINI_API_KEY environment variable if available
# or we can pass it explicitly.
client = genai.Client(api_key=os.environ.get("GEMINI_API_KEY"))

EXTRACTION_PROMPT = """
SYSTEM:
You are a medical data extractor for Indian hospital documents.
Extract information from the OCR text below and return ONLY a JSON object.
Do not add explanations, markdown formatting, or code blocks.
If a field is not found in the text, use null for strings or [] for arrays.

Return EXACTLY this JSON structure. Provide output strictly as a raw JSON string.
{
  "hospital_name": "string or null",
  "document_date": "YYYY-MM-DD or null",
  "diagnosis": ["diagnosis1"],
  "medicines": [{
    "name": "string",
    "dose": "string",
    "frequency": "string",
    "duration": "string",
    "with_food": true,
    "timing": ["morning", "afternoon", "night"],
    "special_instructions": "string or null"
  }],
  "follow_up_date": "YYYY-MM-DD or null",
  "follow_up_location": "string or null",
  "danger_signs": ["string"],
  "diet_restrictions": ["string"],
  "tests_needed": ["string"],
  "activity_restrictions": ["string"]
}

OCR TEXT FROM HOSPITAL DOCUMENT:
{raw_ocr_text}
"""

def extract_medical_entities(raw_text: str) -> dict:
    """
    Takes raw OCR text, sends it to Gemini 2.0 Flash using the new GenAI SDK,
    and returns parsed JSON data.
    """
    if not raw_text or len(raw_text.strip()) == 0:
        raise ValueError("Raw text is empty")
        
    prompt = EXTRACTION_PROMPT.replace("{raw_ocr_text}", raw_text)
    
    # Use gemini-2.5-flash as the newest available model for this API key
    response = client.models.generate_content(
        model='gemini-2.5-flash',
        contents=prompt,
        config=types.GenerateContentConfig(
            temperature=0.1,
            response_mime_type='application/json',
        )
    )
    
    # The new SDK handles JSON parsing reliably if response_mime_type is set,
    # but we can also use response.parsed if we use a Pydantic model with the SDK.
    return json.loads(response.text)

HINDI_PROMPT = """
SYSTEM:
You are a health educator helping families in India.
Convert the medical JSON below into simple Hindi explanations.

RULES:
- Use Class 5 reading level. Short sentences. No medical jargon.
- Use "Hinglish" where appropriate (e.g., use 'medicine' or 'doctor' if it's more common than the complex Hindi words).
- For each medicine: explain kab lena hai (timing), kitna lena hai (dose), khane se pehle ya baad (with_food).
- For danger signs: always prefix with "Yeh dikhne par TURANT doctor ke paas jaayein:"
- For diagnosis: explain what the condition means in simple terms.
- Keep the EXACT same JSON structure — just replace all string values with Hindi text.
- Do not add any fields. Do not remove any fields.
- Return ONLY the JSON object. No markdown, no explanation.

EXTRACTED MEDICAL JSON:
{extracted_json}
"""

def translate_to_hindi(extracted_json: dict) -> dict:
    """
    Passes the extracted JSON through Gemini again to rewrite all text fields in simple Hindi.
    """
    if not extracted_json:
        return extracted_json
        
    prompt = HINDI_PROMPT.replace("{extracted_json}", json.dumps(extracted_json, ensure_ascii=False))
    
    response = client.models.generate_content(
        model='gemini-2.5-flash',
        contents=prompt,
        config=types.GenerateContentConfig(
            temperature=0.1,
            response_mime_type='application/json',
        )
    )
    return json.loads(response.text)
