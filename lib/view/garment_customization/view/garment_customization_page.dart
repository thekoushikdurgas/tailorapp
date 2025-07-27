import 'package:flutter/material.dart';

class GarmentCustomizationPage extends StatelessWidget {
  const GarmentCustomizationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Garment Customization')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.tune, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text('Advanced customization options'),
            SizedBox(height: 8),
            Text('Coming soon...'),
          ],
        ),
      ),
    );
  }
}
