import 'package:flutter/material.dart';

class LoginSignupScreen extends StatefulWidget {
  @override
  _LoginSignupScreenState createState() => _LoginSignupScreenState();
}

class _LoginSignupScreenState extends State<LoginSignupScreen> {
  bool _isLogin = true; // Tracks whether the user is on the login or signup form

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login / Signup')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Toggle Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => setState(() => _isLogin = true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isLogin ? Colors.blue : Colors.grey,
                  ),
                  child: Text('Login'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => setState(() => _isLogin = false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: !_isLogin ? Colors.blue : Colors.grey,
                  ),
                  child: Text('Signup'),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Conditional Form Rendering
            _isLogin ? _buildLoginForm(context) : _buildSignupForm(context),
          ],
        ),
      ),
    );
  }

  // Login Form
  Widget _buildLoginForm(BuildContext context) {
    return Form(
      child: Column(
        children: [
          TextFormField(
            decoration: InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
          ),
          TextFormField(
            decoration: InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Navigate to HomeScreen after login
              Navigator.pushReplacementNamed(context, '/');
            },
            child: Text('Login'),
          ),
        ],
      ),
    );
  }

  // Signup Form
  Widget _buildSignupForm(BuildContext context) {
    return Form(
      child: Column(
        children: [
          TextFormField(
            decoration: InputDecoration(labelText: 'Name'),
          ),
          TextFormField(
            decoration: InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
          ),
          TextFormField(
            decoration: InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
          TextFormField(
            decoration: InputDecoration(labelText: 'Confirm Password'),
            obscureText: true,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Navigate to HomeScreen after signup
              Navigator.pushReplacementNamed(context, '/');
            },
            child: Text('Signup'),
          ),
        ],
      ),
    );
  }
}
