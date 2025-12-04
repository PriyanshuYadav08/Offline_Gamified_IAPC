import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  Future<void> _verifyTeacherPasscode(String enteredPasscode) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("config")
          .doc("teacherPasskey")
          .get();
      if (!snapshot.exists) {
        throw Exception("Passcode config missing!");
      }
      final storedPasscode = snapshot.data()!["key"];
      if (enteredPasscode == storedPasscode) {
        final uid = FirebaseAuth.instance.currentUser!.uid;
        await FirebaseFirestore.instance.collection("users").doc(uid).update({
          "role": "teacher",
        });
        setState(() {
          _role = "teacher";
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("You are now a teacher!")),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Invalid Passcode")));
        }
      }
    } catch (e) {
      print("Error verifying passcode : $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error : $e")));
      }
    }
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
                decoration: const InputDecoration(
                  labelText: 'Email',
                  enabled: false, // Makes it visually disabled (grayed out)
                ),
                readOnly: true, // Prevents editing
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
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveProfile,
                child: const Text('Save'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _logOut, child: const Text('Log Out')),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final enteredPasscode = await showDialog<String>(
                    context: context,
                    builder: (ctx) {
                      String input = "";
                      return AlertDialog(
                        title: Text("Enter Teacher Passcode"),
                        content: TextField(
                          onChanged: (val) => input = val,
                          decoration: InputDecoration(hintText: "Passcode"),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, input),
                            child: Text("Submit"),
                          ),
                        ],
                      );
                    },
                  );
                  if (enteredPasscode != null && enteredPasscode.isNotEmpty) {
                    await _verifyTeacherPasscode(enteredPasscode);
                  }
                },
                child: Text("Become a Teacher"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}