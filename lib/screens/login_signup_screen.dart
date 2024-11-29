import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';



class LoginSignupScreen extends StatefulWidget {
  const LoginSignupScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginSignupScreenState createState() => _LoginSignupScreenState();
}

class _LoginSignupScreenState extends State<LoginSignupScreen> {
  final _auth = FirebaseAuth.instance; 
  bool _isLogin = true; 
  final _formKey = GlobalKey<FormState>(); 

  String _email = '';
  String _password = '';
  String _name = '';
  String _confirmPassword = '';

  bool _isLoading = false; 

  // Show error messages
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  // Login function
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    try {
      setState(() {
        _isLoading = true;
      });
      await _auth.signInWithEmailAndPassword(email: _email, password: _password);


      if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
    } on FirebaseAuthException catch (e) {
      _showErrorDialog(e.message ?? 'An error occurred during login');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Signup function
  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    if (_password != _confirmPassword) {
      _showErrorDialog("Passwords do not match");
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });
      await _auth.createUserWithEmailAndPassword(email: _email, password: _password);

      // Optionally, update the display name for the user
      if (_name.isNotEmpty) {
        await _auth.currentUser!.updateDisplayName(_name);
      }

      // Navigate to the home screen on successful signup
      // ignore: use_build_context_synchronously
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      _showErrorDialog(e.message ?? 'An error occurred during signup');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

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

            if (_isLoading)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }

  // Login Form
  Widget _buildLoginForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            decoration: InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
            validator: (value) => value == null || value.isEmpty || !value.contains('@')
                ? 'Enter a valid email'
                : null,
            onSaved: (value) => _email = value!,
          ),
          TextFormField(
            decoration: InputDecoration(labelText: 'Password'),
            obscureText: true,
            validator: (value) => value == null || value.length < 6
                ? 'Password must be at least 6 characters long'
                : null,
            onSaved: (value) => _password = value!,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _login,
            child: Text('Login'),
          ),
        ],
      ),
    );
  }

  // Signup Form
  Widget _buildSignupForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            decoration: InputDecoration(labelText: 'Name'),
            validator: (value) => value == null || value.isEmpty ? 'Enter your name' : null,
            onSaved: (value) => _name = value!,
          ),
          TextFormField(
            decoration: InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
            validator: (value) => value == null || value.isEmpty || !value.contains('@')
                ? 'Enter a valid email'
                : null,
            onSaved: (value) => _email = value!,
          ),
          TextFormField(
            decoration: InputDecoration(labelText: 'Password'),
            obscureText: true,
            validator: (value) => value == null || value.length < 6
                ? 'Password must be at least 6 characters long'
                : null,
            onSaved: (value) => _password = value!,
          ),
          TextFormField(
            decoration: InputDecoration(labelText: 'Confirm Password'),
            obscureText: true,
            validator: (value) => value == null || value.isEmpty
                ? 'Confirm your password'
                : null,
            onSaved: (value) => _confirmPassword = value!,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _signup,
            child: Text('Signup'),
          ),
        ],
      ),
    );
  }
}
