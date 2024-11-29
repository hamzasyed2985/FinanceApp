import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:finance_app/screens/add_transaction_screen.dart';
import 'package:finance_app/screens/home_screen.dart';
import 'package:finance_app/screens/transactions_screen.dart';
import 'package:finance_app/screens/login_signup_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finance Tracker',
      theme: ThemeData(primarySwatch: Colors.blue),
      // Use the authentication check to determine the initial route
      home: AuthWrapper(),
      routes: {
        '/loginSignup': (context) => LoginSignupScreen(),
        '/home': (context) => HomeScreen(),
        '/transactions': (context) => TransactionsScreen(),
        '/addTransaction': (context) => AddTransactionScreen(),
      },
    );
  }
}

// A wrapper to handle authentication and navigation
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(), // Listen to auth changes
      builder: (context, snapshot) {
        // Check if the user is authenticated
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ); // Show a loading indicator while checking auth
        } else if (snapshot.hasData) {
          return const HomeScreen(); // Navigate to the HomeScreen if authenticated
        } else {
          return const LoginSignupScreen(); // Navigate to Login/Signup if not authenticated
        }
      },
    );
  }
}
