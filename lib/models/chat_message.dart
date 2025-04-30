class ChatMessage {
  final int? id; // Nullable for messages not yet saved
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String modelUsed; // 'gemini', 'groq', 'user'

  ChatMessage({
    this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    required this.modelUsed,
  });

  // Method to convert a ChatMessage object into a Map for DB insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id, // id will be handled by DB auto-increment
      'text': text,
      'isUser': isUser ? 1 : 0, // Store boolean as integer
      'timestamp': timestamp.toIso8601String(), // Store timestamp as ISO string
      'modelUsed': modelUsed,
    };
  }

  // Method to create a ChatMessage object from a Map (retrieved from DB)
  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'],
      text: map['text'],
      isUser: map['isUser'] == 1,
      timestamp: DateTime.parse(map['timestamp']),
      modelUsed: map['modelUsed'],
    );
  }
}
