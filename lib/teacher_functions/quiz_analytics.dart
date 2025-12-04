import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class QuizAnalyticsDetailPage extends StatelessWidget {
  final String quizId;
  final Map<String, dynamic> quizData;

  const QuizAnalyticsDetailPage({
    super.key,
    required this.quizId,
    required this.quizData,
  });

  @override
  Widget build(BuildContext context) {
    final title = quizData['title'] ?? 'Quiz';
    final subject = quizData['subject'] ?? '';
    final className = quizData['class'] ?? '';
    final totalQuestions = quizData['totalQuestions'] ?? 0;
    final duration = quizData['duration'] ?? 0;

    final attemptsQuery = FirebaseFirestore.instance
        .collection('quiz_attempts')
        .where('quizId', isEqualTo: quizId);
        // .orderBy('completedAt', descending: true);

    return Scaffold(
      appBar: AppBar(title: Text('Analytics : $title')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: attemptsQuery.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading attempts : ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _QuizHeader(
                    title: title,
                    subject: subject,
                    className: className,
                    totalQuestions: totalQuestions,
                    duration: duration,
                  ),
                  const SizedBox(height: 24),
                  const Center(child: Text('No attempts yet for this quiz.')),
                ],
              ),
            );
          }

          // Compute stats
          int totalAttempts = docs.length;
          int totalMarksPossible = 0;
          int totalScoreSum = 0;
          int bestScore = 0;
          int worstScore = 1 << 30; // large number

          for (final d in docs) {
            final data = d.data();
            final score = (data['score'] ?? 0) as int;
            final totalMarks = (data['totalMarks'] ?? 0) as int;

            totalScoreSum += score;
            totalMarksPossible = totalMarks; // same for all attempts

            if (score > bestScore) bestScore = score;
            if (score < worstScore) worstScore = score;
          }

          if (worstScore == (1 << 30)) worstScore = 0;

          final double avgScore =
              totalAttempts == 0 ? 0 : totalScoreSum / totalAttempts;
          final double avgPercent = (totalMarksPossible == 0)
              ? 0
              : (avgScore / totalMarksPossible * 100);

          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                _QuizHeader(
                  title: title,
                  subject: subject,
                  className: className,
                  totalQuestions: totalQuestions,
                  duration: duration,
                ),
                const SizedBox(height: 12),
                _SummaryStats(
                  totalAttempts: totalAttempts,
                  avgScore: avgScore,
                  avgPercent: avgPercent,
                  bestScore: bestScore,
                  worstScore: worstScore,
                  totalMarks: totalMarksPossible,
                ),
                const SizedBox(height: 16),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Attempts',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data();
                      return _AttemptTile(
                        attemptData: data,
                        attemptId: doc.id,
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AttemptTile extends StatelessWidget {
  final Map<String, dynamic> attemptData;
  final String attemptId;

  const _AttemptTile({
    required this.attemptData,
    required this.attemptId,
  });

  @override
  Widget build(BuildContext context) {
    final score = (attemptData['score'] ?? 0) as int;
    final totalMarks = (attemptData['totalMarks'] ?? 0) as int;
    final correctCount = (attemptData['correctCount'] ?? 0) as int;
    final wrongCount = (attemptData['wrongCount'] ?? 0) as int;
    final studentId = attemptData['studentId'] ?? '';
    final timestamp = attemptData['completedAt'] as Timestamp?;
    final completedAt = timestamp?.toDate();

    final percent =
        totalMarks == 0 ? 0.0 : (score / totalMarks * 100);

    // Fetch user doc to get student name
    final userDocFuture = FirebaseFirestore.instance
        .collection('users')
        .doc(studentId)
        .get();

    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: userDocFuture,
      builder: (context, snapshot) {
        String displayName = studentId;

        if (snapshot.hasData && snapshot.data!.exists) {
          final userData = snapshot.data!.data();
          if (userData != null && userData['name'] != null) {
            displayName = userData['name'] as String;
          }
        }

        return Card(
          margin: const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 4,
          ),
          child: ListTile(
            title: Text(
              'Student : $displayName',
              style: const TextStyle(fontSize: 14),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Score : $score / $totalMarks '
                  '(${percent.toStringAsFixed(1)}%)',
                ),
                Text(
                  'Correct : $correctCount • Wrong : $wrongCount',
                ),
                if (completedAt != null)
                  Text(
                    'Completed : ${completedAt.toLocal()}',
                    style: const TextStyle(fontSize: 12),
                  ),
              ],
            ),
            onTap: () {
              //detailed analysis compltete karna h
            },
          ),
        );
      },
    );
  }
}

class _QuizHeader extends StatelessWidget {
  final String title;
  final String subject;
  final String className;
  final int totalQuestions;
  final int duration;

  const _QuizHeader({
    required this.title,
    required this.subject,
    required this.className,
    required this.totalQuestions,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text('$subject • Class : $className'),
        Text('$totalQuestions Questions • $duration min'),
      ],
    );
  }
}

class _SummaryStats extends StatelessWidget {
  final int totalAttempts;
  final double avgScore;
  final double avgPercent;
  final int bestScore;
  final int worstScore;
  final int totalMarks;

  const _SummaryStats({
    required this.totalAttempts,
    required this.avgScore,
    required this.avgPercent,
    required this.bestScore,
    required this.worstScore,
    required this.totalMarks,
  });

  @override
  Widget build(BuildContext context) {
    final avgScoreText = totalMarks == 0
        ? '${avgScore.toStringAsFixed(1)}'
        : '${avgScore.toStringAsFixed(1)} / $totalMarks';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Wrap(
          spacing: 12,
          runSpacing: 6,
          children: [
            _statChip('Attempts', '$totalAttempts'),
            _statChip('Avg Score', avgScoreText),
            _statChip('Avg %', '${avgPercent.toStringAsFixed(1)}%'),
            _statChip('Best', '$bestScore / $totalMarks'),
            _statChip('Worst', '$worstScore / $totalMarks'),
          ],
        ),
      ),
    );
  }

  Widget _statChip(String label, String value) {
    return Chip(
      label: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontSize: 11)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    );
  }
}