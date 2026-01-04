import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../theme/app_colors.dart';
import '../services/chatbot_service.dart';
import '../services/language_service.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _speechAvailable = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    _speechAvailable = await _speech.initialize(
      onError: (error) => debugPrint('Speech Error: $error'),
      onStatus: (status) => debugPrint('Speech Status: $status'),
    );
    setState(() {});
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final langService = context.watch<LanguageService>();
    final chatService = context.watch<ChatbotService>();
    
    return Scaffold(
      backgroundColor: AppColors.warmWhite,
      appBar: AppBar(
        backgroundColor: AppColors.warmWhite,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  langService.tr('InvestSathi AI', hi: 'इन्वेस्टसाथी AI', mr: 'इन्व्हेस्टसाथी AI'),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                Text(
                  langService.tr('Your financial guide', hi: 'आपका वित्तीय मार्गदर्शक', mr: 'तुमचा आर्थिक मार्गदर्शक'),
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: () => chatService.clearMessages(),
            tooltip: 'Clear chat',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: chatService.messages.isEmpty
                ? _buildWelcomeView(langService)
                : _buildChatList(chatService, langService),
          ),
          _buildInputArea(chatService, langService),
        ],
      ),
    );
  }

  Widget _buildWelcomeView(LanguageService langService) {
    final suggestions = langService.langCode == 'hi'
        ? ['SIP क्या है?', 'म्यूचुअल फंड कैसे काम करता है?', '₹100 से निवेश कैसे शुरू करें?', 'इमरजेंसी फंड क्या है?']
        : langService.langCode == 'mr'
            ? ['SIP म्हणजे काय?', 'म्युच्युअल फंड कसे काम करते?', '₹100 ने गुंतवणूक कशी सुरू करावी?', 'इमर्जन्सी फंड म्हणजे काय?']
            : ['What is SIP?', 'How do mutual funds work?', 'How to start investing with ₹100?', 'What is emergency fund?'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 48),
          ),
          const SizedBox(height: 20),
          Text(
            langService.tr('Hi! I\'m InvestSathi AI 👋', hi: 'नमस्ते! मैं इन्वेस्टसाथी AI हूं 👋', mr: 'नमस्कार! मी इन्व्हेस्टसाथी AI आहे 👋'),
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            langService.tr(
              'Ask me anything about investing, savings, or financial planning!',
              hi: 'निवेश, बचत या वित्तीय योजना के बारे में कुछ भी पूछें!',
              mr: 'गुंतवणूक, बचत किंवा आर्थिक नियोजनाबद्दल काहीही विचारा!',
            ),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Text(
            langService.tr('Try asking:', hi: 'ये पूछें:', mr: 'हे विचारा:'),
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: suggestions.map((s) => _buildSuggestionChip(s)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(String text) {
    return InkWell(
      onTap: () => _sendMessage(text),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        ),
        child: Text(text, style: TextStyle(color: AppColors.primary, fontSize: 13)),
      ),
    );
  }

  Widget _buildChatList(ChatbotService chatService, LanguageService langService) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: chatService.messages.length + (chatService.isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == chatService.messages.length && chatService.isLoading) {
          return _buildTypingIndicator();
        }
        final message = chatService.messages[index];
        return _buildMessageBubble(message, langService);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message, LanguageService langService) {
    final isUser = message.isUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? AppColors.primary : AppColors.cardBg,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: isUser ? Colors.white : AppColors.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                  if (!isUser) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () => langService.speak(message.text),
                          child: Icon(
                            langService.isSpeaking ? Icons.stop_rounded : Icons.volume_up_rounded,
                            size: 18,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0),
                _buildDot(1),
                _buildDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 600 + (index * 200)),
      builder: (context, value, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.3 + (value * 0.5)),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  Widget _buildInputArea(ChatbotService chatService, LanguageService langService) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: langService.tr(
                          'Ask anything...',
                          hi: 'कुछ भी पूछें...',
                          mr: 'काहीही विचारा...',
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(_textController.text),
                    ),
                  ),
                  if (_speechAvailable)
                    IconButton(
                      icon: Icon(
                        _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                        color: _isListening ? AppColors.error : AppColors.textSecondary,
                      ),
                      onPressed: _toggleListening,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(24),
            ),
            child: IconButton(
              icon: const Icon(Icons.send_rounded, color: Colors.white),
              onPressed: chatService.isLoading ? null : () => _sendMessage(_textController.text),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleListening() async {
    final langService = context.read<LanguageService>();
    
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
    } else {
      setState(() => _isListening = true);
      
      final localeId = langService.langCode == 'hi' ? 'hi_IN' 
          : langService.langCode == 'mr' ? 'mr_IN' 
          : 'en_US';
      
      await _speech.listen(
        onResult: (result) {
          setState(() {
            _textController.text = result.recognizedWords;
          });
          if (result.finalResult) {
            setState(() => _isListening = false);
            if (result.recognizedWords.isNotEmpty) {
              _sendMessage(result.recognizedWords);
            }
          }
        },
        localeId: localeId,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
      );
    }
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    
    _textController.clear();
    final langService = context.read<LanguageService>();
    final chatService = context.read<ChatbotService>();
    
    final response = await chatService.sendMessage(text, langService);
    
    // Auto-speak the response if voice is enabled
    if (langService.voiceEnabled && response.isNotEmpty) {
      await langService.speak(response);
    }
  }
}
