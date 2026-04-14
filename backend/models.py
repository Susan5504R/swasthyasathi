from pydantic import BaseModel, Field
from typing import Optional, List

class Medicine(BaseModel):
    name: str = Field(description="Name of the medicine")
    dose: Optional[str] = Field(None, description="Dosage amount, e.g., '500mg', '1 tablet'")
    frequency: Optional[str] = Field(None, description="How often to take it, e.g., 'Twice a day', 'BD'")
    duration: Optional[str] = Field(None, description="How long to take it, e.g., '5 days'")
    with_food: Optional[bool] = Field(None, description="True if to be taken with food, False if on empty stomach")
    timing: List[str] = Field(default_factory=list, description="List of timings: 'morning', 'afternoon', 'night'")
    special_instructions: Optional[str] = Field(None, description="Any other specific instructions")

class CarePlan(BaseModel):
    hospital_name: Optional[str] = Field(None, description="Name of the hospital")
    document_date: Optional[str] = Field(None, description="Date on the document in YYYY-MM-DD format if possible")
    diagnosis: List[str] = Field(default_factory=list, description="List of diagnoses or conditions")
    medicines: List[Medicine] = Field(default_factory=list, description="List of prescribed medicines")
    follow_up_date: Optional[str] = Field(None, description="Next appointment date")
    follow_up_location: Optional[str] = Field(None, description="Location or doctor for follow up")
    danger_signs: List[str] = Field(default_factory=list, description="Symptoms that require immediate medical attention")
    diet_restrictions: List[str] = Field(default_factory=list, description="Foods to avoid or eat")
    tests_needed: List[str] = Field(default_factory=list, description="Pending or required lab tests")
    activity_restrictions: List[str] = Field(default_factory=list, description="Physical activity instructions")
