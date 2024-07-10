import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> updateRoomStatus() async {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  QuerySnapshot roomsSnapshot = await _firestore.collection('rooms').get();

  for (QueryDocumentSnapshot doc in roomsSnapshot.docs) {
    Map<String, dynamic> roomData = doc.data() as Map<String, dynamic>;
    if (roomData['availableCapacity'] == 0) {
      await doc.reference.update({'status': 'unavailable'});
      print('Updated room ${doc.id} to unavailable');
    }
  }

  print('Room status update completed.');
}
