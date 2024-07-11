import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';
import '../colors.dart';
import '../models/auth_service.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _errorMessage;

  void _register() async {
    setState(() {
      _errorMessage = null;
    });

    String username = _usernameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    String? validationError = _authService.validatePassword(password, email);
    if (validationError != null) {
      setState(() {
        _errorMessage = validationError;
      });
      return;
    }

    String? result = await _authService.registerWithEmailAndPassword(username, email, password);
    if (result == null) {
      setState(() {
        _errorMessage = 'Registration failed. Please try again.';
      });
    } else if (result.startsWith('ERROR')) {
      setState(() {
        _errorMessage = result;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Account successfully created!'),
          duration: const Duration(seconds: 2),
        ),
      );
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.textWhite,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'REGISTRATION',
                  style: TextStyle(fontSize: 24, color: AppColors.textBlack),
                ),
                const SizedBox(height: 20),
                Image.asset('assets/images/auth.jpg', height: 200, width: 200),
                const SizedBox(height: 20),
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    labelStyle: const TextStyle(color: AppColors.textBlack),
                    filled: true,
                    fillColor: AppColors.backlight,
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: const TextStyle(color: AppColors.textBlack),
                    filled: true,
                    fillColor: AppColors.backlight,
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: const TextStyle(color: AppColors.textBlack),
                    filled: true,
                    fillColor: AppColors.backlight,
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: AppColors.textWhite,
                    backgroundColor: AppColors.backgroundColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                    minimumSize: const Size(400, 40),
                  ),
                  onPressed: _register,
                  child: const Text('Sign Up'),
                ),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  },
                  child: const Text(
                    'Already have an account? Login',
                    style: TextStyle(color: AppColors.textBlack),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
