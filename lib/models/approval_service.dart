import 'package:cloud_firestore/cloud_firestore.dart';

class ApprovalService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchGuestRequests() async {
    QuerySnapshot guestRequestsSnapshot = await _firestore.collection('guest_visits').get();
    List<Map<String, dynamic>> guestRequests = guestRequestsSnapshot.docs.map((doc) => {
      'id': doc.id,
      ...doc.data() as Map<String, dynamic>
    }).toList();

    for (var request in guestRequests) {
      String userId = request['userId'];
      request['username'] = await _getUsername(userId);
      request['roomNumber'] = await _getRoomNumber(userId);
    }

    return guestRequests;
  }

  Future<String> _getUsername(String userId) async {
    DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
    return userDoc.exists ? userDoc['username'] ?? 'Unknown' : 'Unknown';
  }

  Future<String> _getRoomNumber(String userId) async {
    QuerySnapshot bookingSnapshot = await _firestore.collection('bookings').where('userId', isEqualTo: userId).get();
    if (bookingSnapshot.docs.isNotEmpty) {
      String roomId = bookingSnapshot.docs.first['roomId'];
      DocumentSnapshot roomSnapshot = await _firestore.collection('rooms').doc(roomId).get();
      return roomSnapshot.exists ? roomSnapshot['roomNumber'] ?? 'Unknown' : 'Unknown';
    }
    return 'Unknown';
  }

  Future<List<Map<String, dynamic>>> fetchMaintenanceRequests() async {
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

    return maintenanceRequests;
  }

  Future<String> _getRoomNumberFromRequest(String roomId) async {
    DocumentSnapshot roomDoc = await _firestore.collection('rooms').doc(roomId).get();
    return roomDoc.exists ? roomDoc['roomNumber'] ?? 'Unknown' : 'Unknown';
  }

  Future<void> updateMaintenanceStatus(String requestId, String newStatus, String adminComment, String userId, String username, String issue) async {
    await _firestore.collection('maintenance_tickets').doc(requestId).update({
      'status': newStatus,
    });

    String notificationMessage = "Hello, your maintenance request for issue '$issue' has been $newStatus.\n$adminComment";

    await sendNotification(userId, notificationMessage);
  }

  Future<void> updateGuestRequestStatus(String requestId, String newStatus, String message, String userId, String guestName) async {
    await _firestore.collection('guest_visits').doc(requestId).update({
      'status': newStatus,
    });

    String notificationMessage = "Your guest request visit for $guestName was $newStatus.\n$message";

    await sendNotification(userId, notificationMessage);
  }

  Future<void> sendNotification(String userId, String message) async {
    await _firestore.collection('notifications').add({
      'userId': userId,
      'message': message,
      'isRead': false,
      'timestamp': Timestamp.now(),
    });
  }

  Future<Map<String, dynamic>?> fetchUserData(String userId) async {
    DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
    return userDoc.data() as Map<String, dynamic>?;
  }
}
