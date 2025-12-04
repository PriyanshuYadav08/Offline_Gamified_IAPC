import 'package:flutter/material.dart';
import '../student_functions/quiz_attempt.dart' show AnswerSnapshot;

class QuizResultPage extends StatelessWidget {
  final String quizTitle;
  final int score;
  final int totalMarks;
  final List<AnswerSnapshot> answers;

  const QuizResultPage({
    super.key,
    required this.quizTitle,
    required this.score,
    required this.totalMarks,
    required this.answers,
  });

  @override
  Widget build(BuildContext context) {
    final double percent = totalMarks == 0
        ? 0.0
        : (score / totalMarks * 100).clamp(0, 100);

    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Result')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quiz title
            Text(
              quizTitle,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            // Score + percentage
            Text(
              'Score : $score / $totalMarks  (${percent.toStringAsFixed(1)}%)',
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 4),

            // Simple performance label
            Text(
              _performanceLabel(percent),
              style: TextStyle(
                fontSize: 14,
                color: _performanceColor(percent),
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              'Question Review',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: answers.isEmpty
                  ? const Center(
                      child: Text('No answers recorded for this quiz.'),
                    )
                  : ListView.builder(
                      itemCount: answers.length,
                      itemBuilder: (context, index) {
                        final a = answers[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Question text
                                Text(
                                  'Q${index + 1}. ${a.questionText}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 6),

                                // Your answer
                                Text(
                                  'Your answer : ${a.selectedAnswerText.isEmpty ? 'Not answered' : a.selectedAnswerText}',
                                  style: TextStyle(
                                    color: a.isCorrect
                                        ? Colors.green
                                        : Colors.redAccent,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                // Marks
                                Text(
                                  'Marks : ${a.awardedMarks} / ${a.marks}',
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

            const SizedBox(height: 8),

            // Back button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // go back to previous page
                },
                child: const Text('Back'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper: label based on percentage
  static String _performanceLabel(double percent) {
    if (percent >= 90) return 'Excellent!';
    if (percent >= 75) return 'Great job!';
    if (percent >= 50) return 'Good effort, keep practicing';
    return 'Keep trying, you can improve';
  }

  // Helper: color based on percentage
  static Color _performanceColor(double percent) {
    if (percent >= 75) return Colors.green;
    if (percent >= 50) return Colors.orange;
    return Colors.redAccent;
  }
}