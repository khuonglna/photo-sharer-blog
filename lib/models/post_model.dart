import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id; // Document ID
  final String imageUrl;
  final String caption;
  final String userId;
  final String userName; // Denormalized for convenience
  final Timestamp timestamp;
  final int likesCount; // Example for future feature

  Post({
    required this.id,
    required this.imageUrl,
    required this.caption,
    required this.userId,
    required this.userName,
    required this.timestamp,
    this.likesCount = 0,
  });

  factory Post.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    if (data == null) {
      throw StateError('Missing data for Post: ${snapshot.id}');
    }
    return Post(
      id: snapshot.id,
      imageUrl: data['imageUrl'] ?? '',
      caption: data['caption'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Anonymous',
      timestamp: data['timestamp'] ?? Timestamp.now(),
      likesCount: data['likesCount'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'imageUrl': imageUrl,
      'caption': caption,
      'userId': userId,
      'userName': userName,
      'timestamp': timestamp,
      'likesCount': likesCount,
    };
  }
}