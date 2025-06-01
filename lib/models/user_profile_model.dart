import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String email;
  String displayName;
  String? profileImageUrl;
  final Timestamp createdAt;

  UserProfile({
    required this.uid,
    required this.email,
    required this.displayName,
    this.profileImageUrl,
    required this.createdAt,
  });

  factory UserProfile.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    return UserProfile(
      uid: snapshot.id,
      email: data?['email'] ?? '',
      displayName: data?['displayName'] ?? 'Anonymous',
      profileImageUrl: data?['profileImageUrl'],
      createdAt: data?['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt,
      // uid is the document ID, so not stored as a field
    };
  }
}