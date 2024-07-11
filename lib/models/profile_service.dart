import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:logger/logger.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Logger _logger = Logger();

  Future<void> updateProfile(String userId, String username, String email, String phoneNumber, File? profileImage) async {
    String? profileImageUrl;

    try {
      if (profileImage != null) {
        UploadTask uploadTask = _storage.ref().child('profile_images/$userId').putFile(profileImage);
        TaskSnapshot taskSnapshot = await uploadTask;
        profileImageUrl = await taskSnapshot.ref.getDownloadURL();
      }

      await _firestore.collection('users').doc(userId).update({
        'username': username,
        'email': email,
        'phoneNumber': phoneNumber,
        if (profileImageUrl != null) 'profileImage': profileImageUrl,
      });

      _logger.i("Profile updated successfully for userId: $userId");
    } catch (e) {
      _logger.e("Failed to update profile for userId: $userId", e);
      rethrow; // Optionally, rethrow the error to handle it further up the call stack
    }
  }
}
