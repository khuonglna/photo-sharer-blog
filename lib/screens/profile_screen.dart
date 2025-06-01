import 'package:flutter/material.dart';
import 'package:photo_sharer/models/user_profile_model.dart';
import 'package:photo_sharer/services/firestore_service.dart';
// import 'package:image_picker/image_picker.dart'; // For profile image
// import 'dart:io'; // For File

class ProfileScreen extends StatefulWidget {
  final String userId;
  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _displayNameController = TextEditingController();
  UserProfile? _userProfile;
  bool _isLoading = true;
  bool _isEditing = false;
  // File? _profileImageFile; // For image picking

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
    });
    _userProfile = await _firestoreService.getUserProfile(widget.userId);
    if (_userProfile != null) {
      _displayNameController.text = _userProfile!.displayName;
    }
    setState(() {
      _isLoading = false;
    });
  }

  // Future<void> _pickProfileImage() async {
  //   final XFile? pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
  //   if (pickedImage != null) {
  //     setState(() {
  //       _profileImageFile = File(pickedImage.path);
  //     });
  //     // In a real app, upload _profileImageFile to Firebase Storage
  //     // then update _userProfile.profileImageUrl and save.
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Profile image selected (upload not implemented yet).')),
  //     );
  //   }
  // }

  Future<void> _saveProfile() async {
    if (_userProfile == null || _displayNameController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
    });
    _userProfile!.displayName = _displayNameController.text;
    // TODO: if _profileImageFile is not null, upload it to storage, get URL and set _userProfile.profileImageUrl

    try {
      await _firestoreService.updateUserProfile(_userProfile!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!'), backgroundColor: Colors.green),
      );
      setState(() {
        _isEditing = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        actions: [
          if (!_isEditing && !_isLoading && _userProfile != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit Profile',
              onPressed: () => setState(() => _isEditing = true),
            ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.save_outlined),
              tooltip: 'Save Profile',
              onPressed: _saveProfile,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userProfile == null
              ? const Center(child: Text('Could not load profile.'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        // onTap: _isEditing ? _pickProfileImage : null,
                        onTap: _isEditing
                            ? () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Profile image update (coming soon!)')),
                                );
                              }
                            : null,
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey[300],
                          // backgroundImage: _profileImageFile != null
                          //     ? FileImage(_profileImageFile!)
                          //     : (_userProfile!.profileImageUrl != null && _userProfile!.profileImageUrl!.isNotEmpty
                          //         ? NetworkImage(_userProfile!.profileImageUrl!)
                          //         : null) as ImageProvider?,
                          backgroundImage:
                              (_userProfile!.profileImageUrl != null && _userProfile!.profileImageUrl!.isNotEmpty
                                  ? NetworkImage(_userProfile!.profileImageUrl!)
                                  : null) as ImageProvider?,
                          child: (_userProfile!.profileImageUrl == null ||
                                  _userProfile!.profileImageUrl!.isEmpty) // && _profileImageFile == null
                              ? Icon(Icons.person_outline, size: 60, color: Colors.grey[700])
                              : null,
                        ),
                      ),
                      if (_isEditing)
                        TextButton.icon(
                          icon: const Icon(Icons.camera_alt_outlined),
                          label: const Text('Change Photo (Soon)'),
                          // onPressed: _pickProfileImage,
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Profile image update (coming soon!)')),
                            );
                          },
                        ),
                      const SizedBox(height: 20),
                      _isEditing
                          ? TextFormField(
                              controller: _displayNameController,
                              decoration: const InputDecoration(
                                labelText: 'Display Name',
                                border: OutlineInputBorder(),
                              ),
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            )
                          : Text(
                              _userProfile!.displayName,
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                      const SizedBox(height: 10),
                      Text(
                        _userProfile!.email,
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Member since: ${_userProfile!.createdAt.toDate().toLocal().toString().substring(0, 10)}', // Basic date display
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      ),
                      const SizedBox(height: 30),
                      if (_isEditing)
                        ElevatedButton(
                          onPressed: _saveProfile,
                          child: const Text('Save Changes'),
                        )
                    ],
                  ),
                ),
    );
  }
}
