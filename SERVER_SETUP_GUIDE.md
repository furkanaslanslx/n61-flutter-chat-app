# 🚀 N61 Chat App - Server Kurulum ve Flutter Bağlantı Rehberi

Bu dokümanda N61 Flutter Chat uygulamasının FastAPI backend'ini başlatma ve Flutter uygulaması ile bağlantı kurma adımları detaylı olarak açıklanmıştır.

## 📋 Gereksinimler

### Sistem Gereksinimleri

- **Python 3.8+** (Virtual environment önerilir)
- **Flutter 3.5+**
- **Docker** (Qdrant vector database için)
- **Groq API Key** (LLM entegrasyonu için)

### Gerekli Servisler

- **Qdrant Vector Database** (Docker container)
- **FastAPI Backend Server** (Python)
- **Flutter Frontend** (Cross-platform)

---

## 🐳 1. Qdrant Vector Database Başlatma

Qdrant, konuşma verilerini vector search için kullanılan database'dir.

```bash
# Qdrant Docker container'ını başlat
docker run -d -p 6333:6333 --name qdrant qdrant/qdrant

# Container'ın çalışıp çalışmadığını kontrol et
docker ps | grep qdrant
```

### Qdrant Durumu Kontrol

- **URL**: http://localhost:6333
- **Dashboard**: http://localhost:6333/dashboard
- **Health Check**: `curl http://localhost:6333/health`

---

## 🐍 2. FastAPI Backend Server Başlatma

### 2.1 Dizin Yapısı

```
n61/
├── scripts/
│   ├── server.py           # FastAPI ana server
│   ├── requirements.txt    # Python bağımlılıkları
│   ├── start_server.sh     # Başlatma scripti
│   ├── upload_to_qdrant.py # Veri yükleme scripti
│   └── venv/               # Virtual environment
```

### 2.2 Virtual Environment Kurulumu

```bash
cd scripts

# Virtual environment oluştur (ilk kurulumda)
python3 -m venv venv

# Virtual environment'ı aktifleştir
source venv/bin/activate  # macOS/Linux
# veya
venv\Scripts\activate     # Windows

# Bağımlılıkları yükle
pip install -r requirements.txt
```

### 2.3 Server Başlatma Yöntemleri

#### Yöntem 1: Startup Script (Önerilen)

```bash
cd scripts
chmod +x start_server.sh
./start_server.sh
```

#### Yöntem 2: Manuel Başlatma

```bash
cd scripts
source venv/bin/activate
python server.py
```

#### Yöntem 3: Uvicorn ile Başlatma

```bash
cd scripts
source venv/bin/activate
uvicorn server:app --host 0.0.0.0 --port 8000 --reload
```

### 2.4 Server Başlatma Çıktısı

Server başarıyla başladığında şu mesajları göreceksiniz:

```
🚀 N61 FastAPI Chat Server Başlatılıyor...
🔧 Virtual environment aktifleştiriliyor...
📋 Bağımlılıklar yükleniyor...
🌟 Server başlatılıyor (http://localhost:8000)...
INFO: Uvicorn running on http://0.0.0.0:8000
```

### 2.5 API Endpoint'leri Test Etme

```bash
# Health check
curl http://localhost:8000/health

# Chat endpoint test
curl -X POST "http://localhost:8000/chat" \
  -H "Content-Type: application/json; charset=utf-8" \
  -d '{
    "message": "Merhaba, nasılsın?",
    "session_id": "test-123"
  }'
```

---

## 📱 3. Flutter Uygulaması Bağlantısı

### 3.1 Flutter App Başlatma

```bash
# Ana proje dizininde
flutter pub get
flutter run

# Belirli platform için
flutter run -d macos      # macOS Desktop
flutter run -d chrome     # Web Browser
flutter run -d android    # Android Emulator
flutter run -d ios        # iOS Simulator
```

### 3.2 Platform Bazlı URL Ayarları

Flutter uygulaması platform'a göre otomatik olarak doğru URL'i seçer:

```dart
// lib/services/chat_api.dart
static String get _baseUrl {
  if (Platform.isAndroid) {
    return "http://10.0.2.2:8000";     // Android Emulator
  } else if (Platform.isIOS) {
    return "http://localhost:8000";    // iOS Simulator
  } else {
    return "http://localhost:8000";    // Desktop (macOS/Windows/Linux)
  }
}
```

### 3.3 Bağlantı Sorunları ve Çözümler

#### Problem 1: "Connection refused" hatası

**Çözüm:**

```bash
# 1. Server'ın çalışıp çalışmadığını kontrol et
curl http://localhost:8000/health

# 2. Port'un kullanımda olup olmadığını kontrol et
lsof -i :8000

# 3. Server'ı yeniden başlat
pkill -f server.py
cd scripts && ./start_server.sh
```

#### Problem 2: Android Emulator bağlantı sorunu

**Çözüm:**

- Android Emulator için `10.0.2.2:8000` IP adresi kullanılır
- Gerçek Android cihaz için network IP'nizi kullanın

