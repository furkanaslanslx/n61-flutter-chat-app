# N61 AI Chat Entegrasyonu

Bu proje, Python tabanlı yapay zeka sohbet fonksiyonunu Flutter uygulaması ile entegre eder.

## Kurulum ve Çalıştırma

### 1. Python API'yi Başlatma

```bash
cd scripts
python3 -m pip install -r requirements.txt
python3 chat_api.py
```

Alternatif olarak:
```bash
cd scripts
./start_api.sh
```

### 2. Flutter Uygulamasını Çalıştırma

```bash
flutter pub get
flutter run
```

## Özellikler

- 🤖 **Yapay Zeka Sohbeti**: Groq LLM ile güçlendirilmiş akıllı cevaplar
- 📦 **İade Kodu Sorgulama**: Sipariş numarası ile iade kodu bulma
- 💬 **Güzel Arayüz**: Modern ve kullanıcı dostu sohbet arayüzü
- 🔄 **Gerçek Zamanlı**: Python API ile Flutter arasında anlık iletişim
- 💾 **Mesaj Kaydetme**: Sohbet geçmişini otomatik kaydetme
- 📱 **Responsive**: Tüm ekran boyutlarında uyumlu

## API Endpoints

- `GET /health` - API durumu kontrolü
- `POST /chat` - Sohbet mesajı gönderme

## Kullanım

1. Python API'yi başlatın (localhost:5000)
2. Flutter uygulamasını açın
3. Ana sayfadaki chat ikonuna tıklayın
4. Sorularınızı yazarak yapay zeka ile sohbet edin

## Örnek Sorular

- "Sipariş 12345 iade kodu nedir?"
- "Ürün iade nasıl yapılır?"
- "Kargo süreleri nedir?"

## Teknik Detaylar

### Python API
- Flask web framework
- Qdrant vector database
- Groq LLM API
- Sentence Transformers

### Flutter App
- Provider state management
- HTTP istekleri
- Markdown desteği
- SharedPreferences ile veri kaydetme
