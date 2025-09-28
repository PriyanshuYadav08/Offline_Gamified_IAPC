import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Create or update user profile
  Future<void> saveUserProfile({
    required String uid,
    required String role,
    required String name,
    required String email,
    String? school,
    String? className,
    List<String>? subjects,
  }) async {
    await _db.collection('users').doc(uid).set({
      'role': role,
      'name': name,
      'email': email,
      'school': school,
      'class': className,
      'subjects': subjects,
      'xp': 0,
      'streak': 0,
      'badges': [],
      'lastLogin': DateTime.now(),
    }, SetOptions(merge: true));
  }

  // Fetch user profile
  Future<DocumentSnapshot<Map<String, dynamic>>> getUserProfile(String uid) {
    return _db.collection('users').doc(uid).get();
  }
}