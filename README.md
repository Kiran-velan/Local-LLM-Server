# Local LLM Server

🚀 Local LLM Server with Ollama

**Why choose Ollama?**

- Simple installation and maintenance
- Automatic GPU support via CUDA (when available)
- JSON API accessible from any project
- Compatible with popular models (mistral, llama2, gemma, etc.)

### Quick Setup Guide

**Step 1: Installation**

```bash
# Install Ollama
curl -fsSL https://ollama.com/install.sh | sh
ollama --version

# Start the server
ollama serve &
```

**Step 2: Get a model**

```bash
# Pull Mistral Instruct (4.1GB)
ollama pull mistral:instruct

# Other options
ollama pull llama2
ollama pull gemma
```

**Step 3: Test it**

```bash
# Try it directly
ollama run mistral:instruct
```

### API Usage

Send requests to **http://localhost:11434/api/generate**

```json
// POST request body
{
  "model": "mistral:instruct",
  "prompt": "Explain black holes",
  "stream": false
}

// Response
{
  "response": "Black holes are regions of spacetime..."
}
```
---
### Optional: FastAPI Wrapper

**1. Project structure**

```
Local-LLM-Server/
├── README.md
├── requirements.txt
├── main.py        # FastAPI wrapper
└── run.sh         # Startup script
```

**2. Create main.py**

```python
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
```

**3. Set up requirements.txt**

```
fastapi
uvicorn
requests
```

**4. Create Python environment**

```bash
cd ~/projects/Local-LLM-Server
python3 -m venv venv
source venv/bin/activate

pip install -r requirements.txt
```

**5. Create run.sh**

```bash
#!/bin/bash

echo "🟢 Starting Ollama server..."
ollama serve > ollama.log 2>&1 &
OLLAMA_PID=$!
sleep 2

# Check if ollama started
if ! ps -p $OLLAMA_PID > /dev/null; then
    echo "❌ Failed to start Ollama (PID $OLLAMA_PID)"
    cat ollama.log
    exit 1
fi

# Auto-cleanup on Ctrl+C
trap "echo '🛑 Stopping Ollama...'; kill $OLLAMA_PID 2>/dev/null || true" EXIT

# Start FastAPI
echo "🟢 Starting FastAPI on http://localhost:8888/ ..."
uvicorn main:app --host 0.0.0.0 --port 8888
```

**6. Run your server**

```bash
./run.sh
```

**7. Test the API via Postman**

```json
// POST to http://localhost:8888/generate
{
  "prompt": "What is gravity?",
  "model": "mistral:instruct"
}
```

![Screenshot 2025-07-08 000259](https://github.com/user-attachments/assets/c4de3798-cf2d-4743-83aa-76af66be18a8)


### Managing Ollama Service

If you need to disable auto-starting:

```bash
# Check service status
sudo systemctl status ollama

# Disable auto-start
sudo systemctl stop ollama
sudo systemctl disable ollama

# Verify it's stopped
sudo systemctl status ollama
ps aux | grep ollama

# Command to stop manually
sudo pkill -f "ollama"
# or
sudo kill <PID>
```
