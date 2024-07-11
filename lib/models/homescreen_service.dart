import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreenService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      return userDoc.data() as Map<String, dynamic>?;
    }
    return null;
  }

  Future<Map<String, dynamic>?> loadRoomData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      QuerySnapshot bookingSnapshot = await _firestore
          .collection('bookings')
          .where('userId', isEqualTo: user.uid)
          .get();

      if (bookingSnapshot.docs.isNotEmpty) {
        DocumentSnapshot bookingDoc = bookingSnapshot.docs.first;
        String roomId = bookingDoc['roomId'];
        String status = bookingDoc['status'];

        DocumentSnapshot roomDoc = await _firestore.collection('rooms').doc(roomId).get();
        if (roomDoc.exists) {
          Map<String, dynamic> roomData = roomDoc.data() as Map<String, dynamic>;
          roomData['status'] = status; // Add status from booking to room data
          roomData['bookingId'] = bookingDoc.id;
          return roomData;
        }
      }
    }
    return null;
  }

  Future<void> updateBookingStatus(String bookingId, String newStatus) async {
    await _firestore.collection('bookings').doc(bookingId).update({
      'status': newStatus,
    });
  }
}
