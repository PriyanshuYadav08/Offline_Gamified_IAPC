import 'package:flutter/material.dart';
import '../profile/user_profile.dart';

class TeacherDashboardPage extends StatelessWidget {
  final String uid;
  const TeacherDashboardPage({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Teacher Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            tooltip: 'Profile',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (ctx) => UserProfilePage(uid: uid)),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              "Welcome Teacher 👩‍🏫",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Create Quiz Button
            ElevatedButton.icon(
              icon: const Icon(Icons.add_circle_outline),
              label: const Text("Create New Quiz"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              onPressed: () {
                // TODO: Navigate to quiz creation screen
              },
            ),
            const SizedBox(height: 16),

            // View Students Button
            ElevatedButton.icon(
              icon: const Icon(Icons.people),
              label: const Text("View Students"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              onPressed: () {
                // TODO: Navigate to student list page
              },
            ),
            const SizedBox(height: 16),

            // View Class Analytics
            ElevatedButton.icon(
              icon: const Icon(Icons.analytics),
              label: const Text("View Class Analytics"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              onPressed: () {
                // TODO: Navigate to analytics page
              },
            ),
          ],
        ),
      ),
    );
  }
}
