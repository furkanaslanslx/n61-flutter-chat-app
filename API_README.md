# N61 FastAPI Chat System

Bu proje, mevcut Flutter chatbot sistemini modern bir FastAPI backend ile entegre eder.

## Sistem Mimarisi

```
Flutter App (Dart)
    ↓ HTTP REST API
FastAPI Server (Python)
    ↓ Vector Search & LLM
Qdrant + Groq API
```

## Dosya Yapısı

```
project-root/
├── scripts/
│   ├── server.py           # FastAPI sunucusu
│   ├── upload_to_qdrant.py # Data yükleme scripti
│   ├── requirements.txt    # Python bağımlılıkları
│   ├── start_server.sh     # Sunucu başlatma scripti
│   └── venv/               # Virtual environment
└── lib/
    ├── services/
    │   └── chat_api.dart   # Flutter API istemcisi
    └── viewmodel/
        └── chat_view_model.dart # Chat state yönetimi
```

## Kurulum ve Çalıştırma

### 1. Backend (FastAPI)

```bash
cd scripts

# Virtual environment oluştur
python3 -m venv venv
source venv/bin/activate

# Bağımlılıkları yükle
pip install -r requirements.txt

# Qdrant başlat (Docker gerekli)
docker run -p 6333:6333 qdrant/qdrant

# Data'yı Qdrant'a yükle
python upload_to_qdrant.py

# Sunucuyu başlat
./start_server.sh
```

### 2. Frontend (Flutter)

```bash
# Flutter projesi ana dizininde
flutter run
```

## API Endpoints

### GET /health

Sunucu durumunu kontrol eder.

```bash
curl http://localhost:8000/health
```

### POST /chat

Chat mesajı gönderir.

```bash
curl -X POST "http://localhost:8000/chat" \
  -H "Content-Type: application/json" \
  -d '{"message": "Merhaba!"}'
```

**Response:**

```json
{
  "answer": "Merhaba! Nasıl yardımcı olabilirim?",
  "source": "kb+llm"
}
```

## Özellikler

- **Vector Search**: Qdrant ile semantik arama
- **LLM Integration**: Groq API ile gelişmiş dil modeli
- **RESTful API**: FastAPI ile modern HTTP API
- **Flutter Integration**: Native HTTP client entegrasyonu
- **Error Handling**: Fallback cevaplar ve hata yönetimi
- **CORS Support**: Mobil cihazlar için CORS desteği

## Geliştirme

### URL Konfigürasyonu

`lib/services/chat_api.dart` dosyasında:

- Android Emulator: `http://10.0.2.2:8000`
- iOS Simulator: `http://localhost:8000`
- Gerçek Cihaz: `http://[BILGISAYAR_IP]:8000`

### Groq API Key

`scripts/server.py` dosyasında GROQ_API_KEY değişkenini kendi API anahtarınızla değiştirin.

## Sorun Giderme

1. **Qdrant Bağlantı Hatası**: Docker container'ının çalıştığından emin olun
2. **Timeout Hataları**: Qdrant'a data yükleme işlemi uzun sürebilir
3. **Flutter HTTP Hataları**: Android emulator için URL'yi kontrol edin
4. **Groq API Hataları**: API anahtarının geçerli olduğundan emin olun
