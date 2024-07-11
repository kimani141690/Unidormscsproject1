import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GuestService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> requestGuestVisit(int roomId, String guestName, String guestPhone, DateTime visitDate, String purpose) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('guest_visits').add({
        'userId': user.uid,
        'roomId': roomId,
        'guestName': guestName,
        'guestPhone': guestPhone,
        'visitDate': visitDate,
        'purpose': purpose,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending',
      });

      await _sendNotification(user.uid, 'Guest Visit Request Sent', 'Your guest visit request for room $roomId has been sent.');
    }
  }

  Future<void> _sendNotification(String userId, String title, String message) async {
    await _firestore.collection('notifications').add({
      'userId': userId,
      'title': title,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    });
  }
}
