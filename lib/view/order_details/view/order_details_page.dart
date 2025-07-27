import 'package:flutter/material.dart';

class OrderDetailsPage extends StatelessWidget {
  final String? orderId;

  const OrderDetailsPage({super.key, this.orderId});

  @override
  Widget build(BuildContext context) {
    final orderIdValue = orderId ?? '';

    return Scaffold(
      appBar: AppBar(title: Text('Order Details - $orderIdValue')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.receipt_long, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            Text('Order ID: $orderIdValue'),
            const SizedBox(height: 16),
            const Text('Order details will be implemented here'),
          ],
        ),
      ),
    );
  }
}
