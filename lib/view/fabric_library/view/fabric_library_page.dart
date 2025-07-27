import 'package:flutter/material.dart';

class FabricLibraryPage extends StatelessWidget {
  const FabricLibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fabric Library')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.texture, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text('Fabric Selection'),
            SizedBox(height: 8),
            Text('Browse premium fabrics'),
          ],
        ),
      ),
    );
  }
}
