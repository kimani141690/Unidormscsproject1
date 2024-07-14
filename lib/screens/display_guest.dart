import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'bottom_navigation.dart'; // Make sure the path is correct
import '../colors.dart'; // Make sure the path is correct
import 'guest.dart'; // Make sure the path is correct
import '../models/guest_service.dart'; // Ensure the path is correct

class GuestRequestsListScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;
  final Map<String, dynamic>? roomData;

  const GuestRequestsListScreen({Key? key, this.userData, this.roomData}) : super(key: key);

  @override
  _GuestRequestsListScreenState createState() => _GuestRequestsListScreenState();
}

class _GuestRequestsListScreenState extends State<GuestRequestsListScreen> {
  final GuestService _guestService = GuestService();
  List<Map<String, dynamic>> guestRequests = [];
  int _currentIndex = 0;
  bool isLoading = true;
  User? currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
    _fetchGuestRequests();
  }

  Future<void> _fetchGuestRequests() async {
    if (currentUser != null) {
      try {
        List<Map<String, dynamic>> fetchedRequests = await _guestService.fetchGuestRequestsByUserId(currentUser!.uid);
        setState(() {
          guestRequests = fetchedRequests;
          isLoading = false;
        });
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching guest requests: $e')),
        );
      }
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User not logged in')),
      );
    }
  }

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
      if (index == 0) {
        Navigator.of(context).pushReplacementNamed('/notice');
      } else if (index == 1) {
        Navigator.of(context).pushReplacementNamed('/home');
      } else if (index == 2) {
        Navigator.of(context).pushReplacementNamed('/profile');
      }
    });
  }

  void _showDetailsDialog(BuildContext context, String guestName, String guestPhone, String purpose, String status, DateTime visitDate) {
    Color statusColor;
    if (status == 'pending') {
      statusColor = Colors.orange;
    } else if (status == 'approved') {
      statusColor = Colors.green;
    } else if (status == 'rejected') {
      statusColor = Colors.red;
    } else {
      statusColor = Colors.black; // default color
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Guest Visit Details'),
          content: SingleChildScrollView(
            child: Table(
              columnWidths: {
                0: IntrinsicColumnWidth(),
                1: FlexColumnWidth(),
              },
              children: [
                TableRow(children: [
                  Text('Guest Name:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(guestName),
                ]),
                TableRow(children: [
                  SizedBox(height: 16), // Add some spacing between rows
                  SizedBox(height: 16),
                ]),
                TableRow(children: [
                  Text('Guest Phone:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(guestPhone),
                ]),
                TableRow(children: [
                  SizedBox(height: 16), // Add some spacing between rows
                  SizedBox(height: 16),
                ]),
                TableRow(children: [
                  Text('Purpose:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(purpose),
                ]),
                TableRow(children: [
                  SizedBox(height: 16), // Add some spacing between rows
                  SizedBox(height: 16),
                ]),
                TableRow(children: [
                  Text('Status:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(status, style: TextStyle(color: statusColor)),
                ]),
                TableRow(children: [
                  SizedBox(height: 16), // Add some spacing between rows
                  SizedBox(height: 16),
                ]),
                TableRow(children: [
                  Text('Visit Date:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(visitDate.toString()),
                ]),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        title: Text('Guest Visit Requests', style: TextStyle(color: AppColors.textBlack)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textBlack),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GuestVisitRequestScreen(
                        userData: widget.userData,
                        roomData: widget.roomData,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.backgroundColor,
                ),
                child: Text('New Request', style: TextStyle(color: AppColors.textBlack)),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
              itemCount: guestRequests.length,
              itemBuilder: (context, index) {
                final request = guestRequests[index];
                final guestName = request['guestName'];
                final guestPhone = request['guestPhone'];
                final purpose = request['purpose'];
                final status = request['status'];
                final visitDate = request['visitDate'].toDate();

                Color statusColor;
                if (status == 'pending') {
                  statusColor = Colors.orange;
                } else if (status == 'approved') {
                  statusColor = Colors.green;
                } else if (status == 'rejected') {
                  statusColor = Colors.red;
                } else {
                  statusColor = Colors.black; // default color
                }

                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text('Guest: $guestName'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Purpose: $purpose'),
                        Text(
                          'Status: $status',
                          style: TextStyle(color: statusColor),
                        ),
                        Text('Visit Date: $visitDate'),
                      ],
                    ),
                    onTap: () {
                      _showDetailsDialog(context, guestName, guestPhone, purpose, status, visitDate);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onTap,
        context: context,
        notificationCount: 0, // Update this if you have a notification count
      ),
    );
  }
}
