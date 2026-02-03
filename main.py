from fastapi import FastAPI
from pydantic import BaseModel
from typing import Optional
from fastapi.middleware.cors import CORSMiddleware # ይህን ጨምር

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
class CvData(BaseModel):
    firstName: str
    lastName: str
    jobTitle: str
    email: str
    phone: str
    summary: Optional[str] = ""

@app.post("/api/sync-cv")
async def sync_cv(data: CvData):
    print(f"✅ ዳታ ደርሷል! ስም: {data.firstName} {data.lastName}")
    return {"status": "success", "received_name": data.firstName}