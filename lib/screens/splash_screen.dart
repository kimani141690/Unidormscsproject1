import 'package:flutter/material.dart';
import 'dart:async';
import 'login_screen.dart';
import '../colors.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Column(
        children: <Widget>[
          Flexible(
            flex: 1,
            child: ClipPath(
              clipper: RoundedClipper(),
              child: Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 3 / 4,
                child: Image.asset('assets/images/splash.png', fit: BoxFit.cover),
              ),
            ),
          ),
          Flexible(
            flex: 1,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    'UNIDORMS',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textBlack,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'home away from home',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textBlack,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.textBlack),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RoundedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height);
    path.lineTo(size.width * 0.8, size.height);
    path.arcToPoint(
      Offset(size.width, size.height * 0.8),
      radius: Radius.circular(size.width * 0.2),
      clockwise: false,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
