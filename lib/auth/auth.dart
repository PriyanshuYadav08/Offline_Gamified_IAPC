import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../student/dashboard_page.dart';

// final FirebaseAuth auth = FirebaseAuth.instance;
final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();

  var _isLogin = true;
  var _emailEntered = '';
  var _passwordEntered = '';

  Future<void> _submit() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }
    _formKey.currentState!.save();

    if (_isLogin) {
      try {
        final userCred = await _firebase.signInWithEmailAndPassword(
          email: _emailEntered,
          password: _passwordEntered,
        );
        print(userCred);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (ctx) => const DashboardPage()),
        );
      } on FirebaseAuthException catch (error) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message ?? 'Login Failed 😣')),
        );
      }
    } else {
      try {
        final userCred = await _firebase.createUserWithEmailAndPassword(
          email: _emailEntered,
          password: _passwordEntered,
        );
        print(userCred);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (ctx) => const DashboardPage()),
        );
      } on FirebaseAuthException catch (error) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message ?? 'Authentication Failed 😣')),
        );
      }
    }
  }
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                // controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                textCapitalization: TextCapitalization.none,
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty ||
                      !value.contains('@')) {
                    return 'Please enter a valid email.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _emailEntered = value!;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                // controller: _passwordController,
                obscureText: _obscureText,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().length < 6) {
                    return 'Password must be at least 6 characters long.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _passwordEntered = value!;
                },
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primaryContainer,
                  ),
                  child: Text(_isLogin ? 'Login' : 'Sign Up'),
                ),
              ),

              const SizedBox(height: 12),

              TextButton(
                onPressed: () {
                  setState(() {
                    _isLogin = !_isLogin;
                  });
                },
                child: Text(
                  _isLogin
                      ? "Don't have an account? Sign up"
                      : "Already have an account? Log in",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}