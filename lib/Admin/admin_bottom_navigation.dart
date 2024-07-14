import 'package:flutter/material.dart';
import 'package:unidorms/Admin/admin.dart';
import 'package:unidorms/Admin/guest_approval.dart';
import 'package:unidorms/Admin/maintenance_approval.dart';
import '../colors.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  CustomBottomNavBar({
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: AppColors.backgroundColor, // Set background color
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.build, color: Colors.black), // Black icon color
          label: 'Maintenance',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.home, color: Colors.black), // Black icon color
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people, color: Colors.black), // Black icon color
          label: 'Guests',
        ),
      ],
      currentIndex: selectedIndex,
      selectedItemColor: AppColors.textBlack,
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MaintenanceApprovalScreen()),
            );
            break;
          case 1:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => AdminPageScreen(userData: null)),
            );
            break;
          case 2:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => GuestApprovalScreen()),
            );
            break;
        }
      },
    );
  }
}
