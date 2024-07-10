import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:unidorms/colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:unidorms/screens/reservation_screen.dart';
import '../models/homescreen_service.dart';
import 'display_guest.dart';
import 'display_maintenance.dart';
import 'login_screen.dart';
import 'bottom_navigation.dart';
import 'profile_screen.dart';
import 'notice_screen.dart';
import 'guest.dart';
import 'display_reviews.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;

  HomeScreen({this.userData});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomeScreen> {
  final HomeScreenService _homeScreenService = HomeScreenService();
  int _currentIndex = 0;
  User? user;
  Map<String, dynamic>? userData;
  Map<String, dynamic>? roomData;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    if (widget.userData != null) {
      userData = widget.userData;
    } else {
      _loadUserData();
    }
  }

  Future<void> _loadUserData() async {
    userData = await _homeScreenService.loadUserData();
    setState(() {});
    _loadRoomData(); // Load room data after loading user data
  }

  Future<void> _loadRoomData() async {
    roomData = await _homeScreenService.loadRoomData();
    setState(() {});
  }

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
      if (index == 1) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomeScreen(userData: userData)));
      } else if (index == 0) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => NoticeScreen()));
      } else if (index == 2) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => ProfileScreen(userData: userData, onProfileUpdated: (updatedData) {
          setState(() {
            userData = updatedData;
          });
        })));
      }
    });
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  void _handleCheckInCheckOut() async {
    if (roomData != null && roomData!['bookingId'] != null) {
      String newStatus = roomData!['status'] == 'checkedin' ? 'checkedout' : 'checkedin';
      await _homeScreenService.updateBookingStatus(roomData!['bookingId'], newStatus);
      _loadRoomData(); // Refresh room data after update

      // Show Snackbar
      String message = newStatus == 'checkedin' ? 'Checked in successfully' : 'Checked out successfully';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showBookingRequiredSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('You must have an existing booking to access this service.'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _handleServiceCardTap(Widget destination) {
    if (roomData != null) {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => destination));
    } else {
      _showBookingRequiredSnackbar();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: userData != null && userData!['profileImage'] != null
                  ? NetworkImage(userData!['profileImage'])
                  : AssetImage('assets/images/userAvatar.jpg') as ImageProvider,
            ),
            SizedBox(width: 10),
            Text(
              'Welcome ${userData?['username'] ?? 'User'}',
              style: TextStyle(
                fontSize: 14.0,
                color: AppColors.textBlack,
              ),
            ),
            Spacer(),
            IconButton(
              icon: Icon(Icons.power_settings_new),
              onPressed: _logout,
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // CachedNetworkImage(
            //   imageUrl: 'https://firebasestorage.googleapis.com/v0/b/unidormz-app.appspot.com/o/profile_images%2Fui_images%2Fhomepage.jpg?alt=media&token=5295feeb-c1ae-49cb-99be-ebb402c06950',
            //   placeholder: (context, url) => CircularProgressIndicator(),
            //   errorWidget: (context, url, error) => Icon(Icons.error),
            //   width: double.infinity,
            //   height: 200,
            //   fit: BoxFit.cover,
            // ),
            Image.asset(
              'assets/images/homepage.jpg',
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 20),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: ListTile(
                title: Text('My Room'),
                subtitle: roomData != null
                    ? Text('${roomData!['roomType']} Room\nRoom No. ${roomData!['roomNumber']}\nStatus: ${roomData!['status']}')
                    : Text('No room data available.\nYou do not have any room booked.'),
                trailing: roomData != null
                    ? ElevatedButton(
                  onPressed: _handleCheckInCheckOut,
                  child: Text(roomData!['status'] == 'checkedin' ? 'Check Out' : 'Check In'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: AppColors.textBlack,
                    backgroundColor: AppColors.backgroundColor,
                    minimumSize: Size(100, 40), // Adjust the button size
                  ),
                )
                    : null,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Services',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(), // Prevents GridView from scrolling
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: [
                ServiceCard(
                  imagePath: 'assets/images/catalogue.png',
                  label: 'Catalogue',
                  onTap: () => Navigator.pushNamed(context, '/catalogue'),
                ),
                ServiceCard(
                  imagePath: 'assets/images/reservations.png',
                  label: 'Reservations',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ReservationsScreen(),
                    ),
                  ),
                ),
                ServiceCard(
                  imagePath: 'assets/images/profile.png',
                  label: 'Profile',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen(
                        userData: userData,
                        onProfileUpdated: (updatedData) {
                          setState(() {
                            userData = updatedData;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                ServiceCard(
                  imagePath: 'assets/images/maintenance.png',
                  label: 'Maintenance',
                  onTap: () => _handleServiceCardTap(MaintenanceRequestsListScreen(
                    userData: userData,
                    roomData: roomData,
                  )),
                ),
                ServiceCard(
                  imagePath: 'assets/images/guest.png',
                  label: 'Guest',
                  onTap: () => _handleServiceCardTap(GuestRequestsListScreen(
                    roomData: roomData,
                    userData: userData,
                  )),
                ),
                ServiceCard(
                  imagePath: 'assets/images/reviews.png',
                  label: 'Reviews',
                  onTap: () => _handleServiceCardTap(ReviewScreen()),
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

class ServiceCard extends StatelessWidget {
  final String imagePath;
  final String label;
  final VoidCallback? onTap;

  ServiceCard({required this.imagePath, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Color(0xFF8DBAC4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                imagePath,
                height: 40,
                width: 40,
              ),
              SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(color: Colors.black),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
