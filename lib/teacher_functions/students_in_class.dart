import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StudentsInClassPage extends StatelessWidget {
  const StudentsInClassPage({super.key});

  /// Fetch the current teacher's class name from Firestore
  Future<String?> _getTeacherClass() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      print('No user logged in.');
      return null;
    }

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    final className = doc.data()?['class'];
    print('Teacher class from Firestore: $className');
    return className;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _getTeacherClass(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        final className = snapshot.data?.trim().toUpperCase();

        if (className == null || className.isEmpty) {
          return const Scaffold(
            body: Center(child: Text('Could not determine your class.')),
          );
        }

        return Scaffold(
          appBar: AppBar(title: Text('Students in $className')),
          body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .where('role', isEqualTo: 'student')
                // Normalize the class field for comparison
                .where('class', isEqualTo: className)
                .snapshots(),
            builder: (context, studentSnap) {
              if (studentSnap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (studentSnap.hasError) {
                return Center(child: Text('Error: ${studentSnap.error}'));
              }

              final docs = studentSnap.data?.docs ?? [];

              if (docs.isEmpty) {
                return Center(
                  child: Text('No students found in your class - $className'),
                );
              }

              return ListView.separated(
                itemCount: docs.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, idx) {
                  final student = docs[idx].data();

                  return ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(student['name'] ?? 'Unnamed'),
                    subtitle: Text('Email: ${student['email'] ?? '-'}'),
                    trailing: Text('XP: ${student['xp'] ?? 0}'),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}