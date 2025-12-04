import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../dashboard/dashboard_page.dart';
import '../services/firebase_service.dart';

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
  bool _isLoading = false;
  bool _obscureText = true;

  Future<void> _storeLoginTime() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('login_time', DateTime.now().millisecondsSinceEpoch);
  }

  Future<void> _submit() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) return;

    _formKey.currentState!.save();
    setState(() => _isLoading = true);

    try {
      UserCredential userCred;

      if (_isLogin) {
        userCred = await _firebase.signInWithEmailAndPassword(
          email: _emailEntered,
          password: _passwordEntered,
        );
      } else {
        userCred = await _firebase.createUserWithEmailAndPassword(
          email: _emailEntered,
          password: _passwordEntered,
        );

        final user = userCred.user;
        if (user != null) {
          await FirebaseService().saveUserProfile(
            uid: user.uid,
            role: "student",
            name: "New User",
            email: user.email!,
            school: "Update School",
            className: "Update Class",
          );
        }
      }

      await _storeLoginTime();
      final user = _firebase.currentUser;
      if (user != null) {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (ctx) => DashboardPage(uid: user.uid)),
        );
      }
    } on FirebaseAuthException catch (error) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(content: Text(error.message ?? 'Authentication Failed')),
        );
    } catch (e) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(content: Text('An unexpected error occurred.')),
        );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? 'Login' : 'Sign Up'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
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
                onSaved: (value) => _emailEntered = value!,
              ),

              const SizedBox(height: 16),

              TextFormField(
                obscureText: _obscureText,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () =>
                        setState(() => _obscureText = !_obscureText),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().length < 6) {
                    return 'Password must be at least 6 characters.';
                  }
                  return null;
                },
                onSaved: (value) => _passwordEntered = value!,
              ),

              const SizedBox(height: 24),

              _isLoading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          _isLogin ? 'Login' : 'Sign Up',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),

              const SizedBox(height: 12),

              TextButton(
                onPressed: () => setState(() => _isLogin = !_isLogin),
                child: Text(
                  _isLogin
                      ? "Don't have an account? Sign Up"
                      : "Already have an account? Log In",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}