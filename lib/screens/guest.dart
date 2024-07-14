import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../colors.dart';
import '../models/guest_service.dart';
import 'bottom_navigation.dart';

class GuestVisitRequestScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;
  final Map<String, dynamic>? roomData;

  const GuestVisitRequestScreen({Key? key, this.userData, this.roomData}) : super(key: key);

  @override
  _GuestVisitRequestScreenState createState() => _GuestVisitRequestScreenState();
}

class _GuestVisitRequestScreenState extends State<GuestVisitRequestScreen> {
  final TextEditingController _guestNameController = TextEditingController();
  final TextEditingController _guestPhoneController = TextEditingController();
  final TextEditingController _purposeController = TextEditingController();
  DateTime? _visitDate;
  final GuestService _guestService = GuestService();
  bool isLoading = true;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = false; // No need to load data as it's passed from HomeScreen
    });
  }

  void _requestGuestVisit() async {
    if (_guestNameController.text.isNotEmpty &&
        _guestPhoneController.text.isNotEmpty &&
        _visitDate != null &&
        _purposeController.text.isNotEmpty) {
      await _guestService.requestGuestVisit(
        widget.roomData!['roomId'],
        _guestNameController.text,
        _guestPhoneController.text,
        _visitDate!,
        _purposeController.text,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Guest visit request sent successfully'), duration: Duration(seconds: 2)),
      );
      _guestNameController.clear();
      _guestPhoneController.clear();
      _purposeController.clear();
      setState(() {
        _visitDate = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter all required information'), duration: Duration(seconds: 2)),
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _visitDate) {
      setState(() {
        _visitDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        title: Text('Guest Visit Request', style: TextStyle(color: AppColors.textBlack)),
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
            Image.asset(
              'assets/images/guest2.jpeg',
              width: double.infinity,
              height: 150, // Adjusted height to fit the content better
              fit: BoxFit.cover,
            ),
            SizedBox(height: 20),
            TextField(
              controller: TextEditingController(text: widget.roomData?['roomNumber']?.toString() ?? 'No room data available'),
              decoration: InputDecoration(
                labelText: 'Room Number',
              ),
              style: TextStyle(color: AppColors.textBlack),
              readOnly: true,
            ),
            SizedBox(height: 16),
            TextField(
              controller: TextEditingController(text: widget.userData?['username'] ?? 'No occupant data available'),
              decoration: InputDecoration(
                labelText: 'Occupant',
              ),
              style: TextStyle(color: AppColors.textBlack),
              readOnly: true,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _guestNameController,
              decoration: InputDecoration(
                labelText: 'Guest Name',
              ),
              style: TextStyle(color: AppColors.textBlack),
              maxLines: 1,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _guestPhoneController,
              decoration: InputDecoration(
                labelText: 'Guest Phone Number',
              ),
              style: TextStyle(color: AppColors.textBlack),
              maxLines: 1,
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 16),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: AbsorbPointer(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Date of Visit',
                    suffixIcon: Icon(Icons.calendar_today, color: AppColors.textBlack),
                  ),
                  style: TextStyle(color: AppColors.textBlack),
                  controller: TextEditingController(
                    text: _visitDate == null ? '' : DateFormat('yyyy-MM-dd').format(_visitDate!),
                  ),
                  readOnly: true,
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _purposeController,
              decoration: InputDecoration(
                labelText: 'Purpose of Visit',
              ),
              style: TextStyle(color: AppColors.textBlack),
              maxLines: 1,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _requestGuestVisit,
              child: Text('Request Guest Visit', style: TextStyle(color: AppColors.textBlack)),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                backgroundColor: AppColors.backgroundColor,
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
