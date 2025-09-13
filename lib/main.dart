import 'package:flutter/material.dart';
// import 'auth/login_page.dart';
// import 'auth/signup_page.dart';
import 'auth/auth.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'IAPC Project',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 93, 0, 255)),
      ),
      home: const AuthScreen(),
    );
  }
}