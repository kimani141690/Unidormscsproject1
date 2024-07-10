import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:unidorms/screens/display_guest.dart';
import 'package:unidorms/screens/display_maintenance.dart';
import 'package:unidorms/screens/display_reviews.dart';
import 'package:unidorms/screens/guest.dart';
import 'package:unidorms/screens/maintenance.dart';
import 'package:unidorms/screens/reservation_screen.dart';
import 'package:unidorms/screens/write_reviews.dart';
import 'models/auth_service.dart';
import 'models/update_rooms.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/notice_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/catalogue_screen.dart';
import 'admin/admin.dart';
import 'admin/guest_approval.dart';
import 'admin/maintenance_approval.dart';
import 'models/roomlist.dart';
import 'models/admin_setup.dart'; // Import the admin_setup.dart

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await adminSetup(); // Call the admin setup function
  await populateRooms();
  await updateRoomStatus();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UniDorms',
      debugShowCheckedModeBanner: false, // Remove the debug banner
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: SplashScreen(), // Set SplashScreen as the initial screen
      routes: {
        '/login': (context) => const LoginScreen(),
        '/registration': (context) => const RegistrationScreen(),
        '/home': (context) => HomeScreen(),
        '/notice': (context) => NoticeScreen(),
        '/profile': (context) => ProfileScreen(
          userData: {},
          onProfileUpdated: (updatedData) {},
        ),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/catalogue': (context) => CatalogueScreen(),
        '/reservation': (context) => ReservationsScreen(),
        '/maintenance': (context) => MaintenanceScreen(),
        '/maintenance-requests': (context) => MaintenanceRequestsListScreen(),
        '/guest': (context) => GuestVisitRequestScreen(),
        '/guest-requests': (context) => GuestRequestsListScreen(),
        '/reviews': (context) => ReviewScreen(),
        '/write-review': (context) => WriteReviewScreen(),
        '/guest-approval': (context) => GuestApprovalScreen(),
        '/maintenance-approval': (context) => MaintenanceApprovalScreen(),
        '/admin': (context) => AdminPageScreen(), // Add this line to define the admin route

      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        } else if (snapshot.hasData) {
          return FutureBuilder<bool>(
            future: _authService.isAdmin(snapshot.data!),
            builder: (context, isAdminSnapshot) {
              if (isAdminSnapshot.connectionState == ConnectionState.waiting) {
                return const SplashScreen();
              } else if (isAdminSnapshot.hasData && isAdminSnapshot.data!) {
                return AdminPageScreen(); // Admin dashboard screen
              } else {
                return HomeScreen();
              }
            },
          );
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}





// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// import 'package:unidorms/screens/display_reviews.dart';
// import 'package:unidorms/screens/guest.dart';
// import 'package:unidorms/screens/maintenance.dart';
// import 'package:unidorms/screens/reservation_screen.dart';
// import 'package:unidorms/screens/write_reviews.dart';
// import 'screens/home_screen.dart';
// import 'screens/login_screen.dart';
// import 'screens/notice_screen.dart';
// import 'screens/profile_screen.dart';
// import 'screens/registration_screen.dart';
// import 'screens/splash_screen.dart';
// import 'screens/forgot_password_screen.dart';
// import 'screens/catalogue_screen.dart';
// import 'package:unidorms/models/roomlist.dart';
// import 'package:unidorms/admin/guest_approval.dart';
// import 'package:unidorms/admin/maintenance_approval.dart';
// import 'package:unidorms/models/admin_setup.dart';
//
// import 'screens/maintenance.dart';
// import 'screens/guest.dart';
// import 'screens/display_reviews.dart';
// import 'screens/write_reviews.dart'; // Import WriteReviewScreen
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   await adminSetup(); // Call the admin setup function
//
//   await populateRooms();
//
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'UniDorms',
//       debugShowCheckedModeBanner: false, // Remove the debug banner
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       home: const SplashScreen(), // Set SplashScreen as the initial screen
//       routes: {
//         '/login': (context) => const LoginScreen(),
//         '/registration': (context) => const RegistrationScreen(),
//         '/home': (context) => HomeScreen(),
//         '/notice': (context) => NoticeScreen(),
//         '/profile': (context) => ProfileScreen(
//           userData: {},
//           onProfileUpdated: (updatedData) {},
//         ),
//         '/forgot-password': (context) => const ForgotPasswordScreen(),
//         '/catalogue': (context) => CatalogueScreen(),
//         '/reservation': (context) => ReservationsScreen(),
//         '/maintenance': (context) => MaintenanceScreen(),
//         '/guest': (context) => GuestVisitRequestScreen(),
//         '/reviews': (context) => ReviewScreen(),
//         '/write-review': (context) => WriteReviewScreen(),
//         '/guest-approval': (context) => GuestApprovalScreen(),
//         '/maintenance-approval': (context) => MaintenanceApprovalScreen(),
//
//
//             // other routes...
//
//
//       },
//     );
//   }
// }
//
// class AuthWrapper extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<User?>(
//       stream: FirebaseAuth.instance.authStateChanges(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const SplashScreen();
//         } else if (snapshot.hasData) {
//           return HomeScreen();
//         } else {
//           return const LoginScreen();
//         }
//       },
//     );
//   }
// }
//
