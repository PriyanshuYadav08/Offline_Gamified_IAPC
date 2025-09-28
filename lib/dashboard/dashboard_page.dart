import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';

class DashboardPage extends StatelessWidget {
  final String uid;
  const DashboardPage({super.key, required this.uid});

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
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: FirebaseService().getUserProfile(uid),
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
        return Scaffold(
          appBar: AppBar(
            title: Text("Welcome ${data['name'] ?? 'Student'}"),
            actions: [
              IconButton(
                icon: const Icon(Icons.account_circle),
                tooltip: 'Profile',
                onPressed: () {
                  // TODO: Navigate to profile page
                },
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "XP: ${data['xp'] ?? 0}",
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              "Streak: ${data['streak'] ?? 0} days",
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              "Badges: " +
                                  ((data['badges'] as List?)?.join(', ') ??
                                      '-'),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        if (data['role'] != null)
                          Chip(
                            label: Text(data['role'].toString().toUpperCase()),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
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
                            // TODO: Navigate to game/test page
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