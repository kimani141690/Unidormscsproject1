import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../colors.dart';
import 'bottom_navigation.dart';
import 'catalogue_screen.dart';
import 'home_screen.dart';
import 'notice_screen.dart';
import '../models/booking_service.dart';
import 'package:firebase_auth/firebase_auth.dart';



class BookingSummaryScreen extends StatefulWidget {
  final DocumentSnapshot roomData;
  final DateTime startDate;
  final DateTime endDate;
  final double totalRent;
  final int totalDays;

  BookingSummaryScreen({
    required this.roomData,
    required this.startDate,
    required this.endDate,
    required this.totalRent,
    required this.totalDays,
  });

  @override
  _BookingSummaryScreenState createState() => _BookingSummaryScreenState();
}

class _BookingSummaryScreenState extends State<BookingSummaryScreen> {
  final TextEditingController _phoneNumberController = TextEditingController();
  final BookingService _bookingService = BookingService();
  int _currentIndex = 1;
  bool _isLoading = false;

  void _proceedToPayment() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Total Rent: Ksh ${widget.totalRent}'),
            TextField(
              controller: _phoneNumberController,
              decoration: InputDecoration(
                labelText: 'Enter your phone number',
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.backgroundColor,
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _processPayment();
            },
            child: Text('Pay'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.backgroundColor,
            ),
          ),
        ],
      ),
    );
  }

  void _processPayment() async {
    String phoneNumber = _phoneNumberController.text.trim();
    if (phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter your phone number.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Get the current user
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('No user logged in');
      }

      await _bookingService.bookRoom(
        userId: currentUser.uid,
        roomId: widget.roomData.id,
        phoneNumber: phoneNumber,
        amount: widget.totalRent,
        startDate: widget.startDate,
        endDate: widget.endDate,
      );

      setState(() {
        _isLoading = false;
      });

      _showSuccessPopup();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print("Error during payment process: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error processing payment. Please try again.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showSuccessPopup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Booking Successful'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 50),
            SizedBox(height: 10),
            Text('Your booking has been confirmed!'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomeScreen()));
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backlight,
        title: Text('Booking Summary', style: TextStyle(color: AppColors.textBlack)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textBlack),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CachedNetworkImage(
              imageUrl: widget.roomData['image'],
              placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => Icon(Icons.error),
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 10),
            Text('Room Type: ${widget.roomData['roomType']}', style: TextStyle(fontSize: 18)),
            Text('Stay Period: ${widget.startDate} to ${widget.endDate}', style: TextStyle(fontSize: 18)),
            Text('Total Days: ${widget.totalDays}', style: TextStyle(fontSize: 18)),
            Text('Total Rent: Ksh ${widget.totalRent}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 20), // Add some space before the buttons
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Booking process cancelled.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => CatalogueScreen()));
                    },
                    child: Text('Cancel'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      minimumSize: Size(150, 50),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _proceedToPayment,
                    child: Text('Proceed'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.backlight,
                      foregroundColor: AppColors.textBlack,
                      minimumSize: Size(150, 50),
                    ),
                  ),
                ],
              ),
            ),
            Spacer(), // Push content above to center the buttons vertically
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onTap,
        context: context,
        notificationCount: 3, // Example notification count, adjust as needed
      ),
    );
  }
}


