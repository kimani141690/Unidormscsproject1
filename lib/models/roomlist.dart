import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> populateRooms() async {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> rooms = [
    {
      'roomType': 'Single Bed Deluxe Room',
      'capacity': 1,
      'availableCapacity': 1,
      'rentPerMonth': 2,
      'roomId': 1,
      'roomNumber': 'A01',  // Added roomNumber field
      'status': 'Available',
      'image': 'https://firebasestorage.googleapis.com/v0/b/unidormz-app.appspot.com/o/ui_images%2Fselfcontained.jpg?alt=media&token=9b7d0a90-df52-4d28-83c8-6aa0c088984f',
      'amenities': ['WiFi', 'Air Conditioning', 'Private Bathroom'],
      'costModel': 'Per person sharing'
    },
    {
      'roomType': 'Single Bed Deluxe Room',
      'capacity': 1,
      'availableCapacity': 1,
      'rentPerMonth': 4,
      'roomId': 6,
      'roomNumber': 'A02',
      'status': 'Available',
      'image': 'https://firebasestorage.googleapis.com/v0/b/unidormz-app.appspot.com/o/ui_images%2F1bed_4.jpg?alt=media&token=78856d39-6f68-4231-9509-43d3b6a6b065',
      'amenities': ['WiFi', 'Air Conditioning', 'Shared Bathroom'],
      'costModel': 'Per person sharing'
    },
    {
      'roomType': '2-Bed Room Deluxe Room',
      'capacity': 2,
      'availableCapacity': 2,
      'rentPerMonth': 4,
      'roomId': 2,
      'roomNumber': 'B02',  // Added roomNumber field
      'status': 'Available',
      'image': 'https://firebasestorage.googleapis.com/v0/b/unidormz-app.appspot.com/o/ui_images%2F2bed.jpg?alt=media&token=2ab2dcd5-720a-41c0-91e4-300dd73d3c8e',
      'amenities': ['WiFi', 'Air Conditioning', 'Shared Bathroom'],
      'costModel': 'Per person sharing'
    },
    {
      'roomType': '2-Bed Room Deluxe Room',
      'capacity': 2,
      'availableCapacity': 2,
      'rentPerMonth': 4,
      'roomId': 4, // Ensure unique roomId
      'roomNumber': 'B03',
      'status': 'Available',
      'image': 'https://firebasestorage.googleapis.com/v0/b/unidormz-app.appspot.com/o/ui_images%2F2bed_3.jpeg?alt=media&token=6465de63-911a-4b71-a752-3822dcff06c8',
      'amenities': ['WiFi', 'Air Conditioning', 'Shared Bathroom'],
      'costModel': 'Per person sharing'
    },
    {
      'roomType': '4-Bed Deluxe Room',
      'capacity': 4,
      'availableCapacity': 4,
      'rentPerMonth': 6,
      'roomId': 3,
      'roomNumber': 'C03',  // Added roomNumber field
      'status': 'Available',
      'image':'https://firebasestorage.googleapis.com/v0/b/unidormz-app.appspot.com/o/ui_images%2F4bed.jpg?alt=media&token=4b23ad25-c047-414c-91b3-b22a39301e29',
      'amenities': ['WiFi', 'Air Conditioning', 'Shared Bathroom'],
      'costModel': 'Per person sharing'
    },

    {
      'roomType': '4-Bed Deluxe Room',
      'capacity': 4,
      'availableCapacity': 4,
      'rentPerMonth': 4,
      'roomId': 5,
      'roomNumber': 'B05',
      'status': 'Available',
      'image':'https://firebasestorage.googleapis.com/v0/b/unidormz-app.appspot.com/o/ui_images%2F4bed_3.jpeg?alt=media&token=700b2ce2-4c98-474e-aa51-d78f8d4abfc0',
      'amenities': ['WiFi', 'Air Conditioning', 'Shared Bathroom'],
      'costModel': 'Per person sharing'
    },

    // Add more rooms as needed
  ];

  // Check if the rooms collection already has documents
  QuerySnapshot snapshot = await _firestore.collection('rooms').limit(1).get();
  if (snapshot.docs.isNotEmpty) {
    print('Rooms collection already exists. Skipping population.');
    return; // Exit if rooms collection already has documents
  }

  // Populate rooms collection
  for (var room in rooms) {
    await _firestore.collection('rooms').add(room);
  }

  print('Rooms collection populated successfully.');
}
