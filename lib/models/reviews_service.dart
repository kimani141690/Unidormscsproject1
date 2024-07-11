import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> submitReview(String review, int rating) async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('No user is currently logged in.');
    }

    await _firestore.collection('reviews').add({
      'review': review,
      'rating': rating,
      'timestamp': Timestamp.now(),
      'userId': currentUser.uid,
    });
  }

Future<List<Map<String, dynamic>>> fetchReviews() async {
  QuerySnapshot snapshot = await _firestore.collection('reviews').get();
  return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
}

Future<Map<String, dynamic>> fetchUserData(String userId) async {
  DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
  return userDoc.data() as Map<String, dynamic>;
}
}