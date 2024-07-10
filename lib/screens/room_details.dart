import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../colors.dart';
import '../models/reservation_service.dart';
import 'home_screen.dart';
import 'notice_screen.dart';
import 'reservation_screen.dart';
import 'dates_screen.dart'; // Import the DatesScreen
import 'bottom_navigation.dart';

class RoomDetailsScreen extends StatefulWidget {
  final DocumentSnapshot roomData;
  final bool isFromReservations;

  const RoomDetailsScreen({
    Key? key,
    required this.roomData,
    this.isFromReservations = false,
  }) : super(key: key);

  @override
  _RoomDetailsScreenState createState() => _RoomDetailsScreenState();
}

class _RoomDetailsScreenState extends State<RoomDetailsScreen> {
  late Map<String, dynamic> roomData;
  bool isLoading = false;
  DocumentSnapshot? existingReservation;
  int _currentIndex = 1;

  @override
  void initState() {
    super.initState();
    roomData = widget.roomData.data() as Map<String, dynamic>;
    roomData['roomId'] = widget.roomData.id; // Ensure roomId is set correctly
    _checkExistingReservation();
  }

  Future<void> _checkExistingReservation() async {
    // Check if there is an existing reservation (this logic should be handled in your ReservationService)
  }

  Future<void> _preBookRoom() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Check if the room has available capacity
      DocumentSnapshot roomDoc = await FirebaseFirestore.instance.collection('rooms').doc(roomData['roomId'].toString()).get();
      if (!roomDoc.exists) {
        throw Exception('Room document does not exist.');
      }

      Map<String, dynamic> roomDataMap = roomDoc.data() as Map<String, dynamic>;
      if (!roomDataMap.containsKey('availableCapacity')) {
        throw Exception('Field "availableCapacity" does not exist.');
      }

      int availableCapacity = roomDataMap['availableCapacity'];
      if (availableCapacity <= 0) {
        throw Exception('No available capacity');
      }

      // Check if the user already has an existing reservation or booking
      if (existingReservation != null && existingReservation!['status'] == 'reserved') {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You already have a reserved room.'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      // Proceed to reserve the room
      await ReservationService().preBookRoom(roomData);

      // Decrement the available capacity
      await FirebaseFirestore.instance.collection('rooms').doc(roomData['roomId'].toString()).update({
        'availableCapacity': FieldValue.increment(-1),
      });

      setState(() {
        roomData['status'] = 'reserved';
        isLoading = false;
      });

      // Notify the user with a pop-up message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Room reserved successfully.'),
          duration: Duration(seconds: 2),
        ),
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => ReservationsScreen()),
      );
    } catch (e) {
      print(e.toString()); // Log the error for debugging
      setState(() {
        isLoading = false;
      });
      if (e is FirebaseException) {
        String message = handleFirestoreError(e.code);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to reserve the room. Please try again.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  String handleFirestoreError(String errorCode) {
    switch (errorCode) {
      case 'already-exists':
        return 'This room is already reserved.';
      case 'out-of-range':
        return 'Invalid capacity update.';
      default:
        return 'An error occurred. Please try again.';
    }
  }

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
      if (index == 0) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => NoticeScreen()));
      } else if (index == 2) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomeScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print('isFromReservations: ${widget.isFromReservations}'); // Debug print
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        title: Text('Room Details', style: TextStyle(color: AppColors.textBlack)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textBlack),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${roomData['roomType']} ', // Use roomId here
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            CachedNetworkImage(
              imageUrl: roomData['image'],
              placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => Icon(Icons.error),
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 10),
            Card(
              color: AppColors.backgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Bed: Double Decker', style: TextStyle(fontSize: 16)),
                    Text('Occupants: ${roomData['capacity']}', style: TextStyle(fontSize: 16)),
                    Text('Amenities: ${roomData['amenities']}', style: TextStyle(fontSize: 16)),
                    Text('Price: Ksh ${roomData['rentPerMonth']}', style: TextStyle(fontSize: 16)),
                    Text('Cost Model: ${roomData['costModel']}', style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            if (!widget.isFromReservations)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _preBookRoom,
                    child: Text('Pre-Book'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.backlight,
                      foregroundColor: AppColors.textBlack,
                      minimumSize: Size(150, 50),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => DatesScreen(roomData: widget.roomData),
                        ),
                      );
                    },
                    child: Text('Book'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.backlight,
                      foregroundColor: AppColors.textBlack,
                      minimumSize: Size(150, 50),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onTap,
        context: context,
      ),
    );
  }
}
