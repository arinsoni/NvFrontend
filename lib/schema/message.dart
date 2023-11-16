class Message {
 late String text;
 final String sender;
 final DateTime timestamp;
 final String userId;
 String? audioUrl;
 String? threadId;
 final bool thumbsUp;
 final bool thumbsDown;
 String? msgId; // Added field for message ID


 Message({
     required this.text,
     required this.sender,
     required this.timestamp,
     required this.userId,
     this.audioUrl,
     this.threadId,
     required this.thumbsUp,
     required this.thumbsDown,
     this.msgId, // Added msgId to constructor
 });


 Map<String, dynamic> toMap() {
   return {
     'text': text,
     'sender': sender,
     'timestamp': timestamp.toIso8601String(),
     'userId': userId,
     'audioUrl': audioUrl,
     'threadId': threadId,
     'thumbsUp': thumbsUp,
     'thumbsDown': thumbsDown,
     'msgId': msgId // Add msgId to map
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
     thumbsUp: map['thumbsUp'],
     thumbsDown: map['thumbsDown'],
     msgId: map['msgId'] // Retrieve msgId from map
   );
 }
}

     