// class BookingSummaryScreen extends StatefulWidget {
//   final DocumentSnapshot roomData;
//   final DateTime startDate;
//   final DateTime endDate;
//   final double totalRent;
//   final int totalDays;
//
//   BookingSummaryScreen({
//     required this.roomData,
//     required this.startDate,
//     required this.endDate,
//     required this.totalRent,
//     required this.totalDays,
//   });
//
//   @override
//   _BookingSummaryScreenState createState() => _BookingSummaryScreenState();
// }
//
// class _BookingSummaryScreenState extends State<BookingSummaryScreen> {
//   final TextEditingController _phoneNumberController = TextEditingController();
//   final BookingService _bookingService = BookingService();
//   int _currentIndex = 1;
//   bool _isLoading = false;
//
//   void _proceedToPayment() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Confirm Payment'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text('Total Rent: Ksh ${widget.totalRent}'),
//             TextField(
//               controller: _phoneNumberController,
//               decoration: InputDecoration(
//                 labelText: 'Enter your phone number',
//               ),
//               keyboardType: TextInputType.phone,
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: Text('Cancel'),
//             style: TextButton.styleFrom(
//               foregroundColor: AppColors.backgroundColor,
//             ),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop();
//               _processPayment();
//             },
//             child: Text('Pay'),
//             style: TextButton.styleFrom(
//               foregroundColor: AppColors.backgroundColor,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _processPayment() async {
//     String phoneNumber = _phoneNumberController.text.trim();
//     if (phoneNumber.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Please enter your phone number.'),
//           duration: Duration(seconds: 2),
//         ),
//       );
//       return;
//     }
//
//     setState(() {
//       _isLoading = true;
//     });
//
//     try {
//       // Get the current user
//       User? currentUser = FirebaseAuth.instance.currentUser;
//       if (currentUser == null) {
//         throw Exception('No user logged in');
//       }
//
//       await _bookingService.bookRoom(
//         userId: currentUser.uid,
//         roomId: widget.roomData.id,
//         phoneNumber: phoneNumber,
//         amount: widget.totalRent,
//         startDate: widget.startDate,
//         endDate: widget.endDate,
//       );
//
//       setState(() {
//         _isLoading = false;
//       });
//
//       _showSuccessPopup();
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//       });
//       print("Error during payment process: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error processing payment. Please try again.'),
//           duration: Duration(seconds: 2),
//         ),
//       );
//     }
//   }
//
//   void _showSuccessPopup() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Booking Successful'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(Icons.check_circle, color: Colors.green, size: 50),
//             SizedBox(height: 10),
//             Text('Your booking has been confirmed!'),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomeScreen()));
//             },
//             child: Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _onTap(int index) {
//     setState(() {
//       _currentIndex = index;
//       if (index == 0) {
//         Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => NoticeScreen()));
//       } else if (index == 2) {
//         Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomeScreen()));
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: AppColors.backlight,
//         title: Text('Booking Summary', style: TextStyle(color: AppColors.textBlack)),
//         centerTitle: true,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: AppColors.textBlack),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//       ),
//       body: _isLoading
//           ? Center(child: CircularProgressIndicator())
//           : Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             CachedNetworkImage(
//               imageUrl: widget.roomData['image'],
//               placeholder: (context, url) => CircularProgressIndicator(),
//               errorWidget: (context, url, error) => Icon(Icons.error),
//               width: double.infinity,
//               height: 200,
//               fit: BoxFit.cover,
//             ),
//             SizedBox(height: 10),
//             Text('Room Type: ${widget.roomData['roomType']}', style: TextStyle(fontSize: 18)),
//             Text('Stay Period: ${widget.startDate} to ${widget.endDate}', style: TextStyle(fontSize: 18)),
//             Text('Total Days: ${widget.totalDays}', style: TextStyle(fontSize: 18)),
//             Text('Total Rent: Ksh ${widget.totalRent}', style: TextStyle(fontSize: 18)),
//             Spacer(),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 ElevatedButton(
//                   onPressed: () {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(
//                         content: Text('Booking process cancelled.'),
//                         duration: Duration(seconds: 2),
//                       ),
//                     );
//                     Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => CatalogueScreen()));
//                   },
//                   child: Text('Cancel'),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.red,
//                     foregroundColor: Colors.white,
//                     minimumSize: Size(150, 50),
//                   ),
//                 ),
//                 ElevatedButton(
//                   onPressed: _proceedToPayment,
//                   child: Text('Proceed'),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.backlight,
//                     foregroundColor: AppColors.textBlack,
//                     minimumSize: Size(150, 50),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _currentIndex,
//         onTap: _onTap,
//         items: [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.notifications),
//             label: 'Notices',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.calendar_today),
//             label: 'Dates',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home),
//             label: 'Home',
//           ),
//         ],
//       ),
//     );
//   }
// }
// when the user clicks proceed a pop up appears that asks them to enter their mpesa phone number to intiate payment by clicking the pay button. i want us to edit the logic for a bit when user clicks pay. i want you to comment out the mpeasa payment i will look at it later by creating a new payment function that creates the booking and sets the payment status as paid.
// import 'dart:convert';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:http/http.dart' as http;
// import 'mpesa_service.dart';
//
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
