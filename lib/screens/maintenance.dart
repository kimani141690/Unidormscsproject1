import 'package:flutter/material.dart';
import '../colors.dart';
import 'bottom_navigation.dart';
import '../models/maintenance_service.dart';

class MaintenanceScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;
  final Map<String, dynamic>? roomData;

  const MaintenanceScreen({Key? key, this.userData, this.roomData}) : super(key: key);

  @override
  _MaintenanceScreenState createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  final TextEditingController _issueController1 = TextEditingController();
  final TextEditingController _issueController2 = TextEditingController();
  final TextEditingController _issueController3 = TextEditingController();
  final MaintenanceService _maintenanceService = MaintenanceService();
  bool isLoading = true;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = false; // No need to load data as it's passed from HomeScreen
    });
  }

  void _raiseTicket() async {
    if (_issueController1.text.isNotEmpty || _issueController2.text.isNotEmpty || _issueController3.text.isNotEmpty) {
      try {
        // Print the contents of roomData and userData for debugging


        final String? roomId = widget.roomData?['roomId']?.toString();

               await _maintenanceService.raiseTicket(
          roomId!,
          [
            _issueController1.text,
            _issueController2.text,
            _issueController3.text,
          ],
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Maintenance ticket raised successfully'), duration: Duration(seconds: 2)),
        );
        _issueController1.clear();
        _issueController2.clear();
        _issueController3.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error raising ticket: ${e.toString()}'), duration: Duration(seconds: 2)),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter at least one issue description'), duration: Duration(seconds: 2)),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        title: Text('Maintenance', style: TextStyle(color: AppColors.textBlack)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textBlack),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Image.asset('assets/images/repair2.jpeg', height: 200),
            SizedBox(height: 16),
            TextField(
              controller: TextEditingController(text: widget.roomData?['roomNumber']?.toString() ?? 'No room data available'),
              decoration: InputDecoration(
                labelText: 'Room Number',
              ),
              readOnly: true,
            ),
            SizedBox(height: 16),
            TextField(
              controller: TextEditingController(text: widget.userData?['username'] ?? 'No occupant data available'),
              decoration: InputDecoration(
                labelText: 'Occupant',
              ),
              readOnly: true,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _issueController1,
              decoration: InputDecoration(
                labelText: 'Issue 1',
              ),
              maxLines: 1,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _issueController2,
              decoration: InputDecoration(
                labelText: 'Issue 2',
              ),
              maxLines: 1,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _issueController3,
              decoration: InputDecoration(
                labelText: 'Issue 3',
              ),
              maxLines: 1,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _raiseTicket,
              child: Text('Raise Ticket',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),

            ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.backgroundColor, // Button color
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: 1,
        onTap: _onTap,
        context: context,
      ),
    );
  }
}
