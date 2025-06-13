import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bem-vindo!')),
      body: const Center(
        child: Text(
          'Olá, Flutter sem Firebase!',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
