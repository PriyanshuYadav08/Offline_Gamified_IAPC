
import 'package:flutter/material.dart';

class SignupPage extends StatefulWidget {
	const SignupPage({Key? key}) : super(key: key);

	@override
	State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
	final TextEditingController _emailController = TextEditingController();
	final TextEditingController _passwordController = TextEditingController();
	final TextEditingController _confirmPasswordController = TextEditingController();
	bool _obscureText = true;

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(title: const Text('Sign Up')),
			body: Padding(
				padding: const EdgeInsets.all(16.0),
				child: Column(
					mainAxisAlignment: MainAxisAlignment.center,
					children: [
						TextField(
							controller: _emailController,
							decoration: const InputDecoration(
								labelText: 'Email',
								border: OutlineInputBorder(),
							),
							keyboardType: TextInputType.emailAddress,
						),
						const SizedBox(height: 16),
						TextField(
							controller: _passwordController,
							obscureText: _obscureText,
							decoration: InputDecoration(
								labelText: 'Password',
								border: const OutlineInputBorder(),
								suffixIcon: IconButton(
									icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
									onPressed: () {
										setState(() {
											_obscureText = !_obscureText;
										});
									},
								),
							),
						),
						const SizedBox(height: 16),
						TextField(
							controller: _confirmPasswordController,
							obscureText: _obscureText,
							decoration: const InputDecoration(
								labelText: 'Confirm Password',
								border: OutlineInputBorder(),
							),
						),
						const SizedBox(height: 24),
						SizedBox(
							width: double.infinity,
							child: Column(
								children: [
									ElevatedButton(
										onPressed: () {
											// TODO: Implement signup logic
										},
										child: const Text('Sign Up'),
									),
									const SizedBox(height: 12),
									TextButton(
										onPressed: () {
											Navigator.pop(context);
										},
										child: const Text('Already have an account? Login'),
									),
								],
							),
						),
					],
				),
			),
		);
	}
}