#### Problem 3: Türkçe karakter bozukluğu

**Çözüm:**

- HTTP headers'da UTF-8 charset belirtildi
- Response parsing'de `utf8.decode()` kullanıldı
- Backend'de `JSONResponse` ile UTF-8 support

---

## 🔧 4. Konfigürasyon Ayarları

### 4.1 Groq API Key

`scripts/server.py` dosyasında GROQ_API_KEY değişkenini güncelleyin:

```python
GROQ_API_KEY = "your-groq-api-key-here"
```

**Güvenlik Önerisi:** API key'i environment variable olarak kullanın:

```bash
export GROQ_API_KEY="your-api-key"
```

### 4.2 Qdrant Ayarları

```python
QDRANT_HOST = "localhost"
QDRANT_PORT = 6333
INSTR_COLLECTION = "n61_instructions"
ORDER_COLLECTION = "order_returns"
```

### 4.3 LLM Model Ayarları

```python
LLM_MODEL = "meta-llama/llama-4-scout-17b-16e-instruct"
EMBED_MODEL = "sentence-transformers/LaBSE"
```

---

## 🚨 5. Troubleshooting

### Server Başlatma Sorunları

#### Port 8000 kullanımda hatası

```bash
# Port'u kullanan process'i bul ve durdur
lsof -ti:8000 | xargs kill -9

# Server'ı yeniden başlat
cd scripts && ./start_server.sh
```

#### Python import hataları

```bash
# Virtual environment'ın aktif olduğunu kontrol et
which python

# Bağımlılıkları yeniden yükle
pip install -r requirements.txt --force-reinstall
```

#### Qdrant bağlantı hatası

```bash
# Qdrant container'ını kontrol et
docker ps | grep qdrant

# Durduysa yeniden başlat
docker start qdrant

# Yeni container başlat
docker run -d -p 6333:6333 --name qdrant qdrant/qdrant
```

### Flutter Bağlantı Sorunları

#### API ping hatası

1. Server'ın çalıştığını doğrulayın: `curl http://localhost:8000/health`
2. Firewall ayarlarını kontrol edin
3. URL'i platform'a göre ayarlayın

#### Session geçmişi kayboluyor

- Session veriler `scripts/session_data.json` dosyasında saklanır
- Server yeniden başladığında otomatik yüklenir

---

## 📊 6. Sistem Durumu Kontrol

### Tüm Servisleri Kontrol Etme

```bash
# 1. Qdrant kontrol
curl http://localhost:6333/health

# 2. FastAPI kontrol
curl http://localhost:8000/health

# 3. Chat endpoint kontrol
curl -X POST "http://localhost:8000/chat" \
  -H "Content-Type: application/json" \
  -d '{"message": "test"}'

# 4. Flutter app durumu
flutter doctor
```

### Log Dosyaları

- **Server logs**: Terminal çıktısı
- **Session data**: `scripts/session_data.json`
- **Flutter logs**: VS Code debug console

---

## 🎯 7. Başarılı Kurulum Kontrolü

Tüm sistemin doğru çalıştığını test etmek için:

1. **Qdrant çalışıyor mu?** ✅

   ```bash
   curl http://localhost:6333/health
   # Response: {"title":"qdrant - vector search engine","version":"1.x.x"}
   ```

2. **FastAPI server çalışıyor mu?** ✅

   ```bash
   curl http://localhost:8000/health
   # Response: {"status":"ok"}
   ```

3. **Chat API çalışıyor mu?** ✅

   ```bash
   curl -X POST "http://localhost:8000/chat" \
     -H "Content-Type: application/json" \
     -d '{"message": "Merhaba"}'
   # Response: JSON with answer field
   ```

4. **Flutter app bağlanıyor mu?** ✅
   - Uygulamayı başlatın
   - Bir mesaj gönderin
   - Cevap alabildiğinizi kontrol edin

---

## 📝 8. Notlar

### Geliştirme Modu

- Server `--reload` modu ile çalışır (kod değişikliğinde otomatik yeniden başlar)
- Flutter hot reload desteklenir

### Production Modu

- Environment variables kullanın
- CORS ayarlarını production domain'e göre sınırlayın
- HTTPS kullanın
- Rate limiting ekleyin

### Session Yönetimi

- Session veriler kalıcı olarak saklanır
- Maksimum 50 mesaj tutulur (performans için)
- Session temizleme: Chat'i clear butonuyla temizleyin

---

## 🆘 Hızlı Çözüm Komutları

```bash
# Tüm servisleri yeniden başlat
docker restart qdrant
cd scripts && pkill -f server.py && ./start_server.sh

# Flutter'ı temiz başlat
flutter clean && flutter pub get && flutter run

# Port'ları temizle
lsof -ti:8000 | xargs kill -9
lsof -ti:6333 | xargs kill -9
```

---

**📞 Destek:** Bu rehber ile ilgili sorunlarınız için proje README.md dosyasını kontrol edin.

**🔄 Güncelleme:** Son güncelleme tarihi: 20 Haziran 2025
