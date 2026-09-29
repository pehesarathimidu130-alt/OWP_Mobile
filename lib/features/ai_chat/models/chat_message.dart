/// Represents a single message in the AI chat conversation.
class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  @override
  String toString() =>
      'ChatMessage(id: $id, isUser: $isUser, text: ${text.length > 40 ? "${text.substring(0, 40)}…" : text})';
}
