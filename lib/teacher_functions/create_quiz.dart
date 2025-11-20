import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CreateQuizPage extends StatefulWidget {
  const CreateQuizPage({super.key});

  @override
  State<CreateQuizPage> createState() => _CreateQuizPageState();
}

class _CreateQuizPageState extends State<CreateQuizPage> {
  final _formKey = GlobalKey<FormState>();

  final _titleCtrl = TextEditingController();
  final _subjectCtrl = TextEditingController();
  final _classCtrl = TextEditingController();
  final _durationCtrl = TextEditingController(text: '10');
  bool _isLive = true;
  bool _isSaving = false;

  final List<_QuestionFormModel> _questions = [ _QuestionFormModel() ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _subjectCtrl.dispose();
    _classCtrl.dispose();
    _durationCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveQuiz() async {
    if (!_formKey.currentState!.validate()) return;

    // validate all questions
    for (final q in _questions) {
      if (!q.isValid()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all question fields.')),
        );
        return;
      }
    }

    setState(() => _isSaving = true);

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final quizzes = FirebaseFirestore.instance.collection('quizzes');
      final quizRef = quizzes.doc(); // auto ID
      final quizId = quizRef.id;

      final quizData = {
        'title': _titleCtrl.text.trim(),
        'subject': _subjectCtrl.text.trim(),
        'class': _classCtrl.text.trim(),
        'createdBy': uid,
        'createdAt': FieldValue.serverTimestamp(),
        'duration': int.tryParse(_durationCtrl.text.trim()) ?? 10,
        'isLive': _isLive,
        'totalQuestions': _questions.length,
      };

      // write quiz + questions in a batch
      final batch = FirebaseFirestore.instance.batch();
      batch.set(quizRef, quizData);

      final questionsCol = quizRef.collection('questions');

      for (final q in _questions) {
        final qRef = questionsCol.doc(); // auto questionId
        batch.set(qRef, q.toFirestoreMap());
      }

      await batch.commit();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Quiz created - $quizId')),
      );
      Navigator.of(context).pop(); // back to dashboard
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create quiz - $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _addQuestion() {
    setState(() => _questions.add(_QuestionFormModel()));
  }

  void _removeQuestion(int index) {
    if (_questions.length == 1) return;
    setState(() => _questions.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Quiz'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Quiz Title'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Enter title' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _subjectCtrl,
                decoration:
                    const InputDecoration(labelText: 'Subject (Math, Science, etc.)'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Enter subject' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _classCtrl,
                decoration:
                    const InputDecoration(labelText: 'Class (e.g. 8A)'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Enter class' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _durationCtrl,
                decoration:
                    const InputDecoration(labelText: 'Duration (minutes)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                title: const Text('Make quiz live'),
                value: _isLive,
                onChanged: (val) => setState(() => _isLive = val),
              ),
              const Divider(),
              const Text(
                'Questions',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              ..._questions.asMap().entries.map((entry) {
                final index = entry.key;
                final model = entry.value;
                return _QuestionCard(
                  key: ValueKey(model.id),
                  index: index,
                  model: model,
                  onRemove: () => _removeQuestion(index),
                );
              }),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: _addQuestion,
                icon: const Icon(Icons.add),
                label: const Text('Add Question'),
              ),
              const SizedBox(height: 16),
              _isSaving
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _saveQuiz,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                        child: Text('Publish Quiz'),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuestionFormModel {
  final String id = UniqueKey().toString();

  String questionText = '';
  String optionOne = '';
  String optionTwo = '';
  String optionThree = '';
  String optionFour = '';
  String correctAnswerKey = 'optionOne'; // default
  int marks = 1;

  bool isValid() {
    return questionText.trim().isNotEmpty &&
        optionOne.trim().isNotEmpty &&
        optionTwo.trim().isNotEmpty &&
        optionThree.trim().isNotEmpty &&
        optionFour.trim().isNotEmpty;
  }

  Map<String, dynamic> toFirestoreMap() {
    return {
      'questionText': questionText.trim(),
      'options': {
        'optionOne': optionOne.trim(),
        'optionTwo': optionTwo.trim(),
        'optionThree': optionThree.trim(),
        'optionFour': optionFour.trim(),
      },
      'correctAnswer': correctAnswerKey, // e.g. "optionTwo"
      'marks': marks,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}

class _QuestionCard extends StatefulWidget {
  final int index;
  final _QuestionFormModel model;
  final VoidCallback onRemove;

  const _QuestionCard({
    super.key,
    required this.index,
    required this.model,
    required this.onRemove,
  });

  @override
  State<_QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<_QuestionCard> {
  @override
  Widget build(BuildContext context) {
    final m = widget.model;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              children: [
                Text('Q${widget.index + 1}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(
                  onPressed: widget.onRemove,
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                ),
              ],
            ),
            TextFormField(
              initialValue: m.questionText,
              decoration: const InputDecoration(labelText: 'Question'),
              onChanged: (v) => m.questionText = v,
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: m.optionOne,
              decoration: const InputDecoration(labelText: 'Option 1'),
              onChanged: (v) => m.optionOne = v,
            ),
            TextFormField(
              initialValue: m.optionTwo,
              decoration: const InputDecoration(labelText: 'Option 2'),
              onChanged: (v) => m.optionTwo = v,
            ),
            TextFormField(
              initialValue: m.optionThree,
              decoration: const InputDecoration(labelText: 'Option 3'),
              onChanged: (v) => m.optionThree = v,
            ),
            TextFormField(
              initialValue: m.optionFour,
              decoration: const InputDecoration(labelText: 'Option 4'),
              onChanged: (v) => m.optionFour = v,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: m.correctAnswerKey,
              decoration:
                  const InputDecoration(labelText: 'Correct option (key)'),
              items: const [
                DropdownMenuItem(
                    value: 'optionOne', child: Text('Option 1')),
                DropdownMenuItem(
                    value: 'optionTwo', child: Text('Option 2')),
                DropdownMenuItem(
                    value: 'optionThree', child: Text('Option 3')),
                DropdownMenuItem(
                    value: 'optionFour', child: Text('Option 4')),
              ],
              onChanged: (v) =>
                  setState(() => m.correctAnswerKey = v ?? 'optionOne'),
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: m.marks.toString(),
              decoration: const InputDecoration(labelText: 'Marks'),
              keyboardType: TextInputType.number,
              onChanged: (v) => m.marks = int.tryParse(v) ?? 1,
            ),
          ],
        ),
      ),
    );
  }
}