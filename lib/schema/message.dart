class Message {
  late String text;
  final String sender;
  final DateTime timestamp;

  final String userId;
  String? audioUrl;
  String? threadId;

  Message(
      {required this.text,
      required this.sender,
      required this.timestamp,
      required this.userId,
      this.audioUrl,
      this.threadId});

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'sender': sender,
      'timestamp': timestamp.toIso8601String(),
      'userId': userId,
      'audioUrl': audioUrl,
      'threadId': threadId
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      text: map['text'],
      sender: map['sender'],
      timestamp: DateTime.parse(map['timestamp'] ?? DateTime.now().toString()),
      userId: map['userId'] ?? '',
      audioUrl: map['audioUrl'],
      threadId: map['threadId'],
    );
  }
}