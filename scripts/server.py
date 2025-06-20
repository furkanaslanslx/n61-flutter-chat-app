# backend/server.py
import re
from fastapi import FastAPI, HTTPException
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

def llm_with_context(question: str, context: str):
    try:
        prompt = f"Soru: {question}\n\nBağlam:\n{context}\n\nNet bir cevap ver:"
        completion = groq.chat.completions.create(
            model=LLM_MODEL,
            messages=[{"role": "user", "content": prompt}],
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
class ChatRequest(BaseModel):
    message: str

class ChatResponse(BaseModel):
    answer: str
    source: str   # "return_code" | "kb+llm"

# ---------- Endpoint'ler ----------
@app.get("/health")
def health():
    return {"status": "ok"}

@app.post("/chat", response_model=ChatResponse)
def chat(req: ChatRequest):
    question = req.message.strip()
    if not question:
        raise HTTPException(status_code=400, detail="Mesaj boş olamaz.")

    # 1) iade kodu mı?
    if "iade" in question.lower() and "kodu" in question.lower():
        code = get_order_return_code(question)
        if code:
            return ChatResponse(answer=f"Siparişin iade kodu: {code}", source="return_code")

    # 2) KB + LLM
    sim_ans = get_similar_answer(question)
    answer  = llm_with_context(question, f"- {sim_ans}")
    return ChatResponse(answer=answer, source="kb+llm")

if __name__ == "__main__":
    import uvicorn
    print("🚀 FastAPI Chat Server başlatılıyor...")
    print("📱 Flutter'dan gelen istekler kabul ediliyor...")
    uvicorn.run(app, host="0.0.0.0", port=8000, reload=True)
