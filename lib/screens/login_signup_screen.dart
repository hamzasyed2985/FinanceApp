import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginSignupScreen extends StatefulWidget {
  const LoginSignupScreen({Key? key}) : super(key: key);

  @override
  _LoginSignupScreenState createState() => _LoginSignupScreenState();
}

class _LoginSignupScreenState extends State<LoginSignupScreen> {
  final _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();

  bool _isLogin = true;
  bool _isLoading = false;

  String _email = '';
  String _password = '';
  String _name = '';
  String _confirmPassword = '';

  void _showErrorDialog(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    try {
      setState(() {
        _isLoading = true;
      });

      await _auth.signInWithEmailAndPassword(
          email: _email, password: _password);

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      _showErrorDialog(e.message ?? 'An error occurred during login');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    if (_password != _confirmPassword) {
      _showErrorDialog('Passwords do not match');
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      await _auth.createUserWithEmailAndPassword(
          email: _email, password: _password);

      if (_name.isNotEmpty) {
        await _auth.currentUser!.updateDisplayName(_name);
      }

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      _showErrorDialog(e.message ?? 'An error occurred during signup');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value)) return 'Enter a valid email';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  Widget _buildTextFormField({
    required String labelText,
    required bool obscureText,
    required String? Function(String?) validator,
    required void Function(String?) onSaved,
  }) {
    return TextFormField(
      decoration: InputDecoration(labelText: labelText),
      obscureText: obscureText,
      validator: validator,
      onSaved: onSaved,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login / Signup')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => setState(() => _isLogin = true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isLogin ? Colors.blue : Colors.grey,
                    ),
                    child: const Text('Login'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => setState(() => _isLogin = false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: !_isLogin ? Colors.blue : Colors.grey,
                    ),
                    child: const Text('Signup'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  children: _isLogin
                      ? [
                          _buildTextFormField(
                            labelText: 'Email',
                            obscureText: false,
                            validator: _validateEmail,
                            onSaved: (value) => _email = value!,
                          ),
                          _buildTextFormField(
                            labelText: 'Password',
                            obscureText: true,
                            validator: _validatePassword,
                            onSaved: (value) => _password = value!,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            child: _isLoading
                                ? const CircularProgressIndicator()
                                : const Text('Login'),
                          ),
                        ]
                      : [
                          _buildTextFormField(
                            labelText: 'Name',
                            obscureText: false,
                            validator: (value) => value == null || value.isEmpty
                                ? 'Enter your name'
                                : null,
                            onSaved: (value) => _name = value!,
                          ),
                          _buildTextFormField(
                            labelText: 'Email',
                            obscureText: false,
                            validator: _validateEmail,
                            onSaved: (value) => _email = value!,
                          ),
                          _buildTextFormField(
                            labelText: 'Password',
                            obscureText: true,
                            validator: _validatePassword,
                            onSaved: (value) => _password = value!,
                          ),
                          _buildTextFormField(
                            labelText: 'Confirm Password',
                            obscureText: true,
                            validator: (value) => value == null || value.isEmpty
                                ? 'Confirm your password'
                                : null,
                            onSaved: (value) => _confirmPassword = value!,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _signup,
                            child: _isLoading
                                ? const CircularProgressIndicator()
                                : const Text('Signup'),
                          ),
                        ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
