import "package:flutter/material.dart";
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_profile.dart';

class UserProfilePage extends StatelessWidget {
	final String uid;
	const UserProfilePage({super.key, required this.uid});

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
					final badgeList = (data['badges'] as List?) ?? [];
					return Scaffold(
						appBar: AppBar(
							title: const Text('Profile'),
							centerTitle: true,
							backgroundColor: Theme.of(context).colorScheme.primary,
							foregroundColor: Colors.white,
							elevation: 0,
							actions: [
								IconButton(
									icon: const Icon(Icons.edit),
									tooltip: 'Edit Profile',
									onPressed: () async {
										await Navigator.of(context).push(
											MaterialPageRoute(
												builder: (ctx) => EditProfilePage(uid: uid),
											),
										);
										// No need to manually refresh, StreamBuilder will auto-update
									},
								),
							],
						),
						body: SingleChildScrollView(
							child: Column(
								children: [
									Container(
										width: double.infinity,
										padding: const EdgeInsets.symmetric(vertical: 32),
										decoration: BoxDecoration(
											color: Theme.of(context).colorScheme.primary,
											borderRadius: const BorderRadius.only(
												bottomLeft: Radius.circular(32),
												bottomRight: Radius.circular(32),
											),
										),
										child: Column(
											children: [
												CircleAvatar(
													radius: 48,
													backgroundColor: Colors.white,
													child: Icon(
														Icons.account_circle,
														size: 80,
														color: Theme.of(context).colorScheme.primary,
													),
												),
												const SizedBox(height: 16),
												Text(
													data['name'] ?? 'User',
													style: Theme.of(context).textTheme.headlineSmall?.copyWith(
																color: Colors.white,
																fontWeight: FontWeight.bold,
															),
												),
												const SizedBox(height: 8),
												Chip(
													label: Text(
														(data['role'] ?? '').toString().toUpperCase(),
														style: const TextStyle(color: Colors.white),
													),
													backgroundColor: const Color.fromARGB(50, 0, 0, 0),
												),
											],
										),
									),
									const SizedBox(height: 24),
									Padding(
										padding: const EdgeInsets.symmetric(horizontal: 24.0),
										child: Column(
											children: [
												_profileTile(Icons.email, 'Email', data['email'] ?? '-'),
												_profileTile(Icons.school, 'School', data['school'] ?? '-'),
												_profileTile(Icons.class_, 'Class', data['class'] ?? '-'),
												const SizedBox(height: 16),
												Row(
													mainAxisAlignment: MainAxisAlignment.spaceEvenly,
													children: [
														_statCard('XP', data['xp']?.toString() ?? '0', context),
														_statCard('Streak', '${data['streak'] ?? 0} days', context),
													],
												),
												const SizedBox(height: 24),
												Align(
													alignment: Alignment.centerLeft,
													child: Text(
														'Badges',
														style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
													),
												),
												const SizedBox(height: 8),
												badgeList.isEmpty
																? const Text('No badges yet.')
																: Wrap(
																		spacing: 8,
																		children: badgeList.map<Widget>((b) => Chip(label: Text(b.toString()))).toList(),
																	),
												const SizedBox(height: 32),
											],
										),
									),
								],
							),
						),
					);
				},
			);
		}

	Widget _profileTile(IconData icon, String label, String value) {
		return ListTile(
			leading: Icon(icon, color: Colors.blueAccent),
			title: Text(label),
			subtitle: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
			contentPadding: const EdgeInsets.symmetric(vertical: 4),
		);
	}

	Widget _statCard(String label, String value, BuildContext context) {
		return Card(
			elevation: 2,
			shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
			child: Container(
				width: 110,
				height: 80,
				alignment: Alignment.center,
				child: Column(
					mainAxisAlignment: MainAxisAlignment.center,
					children: [
						Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
						const SizedBox(height: 4),
						Text(label, style: Theme.of(context).textTheme.bodyMedium),
					],
				),
			),
		);
	}
}