import 'package:flutter/material.dart';

class PatternLibraryPage extends StatelessWidget {
  const PatternLibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pattern Library')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pattern, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text('Pattern Collection'),
            SizedBox(height: 8),
            Text('Explore design patterns'),
          ],
        ),
      ),
    );
  }
}
