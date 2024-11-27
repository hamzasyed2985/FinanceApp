import 'package:finance_app/screens/add_transaction_screen.dart';
import 'package:finance_app/screens/home_screen.dart';
import 'package:finance_app/screens/transactions_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:finance_app/screens/login_signup_screen.dart'; // Import the login/signup screen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finance Tracker',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute:
          '/loginSignup', // Set login/signup screen as the initial route
      routes: {
        '/loginSignup': (context) => LoginSignupScreen(), // Add the route
        '/': (context) => HomeScreen(),
        '/transactions': (context) => TransactionsScreen(),
        '/addTransaction': (context) => AddTransactionScreen(),
      },
    );
  }
}
