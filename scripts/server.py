# backend/server.py
import re
import json
import os
from typing import List, Optional
from fastapi import FastAPI, HTTPException, Response
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

from sentence_transformers import SentenceTransformer
from qdrant_client import QdrantClient
from groq import Groq

# ==== Ayarlar ====
QDRANT_HOST = "localhost"
QDRANT_PORT = 6333
INSTR_COLLECTION = "n61_instructions"
ORDER_COLLECTION = "order_returns"
EMBED_MODEL = "sentence-transformers/LaBSE"
LLM_MODEL = "meta-llama/llama-4-scout-17b-16e-instruct"
GROQ_API_KEY = "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"          # .env içine alman önerilir

# ==== Session Store ====
session_store = {}  # key: session_id, value: List[ChatMessage]
SESSION_FILE = "session_data.json"

# ==== Init ====
model  = SentenceTransformer(EMBED_MODEL)
qdrant = QdrantClient(host=QDRANT_HOST, port=QDRANT_PORT)
groq   = Groq(api_key=GROQ_API_KEY)

app = FastAPI(title="N61-AI Chat API")

# CORS middleware - mobil cihazlar için
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],             # prod'da domain bazlı sınırla
    allow_methods=["*"],
    allow_headers=["*"],
)

# ---------- Session Management ----------
def load_sessions():
    """Session verilerini dosyadan yükle"""
    global session_store
    try:
        if os.path.exists(SESSION_FILE):
            with open(SESSION_FILE, "r", encoding="utf-8") as f:
                session_store = json.load(f)
            print(f"✅ {len(session_store)} session yüklendi")
    except Exception as e:
        print(f"⚠️ Session yükleme hatası: {e}")
        session_store = {}

def save_sessions():
    """Session verilerini dosyaya kaydet"""
    try:
        with open(SESSION_FILE, "w", encoding="utf-8") as f:
            json.dump(session_store, f, ensure_ascii=False, indent=2)
    except Exception as e:
        print(f"⚠️ Session kaydetme hatası: {e}")

def get_session_history(session_id: str) -> List[dict]:
    """Session geçmişini al"""
    return session_store.get(session_id, [])

def add_to_session(session_id: str, role: str, content: str):
    """Session'a mesaj ekle"""
    if session_id not in session_store:
        session_store[session_id] = []
    
    session_store[session_id].append({
        "role": role,
        "content": content
    })
    
    # Maksimum 50 mesaj tut (performans için)
    if len(session_store[session_id]) > 50:
        session_store[session_id] = session_store[session_id][-50:]
    
    save_sessions()

# ---------- Yardımcılar ----------
def get_order_return_code(query: str):
    try:
        match = re.search(r"\b(\d{3,})\b", query)
        if not match:
            return None
        vec  = model.encode([match.group(1)])[0]
        hits = qdrant.search(ORDER_COLLECTION, query_vector=vec, limit=1, timeout=5)
        if not hits:
            return None
        return hits[0].payload["iade_kodu"]
    except Exception as e:
        print(f"Qdrant iade kodu arama hatası: {e}")
        return None

def get_similar_answer(query: str):
    try:
        vec  = model.encode([query])[0]
        hits = qdrant.search(INSTR_COLLECTION, query_vector=vec, limit=3, timeout=5)
        if not hits:
            return "Üzgünüm, bu soruya uygun bir cevap bulamadım."
        return hits[0].payload["answer"]
    except Exception as e:
        print(f"Qdrant arama hatası: {e}")
        # Fallback cevap
        return "N61 mağazamızla ilgili sorularınızı yanıtlamaya çalışıyorum. Lütfen daha spesifik bir soru sorun."

