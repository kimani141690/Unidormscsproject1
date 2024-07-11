import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
// import 'mpesa_service.dart'; // Commented out for now



class BookingService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> bookRoom({
    required String userId,
    required String roomId,
    required String phoneNumber,
    required double amount,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // Check if the room has available capacity
      DocumentSnapshot roomDoc = await FirebaseFirestore.instance.collection('rooms').doc(roomId).get();
      if (!roomDoc.exists) {
        throw Exception('Room document does not exist.');
      }

      Map<String, dynamic> roomData = roomDoc.data() as Map<String, dynamic>;
      int availableCapacity = roomData['availableCapacity'];
      String roomType = roomData['roomType']; // Get the room type
      if (availableCapacity <= 0) {
        throw Exception('No available capacity');
      }

      // Create a new booking document with a paid status
      DocumentReference bookingRef = await FirebaseFirestore.instance.collection('bookings').add({
        'userId': userId,
        'roomId': roomId,
        'phoneNumber': phoneNumber,
        'amount': amount,
        'startDate': startDate,
        'endDate': endDate,
        'status': 'paid', // Initial status set to paid
      });

      String bookingId = bookingRef.id;

      // Decrement the available capacity
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot freshSnap = await transaction.get(roomDoc.reference);
        int updatedCapacity = freshSnap['availableCapacity'] - 1;
        transaction.update(roomDoc.reference, {'availableCapacity': updatedCapacity});
      });

      // Send notification to the database
      await sendNotificationToDatabase(
          userId,
          "You have reserved room: $roomType\nBooking ID: $bookingId"
      );

    } catch (e) {
      print("Error during booking process: $e"); // Log detailed error
      rethrow;
    }
  }

  Future<void> sendNotificationToDatabase(String userId, String message) async {
    await FirebaseFirestore.instance.collection('notifications').add({
      'userId': userId,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false, // Default value for new notifications
    });
  }
}



// class BookingService {
//   final MpesaService _mpesaService = MpesaService();
//   final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
//
//   Future<void> bookRoom({
//     required String userId,
//     required String roomId,
//     required String phoneNumber,
//     required double amount,
//     required DateTime startDate,
//     required DateTime endDate,
//   }) async {
//     try {
//       // Check if the room has available capacity
//       DocumentSnapshot roomDoc = await FirebaseFirestore.instance.collection('rooms').doc(roomId).get();
//       if (!roomDoc.exists) {
//         throw Exception('Room document does not exist.');
//       }
//
//       Map<String, dynamic> roomData = roomDoc.data() as Map<String, dynamic>;
//       int availableCapacity = roomData['availableCapacity'];
//       if (availableCapacity <= 0) {
//         throw Exception('No available capacity');
//       }
//
//       // Create a new booking document with a pending status
//       DocumentReference bookingRef = await FirebaseFirestore.instance.collection('bookings').add({
//         'userId': userId,
//         'roomId': roomId,
//         'phoneNumber': phoneNumber,
//         'amount': amount,
//         'startDate': startDate,
//         'endDate': endDate,
//         'status': 'pending', // Initial status
//       });
//
//       String bookingId = bookingRef.id;
//
//       // Initiate Mpesa payment
//       await _mpesaService.initiatePayment(phoneNumber, amount, bookingId);
//
//       // Decrement the available capacity
//       await FirebaseFirestore.instance.runTransaction((transaction) async {
//         DocumentSnapshot freshSnap = await transaction.get(roomDoc.reference);
//         int updatedCapacity = freshSnap['availableCapacity'] - 1;
//         transaction.update(roomDoc.reference, {'availableCapacity': updatedCapacity});
//       });
//
//       // Send notification
//       await sendNotification(userId, "Booking Initiated", "Your booking payment is in process.");
//     } catch (e) {
//       print("Error during booking process: $e"); // Log detailed error
//       rethrow;
//     }
//   }
//
//   Future<void> sendNotification(String userId, String title, String body) async {
//     // Get the FCM token for the user
//     DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
//     String? fcmToken = userDoc.get('fcmToken');
//
//     if (fcmToken != null) {
//       final serverToken = 'YOUR_SERVER_KEY'; // Replace with your FCM server key
//       await http.post(
//         Uri.parse('https://fcm.googleapis.com/fcm/send'),
//         headers: <String, String>{
//           'Content-Type': 'application/json',
//           'Authorization': 'key=$serverToken',
//         },
//         body: jsonEncode(
//           <String, dynamic>{
//             'notification': <String, dynamic>{'title': title, 'body': body},
//             'priority': 'high',
//             'to': fcmToken,
//           },
//         ),
//       );
//     }
//   }
// }
