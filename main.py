# FastAPI wrapper

from fastapi import FastAPI
from pydantic import BaseModel
import requests

app = FastAPI()

class PromptRequest(BaseModel):
    prompt: str
    model: str = "mistral:instruct"

@app.post("/generate")
def generate(req: PromptRequest):
    response = requests.post(
        "http://localhost:11434/api/generate",
        json={
            "model": req.model,
            "prompt": req.prompt,
            "stream": False
        }
    )
    return response.json()
