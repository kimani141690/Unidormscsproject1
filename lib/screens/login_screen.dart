import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'forgot_password_screen.dart';
import 'registration_screen.dart';
import '../colors.dart';
import '../models/auth_service.dart';
import 'home_screen.dart';
import '../admin/admin.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _obscureText = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showAlertDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text;
      final password = _passwordController.text;

      bool loginSuccess = await _authService.performLogin(email, password);

      if (loginSuccess) {
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          bool isAdmin = await _authService.isAdmin(user);
          if (isAdmin) {
            Navigator.of(context).pushReplacementNamed('/admin');
          } else {
            Navigator.of(context).pushReplacementNamed('/home');
          }
        }
      } else {
        _showAlertDialog('Login Failed', 'Incorrect email or password.');
      }
    }
  }

  void _loginWithGoogle() async {
    try {
      await _authService.signInWithGoogle();
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        bool isAdmin = await _authService.isAdmin(user);
        if (isAdmin) {
          Navigator.of(context).pushReplacementNamed('/admin');
        } else {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      }
    } catch (e) {
      _showAlertDialog('Login Failed', 'Could not sign in with Google.');
    }
  }

  void _forgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showAlertDialog('Error', 'Please enter your email address to reset your password.');
      return;
    }
    try {
      await _authService.sendPasswordResetEmail(email);
      _showAlertDialog('Success', 'Password reset email sent. Please check your email.');
    } catch (e) {
      _showAlertDialog('Error', 'Failed to send password reset email. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.textWhite,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20), // For spacing from top

                const Text(
                  'LOGIN',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textBlack,
                  ),
                ),
                const SizedBox(height: 20),

                Image.asset('assets/images/auth.jpg', width: 200, height: 200,),

                const SizedBox(height: 20),

                SizedBox(
                  width: 400,
                  height: 45, // Adjust the height as needed
                  child: TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: const TextStyle(color: AppColors.textBlack),
                      filled: true,
                      fillColor: AppColors.backlight,
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please enter your email';
                      }
                      // Add more validation if needed
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 400,
                  height: 45, // Adjust the height as needed
                  child: TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: const TextStyle(color: AppColors.textBlack),
                      filled: true,
                      fillColor: AppColors.backlight,
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText ? Icons.visibility_off : Icons.visibility,
                          color: AppColors.textBlack,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                    ),
                    obscureText: _obscureText,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please enter your password';
                      }
                      // Add more validation if needed
                      return null;
                    },
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ForgotPasswordScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: AppColors.textBlack,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: 400,
                  height: 45, // Ensure the button height matches the text fields
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: AppColors.textWhite,
                      backgroundColor: AppColors.backgroundColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                      minimumSize: const Size.fromHeight(40),
                    ),
                    onPressed: _login,
                    child: const Text('Login'),
                  ),
                ),

                const SizedBox(height: 20),

                const Text('or',
                  style: TextStyle(
                    color: AppColors.textBlack,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.backgroundColor,
                    foregroundColor: AppColors.textBlack,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                    minimumSize: const Size(0, 40), // Set minimum size to zero and adjust height
                  ),
                  onPressed: _loginWithGoogle,
                  icon: Image.asset('assets/images/google.png', width: 20, height: 20,),
                  label: const Text('Login with Google'),
                ),
                const SizedBox(height: 20),

                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const RegistrationScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Don’t have an account? Register',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: AppColors.textBlack,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
                const SizedBox(height: 50), // For spacing at bottom
              ],
            ),
          ),
        ),
      ),
    );
  }
}






