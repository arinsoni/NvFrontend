
class Thread {
  final String threadId;
  final String threadName;
  final bool isFavorite;
  final String threadTimestamp;

  Thread({
    required this.threadId,
    required this.threadName,
    required this.isFavorite,
    required this.threadTimestamp,
  });

  @override
  String toString() {
    return 'Thread(threadId: $threadId, threadName: $threadName, isFavorite: $isFavorite, threadTimestamp: $threadTimestamp)';
  }


  factory Thread.fromMap(Map<String, dynamic> map) {
    return Thread(
        threadId: map['threadId'] ?? '', // Adding null check
        threadName: map['threadName'] ?? '', // Adding null check
        isFavorite: map['isFavorite'] as bool,
        threadTimestamp: map['lastMessageTimestamp'] ?? '' // Adding null check
        );
  }

  Map<String, dynamic> toMap() {
    return {
      'threadId': threadId,
      'threadName': threadName,
      'isFavorite': isFavorite,
      'threadTimestamp': threadTimestamp,
    };
  }
}
