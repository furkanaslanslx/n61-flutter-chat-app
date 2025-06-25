import os
import pandas as pd
from qdrant_client import QdrantClient
from qdrant_client.http.models import VectorParams, Distance, PointStruct
from sentence_transformers import SentenceTransformer

# 1) Ayarlar
QDRANT_HOST = "localhost"
QDRANT_PORT = 6333
INSTR_COLLECTION = "n61_instructions"
EMBED_MODEL = "sentence-transformers/paraphrase-multilingual-MiniLM-L12-v2"

# 2) Embedding modeli ve Qdrant Client
model = SentenceTransformer(EMBED_MODEL)
client = QdrantClient(host=QDRANT_HOST, port=QDRANT_PORT, timeout=120.0, prefer_grpc=True)

# ————————————————————————————————
# A) Sorular & Cevaplar (Embedding + Qdrant)
# ————————————————————————————————
# CSV'yi ilk iki virgüle göre bölerek oku (her zaman 3 sütun)
data = []
with open(os.path.join("..", "data", "instructions.csv"), encoding="utf-8") as f:
    header = f.readline().strip().split(",")
    for line in f:
        line = line.strip()
        if not line:
            continue
        parts = line.split(",", 2)
        while len(parts) < 3:
            parts.append("")
        data.append(parts)
df = pd.DataFrame(data, columns=header)

print(df.head())
print(df.shape)

# Kolon kontrolü
required_cols = {"question", "answer"}
assert required_cols.issubset(df.columns), f"Eksik kolonlar: {required_cols - set(df.columns)}"

# Boş veya eksik satırları atla
filtered_rows = df.dropna(subset=["question", "answer"])

# Sadece `question` sütununu embed ediyoruz, çünkü arama bu sütuna göre yapılacak.
inst_vectors = model.encode(filtered_rows["question"].tolist(), show_progress_bar=True)

if client.collection_exists(INSTR_COLLECTION):
    client.delete_collection(INSTR_COLLECTION)
client.create_collection(
    collection_name=INSTR_COLLECTION,
    vectors_config=VectorParams(
        size=inst_vectors.shape[1],   # ← burada inst_vectors kullanın
        distance=Distance.COSINE,
    ),
)


points = [
    PointStruct(id=i, vector=inst_vectors[i].tolist(), payload={
        "content": row["question"] + " " + row["answer"],
        "question": row["question"],
        "answer": row["answer"],
        "question_type": row.get("question_type", "")
    })
    for i, row in filtered_rows.iterrows()
]
client.upsert(collection_name=INSTR_COLLECTION, points=points, wait=True)
print(f"[✓] {INSTR_COLLECTION} koleksiyonu yüklendi ({len(points)} kayıt).")
