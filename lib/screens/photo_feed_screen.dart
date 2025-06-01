import 'package:flutter/material.dart';
import 'package:photo_sharer/auth/auth_service.dart';
import 'package:photo_sharer/models/post_model.dart';
import 'package:photo_sharer/screens/create_post_screen.dart';
import 'package:photo_sharer/screens/profile_screen.dart'; // Import profile screen
import 'package:photo_sharer/services/firestore_service.dart';
import 'package:photo_sharer/widgets/post_card.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PhotoFeedScreen extends StatefulWidget {
  const PhotoFeedScreen({super.key});

  @override
  State<PhotoFeedScreen> createState() => _PhotoFeedScreenState();
}

class _PhotoFeedScreenState extends State<PhotoFeedScreen> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photo Sharer Feed'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              if (_currentUser != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(userId: _currentUser.uid),
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await _authService.signOut();
              // AuthGate will handle navigation
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Post>>(
        stream: _firestoreService.getPostsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No posts yet. Be the first to share!',
                style: TextStyle(fontSize: 18, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            );
          }

          final posts = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async {
              // You can add a manual refresh logic if needed, though streams update automatically
              setState(() {}); // Rebuild to fetch again if not using stream for some part
            },
            child: ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                return PostCard(post: posts[index]);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreatePostScreen()),
          );
        },
        tooltip: 'Add Post',
        child: const Icon(Icons.add_a_photo_outlined),
      ),
    );
  }
}
