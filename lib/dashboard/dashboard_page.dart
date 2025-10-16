import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../profile/user_profile.dart';
import 'teacher_dashboard.dart';

class DashboardPage extends StatelessWidget {
  final String uid;
  const DashboardPage({super.key, required this.uid});

  // Student game list
  static const List<Map<String, dynamic>> games = [
    {'title': 'Math Quiz', 'icon': Icons.calculate},
    {'title': 'Physics Puzzle', 'icon': Icons.science},
    {'title': 'Chemistry Match', 'icon': Icons.bubble_chart},
    {'title': 'Biology Test', 'icon': Icons.eco},
    {'title': 'Coding Challenge', 'icon': Icons.code},
    {'title': 'General Knowledge', 'icon': Icons.quiz},
  ];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(
            body: Center(child: Text('User profile not found.')),
          );
        }

        final data = snapshot.data!.data()!;
        final role = data['role'] ?? 'student';
        if (role == 'teacher') {
          return TeacherDashboardPage(uid: uid);
        }

        return Scaffold(
          appBar: AppBar(
            title: Text("Welcome ${data['name'] ?? 'Student'}"),
            actions: [
              IconButton(
                icon: const Icon(Icons.account_circle),
                tooltip: 'Profile',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (ctx) => UserProfilePage(uid: uid),
                    ),
                  );
                },
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choose a Game/Test',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.1,
                    ),
                    itemCount: games.length,
                    itemBuilder: (context, index) {
                      final game = games[index];
                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            // TODO: Navigate to specific game/test page
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                game['icon'],
                                size: 48,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                game['title'],
                                style: Theme.of(context).textTheme.titleMedium,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}