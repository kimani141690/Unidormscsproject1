// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
// import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
// import '../colors.dart';
// import '../models/auth_service.dart';
//
// class AccountVerificationScreen extends StatefulWidget {
//   final String email;
//   final String verificationCode;
//
//   const AccountVerificationScreen({required this.email, required this.verificationCode, Key? key}) : super(key: key);
//
//   @override
//   _AccountVerificationScreenState createState() => _AccountVerificationScreenState();
// }
//
// class _AccountVerificationScreenState extends State<AccountVerificationScreen> {
//   final AuthService _authService = AuthService();
//   final TextEditingController _codeController = TextEditingController();
//   String? _errorMessage;
//
//   void _verifyCode() async {
//     setState(() {
//       _errorMessage = null;
//     });
//
//     String enteredCode = _codeController.text.trim();
//     User? user = _authService.currentUser;
//
//     if (user != null) {
//       DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(widget.email).get();
//       if (userDoc.exists) {
//         String storedCode = userDoc['verificationCode'];
//         if (enteredCode == storedCode) {
//           await FirebaseFirestore.instance.collection('users').doc(widget.email).update({
//             'emailVerified': true,
//           });
//           if (mounted) {
//             Navigator.of(context).pushReplacementNamed('/home');
//           }
//         } else {
//           setState(() {
//             _errorMessage = 'Invalid verification code. Please try again.';
//           });
//         }
//       } else {
//         setState(() {
//           _errorMessage = 'User data not found. Please try again.';
//         });
//       }
//     } else {
//       setState(() {
//         _errorMessage = 'User not logged in. Please try again.';
//       });
//     }
//   }
//
//   void _resendCode() async {
//     try {
//       await _authService.sendVerificationEmail(widget.email);
//       setState(() {
//         _errorMessage = 'A new code has been sent to your email.';
//       });
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Failed to resend verification code. Please try again.';
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.textWhite,
//       body: Center(
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Text(
//                   'Account Verification',
//                   style: TextStyle(fontSize: 24, color: AppColors.textBlack),
//                 ),
//                 const SizedBox(height: 20),
//                 Image.asset('assets/images/auth.jpg', height: 200, width: 200),
//                 const SizedBox(height: 20),
//                 const Text(
//                   'Verify your email',
//                   style: TextStyle(fontSize: 18, color: AppColors.textBlack),
//                 ),
//                 const SizedBox(height: 10),
//                 Text(
//                   'Please enter the 6 digit code sent to ${widget.email}',
//                   style: const TextStyle(fontSize: 14, color: AppColors.textBlack),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 20),
//                 TextField(
//                   controller: _codeController,
//                   keyboardType: TextInputType.number,
//                   maxLength: 6,
//                   decoration: InputDecoration(
//                     hintText: 'Enter code',
//                     filled: true,
//                     fillColor: AppColors.backlight,
//                     border: OutlineInputBorder(
//                       borderSide: BorderSide.none,
//                       borderRadius: BorderRadius.circular(10.0),
//                     ),
//                   ),
//                 ),
//                 if (_errorMessage != null)
//                   Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 10.0),
//                     child: Text(
//                       _errorMessage!,
//                       style: const TextStyle(color: Colors.red, fontSize: 12),
//                     ),
//                   ),
//                 const SizedBox(height: 10),
//                 TextButton(
//                   onPressed: _resendCode,
//                   child: const Text(
//                     'Resend Code',
//                     style: TextStyle(color: AppColors.textBlack),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     foregroundColor: AppColors.textWhite,
//                     backgroundColor: AppColors.backgroundColor,
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
//                     minimumSize: const Size(400, 40),
//                   ),
//                   onPressed: _verifyCode,
//                   child: const Text('Confirm'),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
