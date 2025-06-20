# N61 Flutter Chat Application with FastAPI Backend

Modern Flutter chat uygulaması ve FastAPI backend entegrasyonu. Vector search, LLM ve gerçek zamanlı sohbet desteği.

## 🚀 Özellikler

- **Modern Flutter UI**: Responsive ve kullanıcı dostu arayüz
- **FastAPI Backend**: REST API ile backend entegrasyonu
- **Vector Search**: Qdrant ile semantik arama
- **LLM Integration**: Groq API ile gelişmiş dil modeli
- **Cross-platform**: iOS, Android ve Desktop desteği
- **Real-time Chat**: HTTP REST API ile hızlı iletişim

## 🛠 Teknolojiler

### Frontend (Flutter)

- **Flutter 3.5+**: Cross-platform mobil uygulama
- **Provider**: State management
- **HTTP**: REST API iletişimi
- **SharedPreferences**: Yerel veri saklama

### Backend (Python)

- **FastAPI**: Modern, hızlı web framework
- **Qdrant**: Vector veritabanı
- **Groq API**: LLM entegrasyonu
- **SentenceTransformers**: Text embedding

## 📦 Kurulum

### Gereksinimler

- Flutter 3.5+
- Python 3.8+
- Docker (Qdrant için)
- Groq API Key

### 1. Repository'yi klonlayın

```bash
git clone https://github.com/furkanaslan71/n61-chat-app.git
cd n61-chat-app
```

### 2. Backend Kurulumu

```bash
cd scripts

# Virtual environment oluştur
python3 -m venv venv
source venv/bin/activate

# Bağımlılıkları yükle
pip install -r requirements.txt

# Qdrant başlat
docker run -p 6333:6333 qdrant/qdrant

# Sunucuyu başlat
./start_server.sh
```

### 3. Frontend Kurulumu

```bash
flutter pub get
flutter run
```

## 🔧 Konfigürasyon

### Groq API Key

`scripts/server.py` dosyasında GROQ_API_KEY değişkenini güncelleyin.

### Platform URL'leri

API URL'leri platform bazında otomatik ayarlanır:

- **Android Emulator**: `http://10.0.2.2:8000`
- **iOS Simulator**: `http://localhost:8000`
- **Desktop**: `http://localhost:8000`

## 📁 Proje Yapısı

```
n61-chat-app/
├── lib/                    # Flutter kaynak kodları
├── scripts/               # Python backend
├── data/                 # Training data
└── assets/              # Flutter assets
```

## 🌐 API Endpoints

### GET /health

```bash
curl http://localhost:8000/health
```

### POST /chat

```bash
curl -X POST "http://localhost:8000/chat" \
  -H "Content-Type: application/json" \
  -d '{"message": "Merhaba!"}'
```

## 🤝 Katkıda Bulunma

1. Fork edin
2. Feature branch oluşturun
3. Commit yapın
4. Pull Request açın

## 👤 Geliştirici

**Furkan Aslan**  
🔗 GitHub: [@furkanaslanslx](https://github.com/furkanaslanslx)

## 📄 Lisans

Bu proje MIT lisansı altında lisanslanmıştır. Detaylar için [LICENSE](LICENSE) dosyasına bakın.

---

⭐ Bu projeyi beğendiyseniz star vermeyi unutmayın!
