import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../colors.dart';
import '../models/reservation_service.dart';
import 'bottom_navigation.dart';
import 'home_screen.dart';
import 'notice_screen.dart';

class ReservationsScreen extends StatefulWidget {
  @override
  _ReservationsScreenState createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> {
  User? currentUser;
  late Future<List<DocumentSnapshot>> reservationsFuture;
  final ReservationService _reservationService = ReservationService();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
    reservationsFuture = _fetchReservations();
  }

  Future<List<DocumentSnapshot>> _fetchReservations() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('reservations')
        .where('userId', isEqualTo: currentUser?.uid)
        .get();
    return querySnapshot.docs;
  }

  Future<void> _cancelReservation(String reservationId, Map<String, dynamic> roomData) async {
    setState(() {
      // Show loading indicator
    });

    try {
      await _reservationService.cancelReservation(reservationId, roomData);

      setState(() {
        reservationsFuture = _fetchReservations(); // Refresh the list
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reservation cancelled successfully.'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print(e.toString()); // Log the error for debugging
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to cancel the reservation. Please try again.'),
          duration: Duration(seconds: 2),
        ),
      );
    } finally {
      setState(() {
        // Hide loading indicator
      });
    }
  }

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
      if (index == 1) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomeScreen()));
      } else if (index == 0) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => NoticeScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        title: Text('Reservations', style: TextStyle(color: AppColors.textBlack)),
        centerTitle: true,

        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textBlack),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Reservations',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            FutureBuilder<List<DocumentSnapshot>>(
              future: reservationsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error fetching reservations'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No reservations available at the moment.'));
                } else {
                  return Column(
                    children: snapshot.data!.where((reservationDoc) {
                      // Filter out cancelled reservations
                      Map<String, dynamic> reservationData =
                      reservationDoc.data() as Map<String, dynamic>;
                      return reservationData['status'] != 'cancelled';
                    }).map((reservationDoc) {
                      Map<String, dynamic> reservationData =
                      reservationDoc.data() as Map<String, dynamic>;

                      return Column(
                        children: [
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    reservationData['roomType'],
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  CachedNetworkImage(
                                    imageUrl: reservationData['image'],
                                    placeholder: (context, url) => CircularProgressIndicator(),
                                    errorWidget: (context, url, error) => Icon(Icons.error),
                                    width: double.infinity,
                                    height: 150,
                                    fit: BoxFit.cover,
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Capacity: ${reservationData['capacity']}',
                                        style: TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'Status: ${reservationData['status']}',
                                        style: TextStyle(
                                          color: reservationData['status'] == 'reserved'
                                              ? Colors.orange
                                              : Colors.green,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () {
                              _cancelReservation(reservationDoc.id, reservationData);
                            },
                            child: Text('Cancel Reservation'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.buttonColor, // Set button color
                              foregroundColor: AppColors.textWhite, // Set text color
                            ),
                          ),
                          SizedBox(height: 20),
                        ],
                      );
                    }).toList(),
                  );
                }
              },
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
