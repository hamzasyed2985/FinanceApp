import 'package:flutter/material.dart';
import 'package:finance_app/main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to AuthWrapper after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthWrapper()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD92A1A), // Red background
      body: Center(
        child: Image.asset(
          'assets/logo.png', // Add your logo image in assets
          width: 150, // Adjust the size of the image as needed
        ),
      ),
    );
  }
}
