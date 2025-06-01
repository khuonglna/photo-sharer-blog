import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart'; // To get current user for path if needed

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance; // Optional: if you structure paths by user ID
  final ImagePicker _picker = ImagePicker();

  // Pick an Image
  Future<File?> pickImageFromDevice(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source, imageQuality: 85); // Added imageQuality
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
    } catch (e) {
      print("Error picking image: $e");
      // In a real app, you might want to throw a custom exception or return an error object
    }
    return null;
  }

  // Upload Image File and Get Download URL
  Future<String?> uploadFileToStorage(File imageFile, String storagePath) async {
    // storagePath example: "post_images/some_unique_filename.jpg"
    // Or, if user-specific: "post_images/${_auth.currentUser?.uid}/some_unique_filename.jpg"
    try {
      final Reference storageRef = _storage.ref().child(storagePath);

      // Define upload task with metadata (optional, but good for content type)
      UploadTask uploadTask = storageRef.putFile(
        imageFile,
        SettableMetadata(contentType: 'image/jpeg'), // Or png, etc.
      );

      // You can listen to the upload progress if needed:
      // uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
      //   double progress = snapshot.bytesTransferred / snapshot.totalBytes;
      //   print('Upload is $progress% complete.');
      // });

      final TaskSnapshot snapshot = await uploadTask;

      if (snapshot.state == TaskState.success) {
        final String downloadUrl = await snapshot.ref.getDownloadURL();
        return downloadUrl;
      } else {
        print("Upload task was not successful: ${snapshot.state}");
        return null;
      }
    } on FirebaseException catch (e) {
      print("Firebase Storage Error: ${e.code} - ${e.message}");
      // e.g., e.code == 'permission-denied'
      return null;
    } catch (e) {
      print("General Error uploading file: $e");
      return null;
    }
  }
}