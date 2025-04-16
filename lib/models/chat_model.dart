class ChatMessageModel {
  final String message;
  final bool isUser;
  final DateTime timestamp;

  ChatMessageModel({
    required this.message,
    required this.isUser,
    required this.timestamp,
  });
}
