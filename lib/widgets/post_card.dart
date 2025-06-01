import 'package:flutter/material.dart';
import 'package:photo_sharer/models/post_model.dart';
import 'package:photo_sharer/services/firestore_service.dart'; // For delete/update actions
import 'package:firebase_auth/firebase_auth.dart'; // To check current user for actions
// import 'package:intl/intl.dart'; // For date formatting, add to pubspec.yaml

class PostCard extends StatelessWidget {
  final Post post;
  final FirestoreService _firestoreService = FirestoreService();
  final User? currentUser = FirebaseAuth.instance.currentUser;

  PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    // final formattedDate = DateFormat.yMMMd().add_jm().format(post.timestamp.toDate()); // Example date formatting

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Row(
              children: [
                // CircleAvatar(backgroundImage: NetworkImage(USER_PROFILE_IMAGE_URL_HERE)), // TODO: Add user profile image
                // SizedBox(width: 8),
                Text(
                  post.userName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Spacer(),
                if (currentUser != null && currentUser!.uid == post.userId)
                  PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'edit') {
                        // TODO: Implement edit post caption functionality
                        // Example: Show a dialog to edit caption
                        String? newCaption = await _showEditCaptionDialog(context, post.caption);
                        if (newCaption != null && newCaption.isNotEmpty) {
                          try {
                            await _firestoreService.updatePostCaption(post.id, newCaption, post.userId);
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(content: Text('Caption updated!')));
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error updating: $e'), backgroundColor: Colors.red));
                          }
                        }
                      } else if (value == 'delete') {
                        // TODO: Implement delete post functionality
                        bool confirmDelete = await _showConfirmDeleteDialog(context) ?? false;
                        if (confirmDelete) {
                          try {
                            await _firestoreService.deletePost(post.id, post.userId);
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Post deleted!')));
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error deleting: $e'), backgroundColor: Colors.red));
                          }
                        }
                      }
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'edit',
                        child: Text('Edit Caption'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: Text('Delete Post'),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          if (post.imageUrl.isNotEmpty)
            Image.network(
              post.imageUrl,
              fit: BoxFit.cover,
              height: 280, // Adjust as needed
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  height: 280,
                  color: Colors.grey[300],
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 280,
                  color: Colors.grey[300],
                  child: const Center(child: Icon(Icons.broken_image, color: Colors.grey, size: 50)),
                );
              },
            )
          else
            Container(
              height: 280,
              color: Colors.grey[300],
              child: const Center(child: Icon(Icons.image_not_supported, color: Colors.grey, size: 50)),
            ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              post.caption,
              style: const TextStyle(fontSize: 15),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
            child: Text(
              // formattedDate, // Use if you add intl package
              post.timestamp.toDate().toLocal().toString().substring(0, 16), // Basic date display
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ),
          // --- Illustrative Like Button ---
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 8.0),
          //   child: Row(
          //     children: [
          //       IconButton(
          //         icon: Icon(Icons.favorite_border, color: Colors.grey[700]),
          //         onPressed: () async {
          //            await _firestoreService.likePost(post.id);
          //         },
          //       ),
          //       Text('${post.likesCount} likes'),
          //     ],
          //   ),
          // ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Future<String?> _showEditCaptionDialog(BuildContext context, String currentCaption) async {
    TextEditingController captionController = TextEditingController(text: currentCaption);
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Caption'),
          content: TextField(
            controller: captionController,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Enter new caption'),
            maxLines: 3,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                Navigator.of(context).pop(captionController.text);
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool?> _showConfirmDeleteDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this post? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }
}
