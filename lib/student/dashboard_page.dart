import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  final List<Map<String, dynamic>> games = const [
    {'title': 'Math Quiz', 'icon': Icons.calculate},
    {'title': 'Physics Puzzle', 'icon': Icons.science},
    {'title': 'Chemistry Match', 'icon': Icons.bubble_chart},
    {'title': 'Biology Test', 'icon': Icons.eco},
    {'title': 'Coding Challenge', 'icon': Icons.code},
    {'title': 'General Knowledge', 'icon': Icons.quiz},
  ];

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
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
    );
  }
}
