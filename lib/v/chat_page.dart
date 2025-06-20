import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/chat_view_model.dart';
import '../widgets/chat_widgets.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Sayfa açıldığında en alta scroll et
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChatViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'N61 AI Asistan',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          actions: [
            Consumer<ChatViewModel>(
              builder: (context, chatVM, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // API bağlantı durumu
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: chatVM.isApiConnected ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            chatVM.isApiConnected ? Icons.wifi : Icons.wifi_off,
                            size: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            chatVM.isApiConnected ? 'Bağlı' : 'Bağlantısız',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Temizle butonu
                    IconButton(
                      icon: const Icon(Icons.clear_all),
                      onPressed: () => _showClearDialog(chatVM),
                      tooltip: 'Sohbeti Temizle',
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        body: Consumer<ChatViewModel>(
          builder: (context, chatVM, child) {
            return Column(
              children: [
                // Mesajlar listesi
                Expanded(
                  child: chatVM.messages.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: chatVM.messages.length + (chatVM.isLoading ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == chatVM.messages.length && chatVM.isLoading) {
                              return const TypingIndicator();
                            }

                            final message = chatVM.messages[index];
                            return ChatBubble(message: message);
                          },
                        ),
                ),
                // Mesaj gönderme alanı
                _buildMessageInput(chatVM),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Merhaba! 👋',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'N61 AI Asistanına hoş geldiniz.\nSorularınızı yazarak başlayabilirsiniz.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 32),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              children: [
                const Text(
                  '💡 Örnek sorular:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '• "Sipariş 12345 iade kodu nedir?"\n'
                  '• "Ürün iade nasıl yapılır?"\n'
                  '• "Kargo süreleri nedir?"',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput(ChatViewModel chatVM) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: chatVM.messageController,
              decoration: InputDecoration(
                hintText: chatVM.isApiConnected ? 'Mesajınızı yazın...' : 'API bağlantısı bekleniyor...',
                enabled: chatVM.isApiConnected && !chatVM.isLoading,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (text) {
                if (text.trim().isNotEmpty && chatVM.isApiConnected && !chatVM.isLoading) {
                  chatVM.sendMessage(text);
                  // Mesaj gönderildikten sonra scroll et
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _scrollToBottom();
                  });
                }
              },
            ),
          ),
          const SizedBox(width: 12),
          Material(
            color: chatVM.isApiConnected && !chatVM.isLoading ? Theme.of(context).primaryColor : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(25),
            child: InkWell(
              borderRadius: BorderRadius.circular(25),
              onTap: () {
                // chatVM.isApiConnected && !chatVM.isLoading
                //     ? () {
                final text = chatVM.messageController.text;
                if (text.trim().isNotEmpty) {
                  chatVM.sendMessage(text);
                  // Mesaj gönderildikten sonra scroll et
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _scrollToBottom();
                  });
                }
                //   }
                // : null,
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                child: Icon(
                  chatVM.isLoading ? Icons.hourglass_empty : Icons.send,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearDialog(ChatViewModel chatVM) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sohbeti Temizle'),
        content: const Text('Tüm mesajlar silinecek. Emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              chatVM.clearMessages();
              Navigator.pop(context);
            },
            child: const Text('Temizle'),
          ),
        ],
      ),
    );
  }
}
