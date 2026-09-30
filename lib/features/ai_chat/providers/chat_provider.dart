import 'package:flutter/foundation.dart';
import '../models/chat_message.dart';

/// Manages the local chat conversation state (UI-only, no backend calls).
///
/// Holds the list of messages and an [isAiTyping] flag used to show the
/// animated typing indicator while the simulated AI "thinks".
class ChatProvider extends ChangeNotifier {
  /// Simulated AI reply delay. Override in tests via the constructor.
  final Duration aiReplyDelay;

  ChatProvider({this.aiReplyDelay = const Duration(milliseconds: 1200)});

  final List<ChatMessage> _messages = [];
  bool _isAiTyping = false;

  /// Immutable view of messages, oldest first.
  List<ChatMessage> get messages => List.unmodifiable(_messages);

  bool get isAiTyping => _isAiTyping;

  bool get isEmpty => _messages.isEmpty;

  /// Sends a user message and triggers the simulated AI reply.
  ///
  /// Ignores blank / whitespace-only input.
  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    // 1. Add the user message immediately.
    _messages.add(ChatMessage(
      id: _nextId(),
      text: trimmed,
      isUser: true,
      timestamp: DateTime.now(),
    ));
    _isAiTyping = true;
    notifyListeners();

    // 2. Simulate the AI "thinking".
    await Future.delayed(aiReplyDelay);

    // TODO: replace with the real AI workflow endpoint via ApiClient
    // e.g. final reply = await ApiClient().post('/ai/chat', body: {'message': trimmed});
    _messages.add(ChatMessage(
      id: _nextId(),
      text:
          "The AI planner isn't connected yet. Soon I'll be able to help you plan your wedding.",
      isUser: false,
      timestamp: DateTime.now(),
    ));
    _isAiTyping = false;
    notifyListeners();
  }

  /// Clears all messages and resets typing state.
  void clearChat() {
    _messages.clear();
    _isAiTyping = false;
    notifyListeners();
  }

  int _idCounter = 0;
  String _nextId() => 'msg_${++_idCounter}';
}
