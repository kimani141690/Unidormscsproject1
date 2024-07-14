import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../colors.dart';
import 'booking_summary_screen.dart';
import 'home_screen.dart';
import 'notice_screen.dart';
import 'bottom_navigation.dart'; // Import the BottomNavigation class

class DatesScreen extends StatefulWidget {
  final DocumentSnapshot roomData;

  DatesScreen({required this.roomData});

  @override
  _DatesScreenState createState() => _DatesScreenState();
}

class _DatesScreenState extends State<DatesScreen> {
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  int _currentIndex = 1;

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      if (_selectedStartDate == null || (_selectedStartDate != null && _selectedEndDate != null)) {
        _selectedStartDate = selectedDay;
        _selectedEndDate = null;
      } else if (selectedDay.isBefore(_selectedStartDate!)) {
        _selectedStartDate = selectedDay;
      } else {
        _selectedEndDate = selectedDay;
      }
    });

    // Calculate total rent and redirect to summary
    if (_selectedStartDate != null && _selectedEndDate != null) {
      _calculateAndRedirectToSummary();
    }
  }

  void _calculateAndRedirectToSummary() {
    int totalDays = _selectedEndDate!.difference(_selectedStartDate!).inDays + 1;
    double totalRent = (totalDays / 30) * widget.roomData['rentPerMonth'];

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BookingSummaryScreen(
          roomData: widget.roomData,
          startDate: _selectedStartDate!,
          endDate: _selectedEndDate!,
          totalRent: totalRent,
          totalDays: totalDays,
        ),
      ),
    );
  }

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
      if (index == 0) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => NoticeScreen()));
      } else if (index == 1) {
        // Stay on the DatesScreen
      } else if (index == 2) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomeScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        title: Text('Choose your stay Period', style: TextStyle(color: AppColors.textBlack)),
        centerTitle: true,

        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textBlack),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2021, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _selectedStartDate ?? DateTime.now(),
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              if (_selectedStartDate != null && _selectedEndDate != null) {
                return day.isAfter(_selectedStartDate!.subtract(Duration(days: 1))) &&
                    day.isBefore(_selectedEndDate!.add(Duration(days: 1)));
              } else if (_selectedStartDate != null) {
                return isSameDay(day, _selectedStartDate);
              }
              return false;
            },
            onDaySelected: _onDaySelected,
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
          ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _selectedStartDate != null && _selectedEndDate != null ? () => _calculateAndRedirectToSummary() : null,
              child: Text('Proceed'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.backgroundColor,
                foregroundColor: AppColors.textBlack,
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ),
        ],
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
