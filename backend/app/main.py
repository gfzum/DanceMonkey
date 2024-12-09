from typing import Optional
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

app = FastAPI()

class VideoBase(BaseModel):
    title: str
    description: Optional[str] = None

@app.get("/")
def read_root():
    return {"status": "healthy", "service": "dance-monkey-api"}

@app.get("/health")
def health_check():
    return {"status": "ok"} 