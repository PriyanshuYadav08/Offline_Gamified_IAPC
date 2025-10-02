import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/auth.dart';

class EditProfilePage extends StatefulWidget {
  final String uid;
  const EditProfilePage({super.key, required this.uid});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  Future<void> _logOut() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (ctx) => const AuthScreen()),
        (route) => false,
      );
    }
  }
  final _formKey = GlobalKey<FormState>();
  TextEditingController? _nameController;
  TextEditingController? _emailController;
  TextEditingController? _schoolController;
  TextEditingController? _classController;
  String? _role;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    final doc = await FirebaseService().getUserProfile(widget.uid);
    final data = doc.data() ?? {};
    _nameController = TextEditingController(text: data['name'] ?? '');
    _emailController = TextEditingController(text: data['email'] ?? '');
    _schoolController = TextEditingController(text: data['school'] ?? '');
    _classController = TextEditingController(text: data['class'] ?? '');
    setState(() {
      _role = data['role'] ?? 'student';
      _loading = false;
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (_nameController == null ||
        _emailController == null ||
        _schoolController == null ||
        _classController == null)
      return;
    await FirebaseService().saveUserProfile(
      uid: widget.uid,
      role: _role ?? 'student',
      name: _nameController!.text.trim(),
      email: _emailController!.text.trim(),
      school: _schoolController!.text.trim(),
      className: _classController!.text.trim(),
    );
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading ||
        _nameController == null ||
        _emailController == null ||
        _schoolController == null ||
        _classController == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Enter name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) =>
                    v == null || !v.contains('@') ? 'Enter valid email' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _schoolController,
                decoration: const InputDecoration(labelText: 'School'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _classController,
                decoration: const InputDecoration(labelText: 'Class'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _role,
                items: const [
                  DropdownMenuItem(value: 'student', child: Text('Student')),
                  DropdownMenuItem(value: 'teacher', child: Text('Teacher')),
                ],
                onChanged: (v) => setState(() => _role = v),
                decoration: const InputDecoration(labelText: 'Role'),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveProfile,
                child: const Text('Save'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _logOut,
                child: const Text('Log Out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}