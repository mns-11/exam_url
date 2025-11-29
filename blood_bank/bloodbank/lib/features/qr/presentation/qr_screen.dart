import 'package:flutter/material.dart';

class QrScreen extends StatelessWidget {
  const QrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('البطاقة الرقمية (Beta)')),
      body: const Center(child: Text('QR Placeholder')),
    );
  }
}
