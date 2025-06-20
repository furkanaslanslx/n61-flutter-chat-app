import os
import pandas as pd
from sentence_transformers import SentenceTransformer
from qdrant_client import QdrantClient
from qdrant_client.http.models import VectorParams, Distance, PointStruct

# 1) Ayarlar
QDRANT_HOST = "localhost"
QDRANT_PORT = 6333
INSTR_COLLECTION = "n61_instructions"
ORDER_COLLECTION = "order_returns"
EMBED_MODEL = "sentence-transformers/LaBSE"

# 2) Qdrant client
client = QdrantClient(host=QDRANT_HOST, port=QDRANT_PORT)

# 3) Embedding modeli
model = SentenceTransformer(EMBED_MODEL)

# ————————————————————————————————
# A) Sorular & Cevaplar (Embedding + Qdrant)
# ————————————————————————————————
df_inst = pd.read_csv(os.path.join("..", "data", "instructions.csv"), on_bad_lines='skip').dropna(subset=["question","answer"])
# embed
inst_texts = df_inst["question"].tolist()
inst_embeds = model.encode(inst_texts, show_progress_bar=True)

# recreate
client.recreate_collection(
    collection_name=INSTR_COLLECTION,
    vectors_config=VectorParams(size=inst_embeds.shape[1], distance=Distance.COSINE),
)

# upsert batch'ler
points = [
    PointStruct(id=i,
                vector=inst_embeds[i],
                payload={
                    "question": df_inst.loc[i,"question"],
                    "answer":   df_inst.loc[i,"answer"]
                })
    for i in range(len(df_inst))
]
for i in range(0, len(points), 256):
    client.upsert(collection_name=INSTR_COLLECTION, points=points[i:i+256])
print(f"[✓] {INSTR_COLLECTION} koleksiyonu yüklendi ({len(points)} kayıt).")


# ————————————————————————————————
# B) Sipariş & İade Kodu (Embedding + Qdrant)
# ————————————————————————————————
df_ord = pd.read_csv(os.path.join("..", "data", "order_returns.csv")).dropna()
# Biz de burda "siparis_no" + "iade_kodu" birleşimini embed ediyoruz:
ord_texts = (df_ord["siparis_no"].astype(str) + " " + df_ord["iade_kodu"]).tolist()
ord_embeds = model.encode(ord_texts, show_progress_bar=True)

client.recreate_collection(
    collection_name=ORDER_COLLECTION,
    vectors_config=VectorParams(size=ord_embeds.shape[1], distance=Distance.COSINE),
)

points = [
    PointStruct(id=i,
                vector=ord_embeds[i],
                payload={
                    "siparis_no": int(df_ord.loc[i,"siparis_no"]),
                    "urun_adi":   df_ord.loc[i,"urun_adi"],
                    "iade_kodu":  df_ord.loc[i,"iade_kodu"],
                })
    for i in range(len(df_ord))
]
for i in range(0, len(points), 256):
    client.upsert(collection_name=ORDER_COLLECTION, points=points[i:i+256])
print(f"[✓] {ORDER_COLLECTION} koleksiyonu yüklendi ({len(points)} kayıt).") 