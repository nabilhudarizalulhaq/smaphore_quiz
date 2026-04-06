import 'package:flutter/material.dart';

class IntroductionCodePage extends StatelessWidget {
  const IntroductionCodePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Introduction to Semaphore Code'),
        backgroundColor: Colors.blueAccent.shade700,
      ),
      body: const Center(
        child: Text(
          'This page will introduce the semaphore code and its history.',
          style: TextStyle(fontSize: 24, color: Colors.black87),
        ),
      ),
    );
  }
}
