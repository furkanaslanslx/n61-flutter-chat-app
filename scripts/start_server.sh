#!/bin/bash

echo "🚀 N61 FastAPI Chat Server Başlatılıyor..."

# Virtual environment kontrolü
if [ ! -d "venv" ]; then
    echo "📦 Virtual environment oluşturuluyor..."
    python3 -m venv venv
fi

# Virtual environment aktifleştir
echo "🔧 Virtual environment aktifleştiriliyor..."
source venv/bin/activate

# Bağımlılıkları yükle
echo "📋 Bağımlılıklar yükleniyor..."
pip install -r requirements.txt

# Server'ı başlat
echo "🌟 Server başlatılıyor (http://localhost:8000)..."
uvicorn server:app --host 0.0.0.0 --port 8000 --reload
