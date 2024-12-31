import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:finance_app/screens/add_transaction_screen.dart';
import 'package:finance_app/screens/home_screen.dart';
import 'package:finance_app/screens/transactions_screen.dart';
import 'package:finance_app/screens/login_signup_screen.dart';
import 'package:finance_app/screens/splash_screen.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); 
  FirebaseAuth.instance.signOut();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finance Tracker',
      theme: ThemeData(
        primaryColor: const Color(0xFFD92A1A), 
        scaffoldBackgroundColor: Colors.white, 
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFFD92A1A), 
          secondary: Colors.white, 
        ),
        appBarTheme: const AppBarTheme(
          color: Color(0xFFD92A1A), 
          foregroundColor: Colors.white, 
        ),
      ),
      home: const SplashScreen(),
      routes: {
        '/loginSignup': (context) => const LoginSignupScreen(),
        '/home': (context) => const HomeScreen(),
        '/transactions': (context) => const TransactionsScreen(),
        '/addTransaction': (context) => const AddTransactionScreen(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream:
          FirebaseAuth.instance.authStateChanges(), 
      builder: (context, snapshot) {
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ); 
        } else if (snapshot.hasData) {
          return const HomeScreen(); 
        } else {
          return const LoginSignupScreen();
        }
      },
    );
  }
}
