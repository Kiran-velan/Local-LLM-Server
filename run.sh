#!/bin/bash

echo "🟢 Starting Ollama server..."
ollama serve > ollama.log 2>&1 &
OLLAMA_PID=$!
sleep 2

# Check if ollama actually started
if ! ps -p $OLLAMA_PID > /dev/null; then
    echo "❌ Failed to start Ollama (PID $OLLAMA_PID)"
    cat ollama.log
    exit 1
fi

# Auto-cleanup on Ctrl+C
trap "echo '🛑 Stopping Ollama...'; kill $OLLAMA_PID 2>/dev/null || true" EXIT

# Start FastAPI
echo "🟢 Starting FastAPI on http://localhost:8888 ..."
uvicorn main:app --host 0.0.0.0 --port 8888