// import 'package:flutter/material.dart';
// import 'forgot_password_screen.dart';
// import 'registration_screen.dart';
// import '../colors.dart';
// import '../models/auth_service.dart';
//
// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});
//
//   @override
//   _LoginScreenState createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends State<LoginScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final AuthService _authService = AuthService();
//
//   bool _obscureText = true;
//
//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }
//
//   void _showAlertDialog(String title, String message) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text(title),
//           content: Text(message),
//           actions: [
//             TextButton(
//               child: const Text('OK'),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   void _login() async {
//     if (_formKey.currentState!.validate()) {
//       final email = _emailController.text;
//       final password = _passwordController.text;
//
//       bool loginSuccess = await _authService.performLogin(email, password);
//
//       if (loginSuccess) {
//         Navigator.of(context).pushReplacementNamed('/home');
//       } else {
//         _showAlertDialog('Login Failed', 'Incorrect email or password.');
//       }
//     }
//   }
//
//   void _loginWithGoogle() async {
//     try {
//       await _authService.signInWithGoogle();
//       Navigator.of(context).pushReplacementNamed('/home');
//     } catch (e) {
//       _showAlertDialog('Login Failed', 'Could not sign in with Google.');
//     }
//   }
//
//   void _forgotPassword() async {
//     final email = _emailController.text.trim();
//     if (email.isEmpty) {
//       _showAlertDialog('Error', 'Please enter your email address to reset your password.');
//       return;
//     }
//     try {
//       await _authService.sendPasswordResetEmail(email);
//       _showAlertDialog('Success', 'Password reset email sent. Please check your email.');
//     } catch (e) {
//       _showAlertDialog('Error', 'Failed to send password reset email. Please try again.');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.textWhite,
//       body: Center(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(16.0),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const SizedBox(height: 20), // For spacing from top
//
//                 const Text(
//                   'LOGIN',
//                   style: TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                     color: AppColors.textBlack,
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//
//                 Image.asset('assets/images/auth.jpg', width: 200, height: 200,),
//
//                 const SizedBox(height: 20),
//
//                 SizedBox(
//                   width: 400,
//                   height: 45, // Adjust the height as needed
//                   child: TextFormField(
//                     controller: _emailController,
//                     decoration: InputDecoration(
//                       labelText: 'Email',
//                       labelStyle: const TextStyle(color: AppColors.textBlack),
//                       filled: true,
//                       fillColor: AppColors.backlight,
//                       border: OutlineInputBorder(
//                         borderSide: BorderSide.none,
//                         borderRadius: BorderRadius.circular(20.0),
//                       ),
//                     ),
//                     validator: (value) {
//                       if (value?.isEmpty ?? true) {
//                         return 'Please enter your email';
//                       }
//                       // Add more validation if needed
//                       return null;
//                     },
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 SizedBox(
//                   width: 400,
//                   height: 45, // Adjust the height as needed
//                   child: TextFormField(
//                     controller: _passwordController,
//                     decoration: InputDecoration(
//                       labelText: 'Password',
//                       labelStyle: const TextStyle(color: AppColors.textBlack),
//                       filled: true,
//                       fillColor: AppColors.backlight,
//                       border: OutlineInputBorder(
//                         borderSide: BorderSide.none,
//                         borderRadius: BorderRadius.circular(20.0),
//                       ),
//                       suffixIcon: IconButton(
//                         icon: Icon(
//                           _obscureText ? Icons.visibility_off : Icons.visibility,
//                           color: AppColors.textBlack,
//                         ),
//                         onPressed: () {
//                           setState(() {
//                             _obscureText = !_obscureText;
//                           });
//                         },
//                       ),
//                     ),
//                     obscureText: _obscureText,
//                     validator: (value) {
//                       if (value?.isEmpty ?? true) {
//                         return 'Please enter your password';
//                       }
//                       // Add more validation if needed
//                       return null;
//                     },
//                   ),
//                 ),
//                 Align(
//                   alignment: Alignment.centerRight,
//                   child: TextButton(
//                     onPressed: () {
//                       Navigator.of(context).push(
//                         MaterialPageRoute(
//                           builder: (context) => const ForgotPasswordScreen(),
//                         ),
//                       );
//                     },
//                     child: const Text(
//                       'Forgot Password?',
//                       style: TextStyle(
//                         color: AppColors.textBlack,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),
//
//                 const SizedBox(height: 20),
//
//                 SizedBox(
//                   width: 400,
//                   height: 45, // Ensure the button height matches the text fields
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       foregroundColor: AppColors.textWhite,
//                       backgroundColor: AppColors.backgroundColor,
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
//                       minimumSize: const Size.fromHeight(40),
//                     ),
//                     onPressed: _login,
//                     child: const Text('Login'),
//                   ),
//                 ),
//
//                 const SizedBox(height: 20),
//
//                 const Text('or',
//                   style: TextStyle(
//                     color: AppColors.textBlack,
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//
//                 const SizedBox(height: 10),
//
//                 ElevatedButton.icon(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.backgroundColor,
//                     foregroundColor: AppColors.textBlack,
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
//                     minimumSize: const Size(0, 40), // Set minimum size to zero and adjust height
//                   ),
//                   onPressed: _loginWithGoogle,
//                   icon: Image.asset('assets/images/google.png', width: 20, height: 20,),
//                   label: const Text('Login with Google'),
//                 ),
//                 const SizedBox(height: 20),
//
//                 GestureDetector(
//                   onTap: () {
//                     Navigator.of(context).push(
//                       MaterialPageRoute(
//                         builder: (context) => const RegistrationScreen(),
//                       ),
//                     );
//                   },
//                   child: const Text(
//                     'Don’t have an account? Register',
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 12,
//                       color: AppColors.textBlack,
//                       decoration: TextDecoration.none,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 50), // For spacing at bottom
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
