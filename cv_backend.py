import os
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional, Dict, Any
from supabase import create_client, Client
import httpx

app = FastAPI()

# 1. CORS Middleware - የ Flutter ዌብሳይትህ ከ Render ጋር እንዲነጋገር ይፈቅዳል
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # በምርት ላይ (Production) የ Netlify ሊንክህን እዚህ ብታስገባ ይሻላል
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Environment Variables (ከ Render Dashboard የሚነበቡ)
SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")
GROQ_API_KEY = os.getenv("GROQ_API_KEY")

# Supabase Client Initialization
supabase: Client = None
if SUPABASE_URL and SUPABASE_KEY:
    supabase = create_client(SUPABASE_URL, SUPABASE_KEY)

# ከ Flutter CvModel ጋር የተቀናጀ Pydantic Model
class CvBackendModel(BaseModel):
    uid: str
    firstName: str = ""
    lastName: str = ""
    jobTitle: str = ""
    portfolio: str = ""
    email: str = ""
    phone: str = ""
    phone2: str = ""
    address: str = ""
    age: str = ""
    gender: str = ""
    nationality: str = ""
    linkedin: str = ""
    profileImagePath: str = ""
    summary: str = ""
    education: List[Dict[str, Any]] = []
    experience: List[Dict[str, Any]] = []
    skills: List[Dict[str, Any]] = []
    languages: List[Dict[str, Any]] = []
    certificates: List[Dict[str, Any]] = []
    user_references: List[Dict[str, Any]] = []
    lastUpdated: Optional[str] = None

@app.get("/")
def read_root():
    return {"status": "online", "service": "CV Builder Pro API with CORS enabled"}

# 1. መረጃን ወደ Supabase የመላኪያ Endpoint
@app.post("/api/sync-cv")
async def sync_cv(cv_data: CvBackendModel):
    if not supabase:
        raise HTTPException(status_code=500, detail="Supabase not configured")
    try:
        data_to_save = cv_data.dict()
        # 'cv_data' Table ላይ Upsert ያደርጋል (ካለ ያድሳል፣ ከሌለ ይጨምራል)
        response = supabase.table("cv_data").upsert(data_to_save).execute()
        return {"status": "success", "data": response.data}
    except Exception as e:
        print(f"Sync Error: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

# 2. AI Summary የማመንጫ Endpoint
@app.post("/api/generate-summary")
async def generate_summary(payload: Dict[str, Any]):
    if not GROQ_API_KEY:
        raise HTTPException(status_code=500, detail="Groq API key missing")
    
    context = payload.get("context", "")
    is_amharic = payload.get("isAmharic", False)
    
    system_prompt = (
        "You are an elite CV ghostwriter. Write ONE cohesive professional summary paragraph "
        "(5-7 lines) based on the user data. Use first-person 'I'. "
        "Do not include labels like 'Summary:' or 'Note:'."
    )
    user_prompt = f"Data: {context}. Write the summary in {'Amharic' if is_amharic else 'English'}."

    async with httpx.AsyncClient() as client:
        try:
            response = await client.post(
                "https://api.groq.com/openai/v1/chat/completions",
                headers={"Authorization": f"Bearer {GROQ_API_KEY}"},
                json={
                    "model": "llama-3.3-70b-versatile",
                    "messages": [
                        {"role": "system", "content": system_prompt},
                        {"role": "user", "content": user_prompt}
                    ],
                    "temperature": 0.7
                },
                timeout=30.0
            )
            result = response.json()
            if "choices" not in result:
                raise HTTPException(status_code=500, detail="AI Response Error")
            
            summary_text = result['choices'][0]['message']['content']
            return {"summary": summary_text}
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"AI Error: {str(e)}")