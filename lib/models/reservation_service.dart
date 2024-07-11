import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class ReservationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Uuid _uuid = Uuid();

  Future<DocumentSnapshot?> checkExistingReservationOrBooking() async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) return null;

    final userReservation = await _firestore
        .collection('reservations')
        .where('userId', isEqualTo: currentUser.uid)
        .get();

    if (userReservation.docs.isNotEmpty) {
      final reservation = userReservation.docs.first;
      if (reservation['status'] == 'reserved') {
        return reservation;
      }
    }
    return null;
  }

  Future<void> preBookRoom(Map<String, dynamic> roomData) async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) return;

    // Check if the user already has a reservation or booking
    DocumentSnapshot? existingReservation = await checkExistingReservationOrBooking();
    if (existingReservation != null) {
      throw Exception('You already have a reserved or booked room.');
    }

    // Proceed to reserve the room
    String reservationId = _uuid.v4();
    await _firestore.collection('reservations').doc(reservationId).set({
      'userId': currentUser.uid,
      'roomId': roomData['roomId'].toString(),
      'roomType': roomData['roomType'],
      'image': roomData['image'],
      'capacity': roomData['capacity'],
      'status': 'reserved',
      'timestamp': FieldValue.serverTimestamp(),
      'expiryTime': DateTime.now().add(Duration(minutes: 30)), // Change to 30 minutes
    });

    // Send notification to the user
    await _firestore.collection('notifications').add({
      'userId': currentUser.uid,
      'message': 'You have reserved room ${roomData['roomType']} no. ${roomData['roomId']}',
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false, // Ensure notification is initially unread
    });

    // Schedule cancellation of reservation after 30 minutes
    Future.delayed(Duration(minutes: 30), () async { // Change to 30 minutes
      final reservation = await _firestore.collection('reservations').doc(reservationId).get();

      if (reservation.exists && reservation.data()?['status'] == 'reserved') {
        await _firestore.collection('reservations').doc(reservationId).update({
          'status': 'cancelled',
        });

        await _firestore.collection('rooms').doc(roomData['roomId'].toString()).update({
          'availableCapacity': FieldValue.increment(1),
        });

        await _firestore.collection('notifications').add({
          'userId': currentUser.uid,
          'message': 'Your reservation for room ${roomData['roomType']} no. ${roomData['roomId']} has been cancelled due to time expiry.',
          'timestamp': FieldValue.serverTimestamp(),
          'isRead': false, // Ensure notification is initially unread
        });
      }
    });
  }

  Future<void> cancelReservation(String reservationId, Map<String, dynamic> roomData) async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) return;

    await _firestore.collection('reservations').doc(reservationId).update({
      'status': 'cancelled',
    });

    await _firestore.collection('rooms').doc(roomData['roomId'].toString()).update({
      'availableCapacity': FieldValue.increment(1),
    });

    await _firestore.collection('notifications').add({
      'userId': currentUser.uid,
      'message': 'Your reservation for room ${roomData['roomType']} no. ${roomData['roomId']} has been cancelled.',
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false, // Ensure notification is initially unread
    });
  }
}
