import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

class MaintenanceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<Map<String, dynamic>>> fetchMaintenanceRequests() async {
    try {
      QuerySnapshot maintenanceRequestsSnapshot = await _firestore.collection('maintenance_tickets').get();
      List<Map<String, dynamic>> maintenanceRequests = [];

      for (var doc in maintenanceRequestsSnapshot.docs) {
        Map<String, dynamic> requestData = doc.data() as Map<String, dynamic>;
        String userId = requestData['userId'];
        String roomId = requestData['roomId'].toString();

        requestData['username'] = await _getUsername(userId);
        requestData['roomNumber'] = await _getRoomNumberFromRequest(roomId);

        maintenanceRequests.add({
          'id': doc.id,
          ...requestData,
        });
      }

      _logger.i('Fetched ${maintenanceRequests.length} maintenance requests');
      return maintenanceRequests;
    } catch (e) {
      _logger.e('Error fetching maintenance requests', e);
      rethrow;
    }
  }

  Future<String> _getUsername(String userId) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
      return userDoc.exists ? userDoc['username'] ?? 'Unknown' : 'Unknown';
    } catch (e) {
      _logger.e('Error fetching username for userId: $userId', e);
      return 'Unknown';
    }
  }

  Future<String> _getRoomNumberFromRequest(String roomId) async {
    try {
      DocumentSnapshot roomDoc = await _firestore.collection('rooms').doc(roomId).get();
      return roomDoc.exists ? roomDoc['roomNumber'] ?? 'Unknown' : 'Unknown';
    } catch (e) {
      _logger.e('Error fetching room number for roomId: $roomId', e);
      return 'Unknown';
    }
  }

  Future<void> updateMaintenanceStatus(String requestId, String newStatus, String adminComment, String userId, String username, String issue) async {
    try {
      await _firestore.collection('maintenance_tickets').doc(requestId).update({
        'status': newStatus,
      });

      String notificationMessage = "Hello, your maintenance request for issue '$issue' has been $newStatus.\n$adminComment";

      await sendNotification(userId, notificationMessage);
      _logger.i('Updated maintenance status for requestId: $requestId to $newStatus');
    } catch (e) {
      _logger.e('Error updating maintenance status for requestId: $requestId', e);
      rethrow;
    }
  }

  Future<void> sendNotification(String userId, String message) async {
    try {
      await _firestore.collection('notifications').add({
        'userId': userId,
        'message': message,
        'isRead': false,
        'timestamp': Timestamp.now(),
      });
      _logger.i('Sent notification to userId: $userId');
    } catch (e) {
      _logger.e('Error sending notification to userId: $userId', e);
      rethrow;
    }
  }



  Future<void> raiseTicket(String roomId, List<String> issues) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('maintenance_tickets').add({
          'roomId': roomId, // Ensure roomId is passed as a String
          'issues': issues,
          'status': 'pending',
          'timestamp': Timestamp.now(),
          'userId': user.uid,
        });
        await sendNotification(user.uid, 'Your Maintenance request for room $roomId has been sent.');

        _logger.i('Raised ticket for roomId: $roomId with issues: $issues');
      } else {
        _logger.e('Error raising ticket: No current user');
        throw Exception('No current user');
      }
    } catch (e) {
      _logger.e('Error raising ticket for roomId: $roomId', e);
      rethrow;
    }
  }


  Future<Map<String, dynamic>?> fetchUserData(String userId) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
      return userDoc.data() as Map<String, dynamic>?;
    } catch (e) {
      _logger.e('Error fetching user data for userId: $userId', e);
      return null;
    }
  }
}
