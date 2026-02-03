from fastapi import FastAPI, HTTPException
from supabase import create_client, Client
from pydantic import BaseModel

app = FastAPI()

# Supabase መረጃዎች
URL = "https://your-project.supabase.co"
KEY = "your-anon-key"
supabase: Client = create_client(URL, KEY)

# ለሲቪ ዳታ የሚሆን ሞዴል
class CvData(BaseModel):
    uid: str
    name: str
    email: str
    summary: str = None
    experience: list = []
    education: list = []
    skills: list = []

@app.post("/sync-cv")
async def sync_cv(cv: CvData):
    try:
        # 1. መረጃውን ወደ Supabase 'user_cvs' ሰንጠረዥ ማስገባት
        # .upsert() ማለት መረጃው ካለ ማደስ (Update)፣ ከሌለ መፍጠር (Insert) ማለት ነው
        response = supabase.table("user_cvs").upsert({
            "user_id": cv.uid,
            "full_name": cv.name,
            "email": cv.email,
            "cv_content": cv.dict(), # ሙሉውን ዳታ በ JSON መልክ ያስቀምጣል
            "updated_at": "now()"
        }).execute()

        return {"status": "success", "message": "CV Synced to Supabase via Python"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))