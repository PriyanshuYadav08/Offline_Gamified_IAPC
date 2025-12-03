import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../teacher_functions/quiz_analytics.dart';

class TeacherQuizzesAnalyticsPage extends StatelessWidget {
  const TeacherQuizzesAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final query = FirebaseFirestore.instance
        .collection('quizzes')
        .where('createdBy', isEqualTo: uid);
        // .orderBy('createdAt', descending: true);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Quizzes Analytics'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: query.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading quizzes: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No quizzes created yet.'));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data();
              final title = data['title'] ?? 'Untitled';
              final subject = data['subject'] ?? '';
              final className = data['class'] ?? '';
              final totalQuestions = data['totalQuestions'] ?? 0;
              final duration = data['duration'] ?? 0;
              final isLive = data['isLive'] == true;

              return Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(title),
                  subtitle: Text(
                    '$subject • Class: $className • $totalQuestions Qs • $duration min',
                  ),
                  trailing: isLive
                      ? const Icon(Icons.circle, color: Colors.green, size: 12)
                      : const Icon(Icons.circle, color: Colors.grey, size: 12),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => QuizAnalyticsDetailPage(
                          quizId: doc.id,
                          quizData: data,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}