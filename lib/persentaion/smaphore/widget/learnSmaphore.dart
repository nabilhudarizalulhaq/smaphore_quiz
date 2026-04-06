import 'package:flutter/material.dart';

class LearnsmaphorePage extends StatelessWidget {
  const LearnsmaphorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learn Semaphore'),
        backgroundColor: Colors.blueAccent.shade700,
      ),
      body: const Center(
        child: Text(
          'This is the Learn Semaphore Page',
          style: TextStyle(fontSize: 24, color: Colors.black87),
        ),
      ),
    );
  }
}
