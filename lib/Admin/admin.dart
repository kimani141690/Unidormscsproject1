import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../colors.dart';
import '../screens/login_screen.dart';
import 'guest_approval.dart';
import 'maintenance_approval.dart';
import '../models/admin_service.dart';
import 'admin_bottom_navigation.dart';

class AdminPageScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;

  AdminPageScreen({this.userData});

  @override
  _AdminPageScreenState createState() => _AdminPageScreenState();
}

class _AdminPageScreenState extends State<AdminPageScreen> {
  final AdminService _adminService = AdminService();
  Map<String, dynamic>? userData;

  int totalRooms = 0;
  int occupiedRooms = 0;
  int bookedRooms = 0;
  int totalStudents = 0;
  int studentsInHostel = 0;
  int studentsOutsideHostel = 0;
  int totalReservations = 0;
  int activeReservations = 0;
  int cancelledReservations = 0;
  int guestRequests = 0;
  int approvedGuestRequests = 0;
  int rejectedGuestRequests = 0;
  int maintenanceRequests = 0;
  int resolvedMaintenanceRequests = 0;
  double totalRentCollected = 0.0;

  @override
  void initState() {
    super.initState();
    userData = widget.userData;
    _loadAdminData();
  }

  Future<void> _loadAdminData() async {
    totalRooms = await _adminService.getTotalRooms();
    occupiedRooms = await _adminService.getOccupiedRooms();
    bookedRooms = await _adminService.getBookedRooms();
    totalStudents = await _adminService.getTotalStudents();
    studentsInHostel = await _adminService.getStudentsInHostel();
    studentsOutsideHostel = await _adminService.getCheckedOutStudents();
    totalReservations = await _adminService.getTotalReservations();
    activeReservations = await _adminService.getActiveReservations();
    cancelledReservations = await _adminService.getCancelledReservations();
    guestRequests = await _adminService.getGuestRequests();
    approvedGuestRequests = await _adminService.getApprovedGuestRequests();
    rejectedGuestRequests = await _adminService.getRejectedGuestRequests();
    maintenanceRequests = await _adminService.getMaintenanceRequests();
    resolvedMaintenanceRequests = await _adminService.getResolvedMaintenanceRequests();
    totalRentCollected = await _adminService.getTotalRentCollected();
    setState(() {});
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF8DBAC4),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: userData != null && userData!['profileImage'] != null
                  ? NetworkImage(userData!['profileImage'])
                  : AssetImage('assets/images/admin_avatar.png') as ImageProvider,
            ),
            SizedBox(width: 10),
            Text(
              'Welcome ${userData?['username'] ?? 'Admin'}',
              textAlign: TextAlign.center,
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),

              // Rooms Stats Section
              Text(
                'Rooms Stats',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _buildStatCard('Total Rooms', totalRooms.toString())),
                  Expanded(child: _buildStatCard('Occupied', occupiedRooms.toString())),
                  Expanded(child: _buildStatCard('Booked', bookedRooms.toString())),
                ],
              ),
              SizedBox(height: 20),

              // Students Stats Section
              Text(
                'Students Stats',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _buildStatCard('Total Students', totalStudents.toString())),
                  Expanded(child: _buildStatCard('Checked In', studentsInHostel.toString())),
                  Expanded(child: _buildStatCard('Checked Out', studentsOutsideHostel.toString())),
                ],
              ),
              SizedBox(height: 20),

              // Reservations Stats Section
              Text(
                'Reservations Stats',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _buildStatCard('Total Reservations', totalReservations.toString())),
                  Expanded(child: _buildStatCard('Active Reservations', activeReservations.toString())),
                  Expanded(child: _buildStatCard('Cancelled Reservations', cancelledReservations.toString())),
                ],
              ),
              SizedBox(height: 20),

              // Guest Stats Section
              Text(
                'Guest Stats',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _buildStatCard('Guest Requests', guestRequests.toString())),
                  Expanded(child: _buildStatCard('Approved Guests', approvedGuestRequests.toString())),
                  Expanded(child: _buildStatCard('Rejected Guests', rejectedGuestRequests.toString())),
                ],
              ),
              SizedBox(height: 20),

              // Maintenance Stats Section
              Text(
                'Maintenance Stats',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _buildStatCard('Maintenance Requests', maintenanceRequests.toString())),
                  Expanded(child: _buildStatCard('Resolved Maintenance', resolvedMaintenanceRequests.toString())),
                  Expanded(child: _buildStatCard('Rent Collected', '\$${totalRentCollected.toStringAsFixed(2)}')),
                ],
              ),
              SizedBox(height: 30),

              // Services Section
              Text(
                'Services',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: _buildServiceButton(context, Icons.people, 'Visitors', GuestApprovalScreen())),
                  Expanded(child: _buildServiceButton(context, Icons.build, 'Maintenance', MaintenanceApprovalScreen())),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: 0,
        onItemTapped: (index) {},
      ),
    );
  }

  Widget _buildStatCard(String title, String count) {
    return Card(
      color: AppColors.backgroundColor,
      child: Container(
        width: 100,
        height: 80,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              count,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(fontSize: 14, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceButton(BuildContext context, IconData icon, String label, Widget destination) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0), // Add horizontal padding to add space between buttons
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => destination));
        },
        icon: Icon(icon, color: Colors.black), // Black icon color
        label: Text(label, style: TextStyle(color: Colors.black)), // Black text color
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.backgroundColor, // Background color
          minimumSize: Size(100, 40), // Reduced size to fit content
        ),
      ),
    );
  }
}
