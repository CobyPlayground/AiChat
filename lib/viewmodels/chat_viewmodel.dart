import 'package:flutter/foundation.dart';
import '../models/chat_message.dart';
import '../services/ai_service.dart';
import '../models/character.dart';
import '../services/chat_storage.dart';
import '../services/ad_service.dart';
import 'package:flutter/material.dart';

class ChatViewModel extends ChangeNotifier {
  final Character character;
  final AIService aiService;
  final ChatStorage chatStorage;
  final TextEditingController messageController = TextEditingController();
  
  List<ChatMessage> _messages = [];
  bool _isGenerating = false;

  ChatViewModel({
    required this.character,
    required this.aiService,
    required this.chatStorage,
  }) {
    _loadMessages();
    aiService.initializeForCharacter(character);
  }

  List<ChatMessage> get messages => _messages;
  bool get isGenerating => _isGenerating;

  Future<void> _loadMessages() async {
    try {
      _messages = await chatStorage.getMessages(character.id);
      if (_messages.isEmpty) {
        final welcomeMessage = ChatMessage(
          content: '${character.nameJp}です。よろしくお願いします！',
          role: 'assistant',
          timestamp: DateTime.now(),
          explanation: '기본적인 자기소개 표현입니다.\n- 〜です: ~입니다\n- よろしくお願いします: 잘 부탁드립니다',
          vocabulary: [
            Vocabulary(
              word: 'よろしく',
              reading: 'よろしく',
              meaning: '잘 부탁드립니다',
            ),
            Vocabulary(
              word: 'お願い',
              reading: 'おねがい',
              meaning: '부탁',
            ),
          ],
        );
        _messages.add(welcomeMessage);
        await chatStorage.saveMessage(character.id, welcomeMessage);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load messages: $e');
    }
  }

  Future<void> sendMessage() async {
    final userMessage = messageController.text.trim();
    if (userMessage.isEmpty || _isGenerating) return;

    final userChatMessage = ChatMessage(
      content: userMessage,
      role: 'user',
      timestamp: DateTime.now(),
    );

    messageController.clear();
    _messages.add(userChatMessage);
    await chatStorage.saveMessage(character.id, userChatMessage);
    AdService().incrementMessageCount();
    notifyListeners();

    _isGenerating = true;
    notifyListeners();

    try {
      final aiMessage = await aiService.generateResponse(userMessage);
      _messages.add(aiMessage);
      await chatStorage.saveMessage(character.id, aiMessage);
      AdService().incrementMessageCount();
    } catch (e) {
      _messages.add(ChatMessage(
        content: '죄송합니다. 오류가 발생했습니다. 다시 시도해주세요.',
        role: 'assistant',
        timestamp: DateTime.now(),
      ));
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }

  Future<void> resetChat() async {
    try {
      await chatStorage.clearMessages(character.id);
      _messages.clear();
      messageController.clear();
      _isGenerating = false;

      final welcomeMessage = ChatMessage(
        content: '${character.nameJp}です。よろしくお願いします！',
        role: 'assistant',
        timestamp: DateTime.now(),
        explanation: '기본적인 자기소개 표현입니다.\n- 〜です: ~입니다\n- よろしくお願いします: 잘 부탁드립니다',
        vocabulary: [
          Vocabulary(
            word: 'よろしく',
            reading: 'よろしく',
            meaning: '잘 부탁드립니다',
          ),
          Vocabulary(
            word: 'お願い',
            reading: 'おねがい',
            meaning: '부탁',
          ),
        ],
      );
      _messages.add(welcomeMessage);
      await chatStorage.saveMessage(character.id, welcomeMessage);
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to reset chat: $e');
    }
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }
} 