def llm_with_context(question: str, context: str, history: List[dict] = None):
    try:
        # Konuşma geçmişini hazırla
        messages = []
        
        # Sistem mesajı
        system_prompt = f"""N61 mağazası müşteri hizmetleri asistanısın. 
        
Görevin:
- Müşteri sorularını samimi ve yardımsever bir şekilde yanıtlamak
- Verilen bağlam bilgilerini kullanarak doğru cevaplar vermek
- Konuşma geçmişini dikkate alarak tutarlı cevaplar vermek

Bağlam bilgileri:
{context}

Lütfen kısa, net ve yardımcı cevaplar ver."""

        messages.append({"role": "system", "content": system_prompt})
        
        # Konuşma geçmişini ekle (son 10 mesaj)
        if history:
            recent_history = history[-10:]  # Son 10 mesajı al
            for msg in recent_history:
                if msg.get("role") in ["user", "assistant"]:
                    messages.append({
                        "role": msg["role"], 
                        "content": msg["content"]
                    })
        
        # Mevcut soruyu ekle
        messages.append({"role": "user", "content": question})
        
        completion = groq.chat.completions.create(
            model=LLM_MODEL,
            messages=messages,
            temperature=0.7,
            max_tokens=512,
            top_p=1,
            stream=False,
        )
        return completion.choices[0].message.content
    except Exception as e:
        print(f"Groq LLM hatası: {e}")
        # Fallback cevap
        return f"Sorunuz: '{question}' hakkında şu bilgileri buldum: {context}"

# ---------- API Şemaları ----------
class ChatMessage(BaseModel):
    role: str  # "user" veya "assistant"
    content: str

class ChatRequest(BaseModel):
    message: str
    session_id: Optional[str] = None
    history: Optional[List[ChatMessage]] = None

class ChatResponse(BaseModel):
    answer: str
    source: str   # "return_code" | "kb+llm"
    session_id: str

# ---------- Endpoint'ler ----------
@app.get("/health")
def health():
    return JSONResponse(
        content={"status": "ok"},
        headers={"Content-Type": "application/json; charset=utf-8"}
    )

@app.post("/chat")
def chat(req: ChatRequest):
    question = req.message.strip()
    if not question:
        raise HTTPException(status_code=400, detail="Mesaj boş olamaz.")

    # Session ID al veya oluştur
    session_id = req.session_id or f"default-{hash(question) % 10000}"
    
    # Session geçmişini al
    session_history = get_session_history(session_id)
    
    # Client'dan gelen history varsa birleştir
    if req.history:
        client_history = [{"role": msg.role, "content": msg.content} for msg in req.history]
        # Duplicate kontrolü yaparak birleştir
        combined_history = session_history.copy()
        for msg in client_history:
            if msg not in combined_history:
                combined_history.append(msg)
        session_history = combined_history

    # Kullanıcı mesajını session'a ekle
    add_to_session(session_id, "user", question)

    # 1) iade kodu mı?
    if "iade" in question.lower() and "kodu" in question.lower():
        code = get_order_return_code(question)
        if code:
            answer = f"Siparişin iade kodu: {code}"
            add_to_session(session_id, "assistant", answer)
            return JSONResponse(
                content={
                    "answer": answer,
                    "source": "return_code", 
                    "session_id": session_id
                },
                headers={"Content-Type": "application/json; charset=utf-8"}
            )

    # 2) KB + LLM with history
    sim_ans = get_similar_answer(question)
    answer = llm_with_context(question, f"- {sim_ans}", session_history)
    
    # Bot cevabını session'a ekle
    add_to_session(session_id, "assistant", answer)
    
    return JSONResponse(
        content={
            "answer": answer,
            "source": "kb+llm",
            "session_id": session_id
        },
        headers={"Content-Type": "application/json; charset=utf-8"}
    )

if __name__ == "__main__":
    import uvicorn
    print("🚀 FastAPI Chat Server başlatılıyor...")
    print("📱 Flutter'dan gelen istekler kabul ediliyor...")
    print("🧠 Session-aware chat desteği aktif...")
    
    # Session verilerini yükle
    load_sessions()
    
    uvicorn.run(app, host="0.0.0.0", port=8000, reload=True)
