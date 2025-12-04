import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../student_functions/quiz_result.dart';

class QuizAttemptPage extends StatefulWidget {
  final String quizId;
  final Map<String, dynamic> quizData;

  const QuizAttemptPage({
    super.key,
    required this.quizId,
    required this.quizData,
  });

  @override
  State<QuizAttemptPage> createState() => _QuizAttemptPageState();
}

class _QuizAttemptPageState extends State<QuizAttemptPage> {
  bool _isLoading = true;
  List<_QuestionModel> _questions = [];
  int _currentIndex = 0;
  final Map<String, String> _selectedByQuestionId = {}; // qId -> optionKey

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('quizzes')
          .doc(widget.quizId)
          .collection('questions')
          .orderBy('createdAt')
          .get();

      final list = snap.docs.map((d) {
        final data = d.data();
        return _QuestionModel.fromFirestore(d.id, data);
      }).toList();

      setState(() {
        _questions = list;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load questions : $e')));
      setState(() => _isLoading = false);
    }
  }

  void _selectOption(String questionId, String optionKey) {
    setState(() {
      _selectedByQuestionId[questionId] = optionKey;
    });
  }

  Future<void> _submitQuiz() async {
    if (_questions.isEmpty) return;

    int totalMarks = 0;
    int score = 0;
    int correctCount = 0;

    final List<AnswerSnapshot> answerSnapshots = [];

    for (final q in _questions) {
      totalMarks += q.marks;
      final selectedKey = _selectedByQuestionId[q.id];
      final isCorrect =
          selectedKey != null && selectedKey == q.correctAnswerKey;
      if (isCorrect) {
        score += q.marks;
        correctCount++;
      }

      final correctText = q.options[q.correctAnswerKey] ?? '';
      final selectedText = selectedKey != null
          ? (q.options[selectedKey] ?? '')
          : '';

      answerSnapshots.add(
        AnswerSnapshot(
          questionId: q.id,
          questionText: q.questionText,
          correctAnswerKey: q.correctAnswerKey,
          selectedAnswerKey: selectedKey ?? '',
          correctAnswerText: correctText,
          selectedAnswerText: selectedText,
          marks: q.marks,
          awardedMarks: isCorrect ? q.marks : 0,
          isCorrect: isCorrect,
        ),
      );
    }

    final wrongCount = _questions.length - correctCount;
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final teacherId = widget.quizData['createdBy'];

    try {
      final attempts = FirebaseFirestore.instance.collection('quiz_attempts');
      final attemptRef = await attempts.add({
        'quizId': widget.quizId,
        'studentId': uid,
        'teacherId': teacherId,
        'score': score,
        'totalMarks': totalMarks,
        'correctCount': correctCount,
        'wrongCount': wrongCount,
        'timeTaken': 0, // TODO: measure
        'completedAt': FieldValue.serverTimestamp(),
      });

      // write attempted_answers subcollection
      final batch = FirebaseFirestore.instance.batch();
      final answersCol = attemptRef.collection('attempted_answers');

      for (final ans in answerSnapshots) {
        final docRef = answersCol.doc();
        batch.set(docRef, ans.toFirestoreMap());
      }

      await batch.commit();

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => QuizResultPage(
            quizTitle: widget.quizData['title'] ?? 'Quiz',
            score: score,
            totalMarks: totalMarks,
            answers: answerSnapshots,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to submit quiz - $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz')),
        body: const Center(child: Text('No questions in this quiz.')),
      );
    }

    final q = _questions[_currentIndex];
    final selectedKey = _selectedByQuestionId[q.id];

    return Scaffold(
      appBar: AppBar(title: Text(widget.quizData['title'] ?? 'Quiz')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(
              value: (_currentIndex + 1) / _questions.length,
            ),
            const SizedBox(height: 12),
            Text(
              'Q${_currentIndex + 1}. ${q.questionText}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            ...['optionOne', 'optionTwo', 'optionThree', 'optionFour'].map((
              key,
            ) {
              final text = q.options[key];
              if (text == null || text.isEmpty) return const SizedBox.shrink();
              return RadioListTile<String>(
                value: key,
                groupValue: selectedKey,
                onChanged: (val) => _selectOption(q.id, val!),
                title: Text(text),
              );
            }).toList(),
            const Spacer(),
            Row(
              children: [
                if (_currentIndex > 0)
                  ElevatedButton(
                    onPressed: () {
                      setState(() => _currentIndex--);
                    },
                    child: const Text('Previous'),
                  ),
                const Spacer(),
                if (_currentIndex < _questions.length - 1)
                  ElevatedButton(
                    onPressed: () {
                      setState(() => _currentIndex++);
                    },
                    child: const Text('Next'),
                  )
                else
                  ElevatedButton(
                    onPressed: _submitQuiz,
                    child: const Text('Submit'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionModel {
  final String id;
  final String questionText;
  final Map<String, String> options;
  final String correctAnswerKey;
  final int marks;
  final String explanation;

  _QuestionModel({
    required this.id,
    required this.questionText,
    required this.options,
    required this.correctAnswerKey,
    required this.marks,
    required this.explanation,
  });

  factory _QuestionModel.fromFirestore(String id, Map<String, dynamic> data) {
    final opts = Map<String, dynamic>.from(data['options'] ?? {});
    return _QuestionModel(
      id: id,
      questionText: data['questionText'] ?? '',
      options: {
        'optionOne': (opts['optionOne'] ?? '').toString(),
        'optionTwo': (opts['optionTwo'] ?? '').toString(),
        'optionThree': (opts['optionThree'] ?? '').toString(),
        'optionFour': (opts['optionFour'] ?? '').toString(),
      },
      correctAnswerKey: data['correctAnswer'] ?? 'optionOne',
      marks: (data['marks'] ?? 1) as int,
      explanation: data['explanation'] ?? '',
    );
  }
}

class AnswerSnapshot {
  final String questionId;
  final String questionText;
  final String correctAnswerKey;
  final String selectedAnswerKey;
  final String correctAnswerText;
  final String selectedAnswerText;
  final int marks;
  final int awardedMarks;
  final bool isCorrect;

  AnswerSnapshot({
    required this.questionId,
    required this.questionText,
    required this.correctAnswerKey,
    required this.selectedAnswerKey,
    required this.correctAnswerText,
    required this.selectedAnswerText,
    required this.marks,
    required this.awardedMarks,
    required this.isCorrect,
  });

  Map<String, dynamic> toFirestoreMap() {
    return {
      'questionId': questionId,
      'questionText': questionText,
      'correctAnswerKey': correctAnswerKey,
      'selectedAnswerKey': selectedAnswerKey,
      'correctAnswer': correctAnswerText,
      'selectedAnswer': selectedAnswerText,
      'isCorrect': isCorrect,
      'marks': marks,
      'awardedMarks': awardedMarks,
    };
  }
}
