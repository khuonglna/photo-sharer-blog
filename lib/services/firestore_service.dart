import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:photo_sharer/models/post_model.dart';
import 'package:photo_sharer/models/user_profile_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --- User Profile Operations ---
  Future<void> createUserProfile(User user, String displayName) async {
    final userProfile = UserProfile(
      uid: user.uid,
      email: user.email ?? 'No Email',
      displayName: displayName,
      createdAt: Timestamp.now(),
      // profileImageUrl will be updated later via profile screen + Storage
    );
    await _db.collection('users').doc(user.uid).set(userProfile.toFirestore());
  }

  Future<UserProfile?> getUserProfile(String uid) async {
    final docSnap = await _db.collection('users').doc(uid).get();
    if (docSnap.exists) {
      return UserProfile.fromFirestore(docSnap);
    }
    return null;
  }

  Future<void> updateUserProfile(UserProfile userProfile) async {
    await _db.collection('users').doc(userProfile.uid).update(userProfile.toFirestore());
  }

  // --- Post Operations ---
  Stream<List<Post>> getPostsStream() {
    return _db.collection('posts').orderBy('timestamp', descending: true).snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Post.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>)).toList());
  }

  Future<void> addPost({
    required String imageUrl, // This will come from Firebase Storage
    required String caption,
  }) async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception("User not logged in");
    }

    // Fetch current user's display name
    UserProfile? userProfile = await getUserProfile(currentUser.uid);
    String userName = userProfile?.displayName ?? 'Anonymous';

    final newPost = Post(
      id: '', // Firestore will generate ID
      imageUrl: imageUrl,
      caption: caption,
      userId: currentUser.uid,
      userName: userName,
      timestamp: Timestamp.now(),
      likesCount: 0,
    );

    await _db.collection('posts').add(newPost.toFirestore());
  }

  Future<void> deletePost(String postId, String postUserId) async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null || currentUser.uid != postUserId) {
      throw Exception("Not authorized to delete this post.");
    }
    // TODO: Also delete image from Firebase Storage
    await _db.collection('posts').doc(postId).delete();
  }

  Future<void> updatePostCaption(String postId, String newCaption, String postUserId) async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null || currentUser.uid != postUserId) {
      throw Exception("Not authorized to update this post.");
    }
    await _db.collection('posts').doc(postId).update({'caption': newCaption});
  }

  // --- Example: Like a post (Illustrative) ---
  Future<void> likePost(String postId) async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final postRef = _db.collection('posts').doc(postId);
    // This is a simplified like. A real app would handle unliking and store likes per user.
    await postRef.update({'likesCount': FieldValue.increment(1)});
  }
}
