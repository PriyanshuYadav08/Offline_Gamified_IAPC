import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../student_functions/quiz_attempt.dart';

class LiveQuizzesPage extends StatelessWidget {
  final String studentClass; // e.g. "8A"

  const LiveQuizzesPage({super.key, required this.studentClass});

  @override
  Widget build(BuildContext context) {
    final query = FirebaseFirestore.instance
        .collection('quizzes')
        .where('isLive', isEqualTo: true)
        .where('class', isEqualTo: studentClass);
        // .orderBy('createdAt', descending: true);

    return Scaffold(
      appBar: AppBar(title: const Text('Live Quizzes')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: query.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No live quizzes.'));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data();
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(data['title'] ?? 'Untitled'),
                  subtitle: Text(
                    '${data['subject'] ?? ''} • ${data['duration'] ?? 0} min • ${data['totalQuestions'] ?? 0} Qs',
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => QuizAttemptPage(
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