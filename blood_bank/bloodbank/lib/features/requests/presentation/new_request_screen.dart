import 'package:flutter/material.dart';

class NewRequestScreen extends StatelessWidget {
  const NewRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('طلب تبرع جديد')),
      body: const Center(child: Text('New Request Placeholder')),
    );
  }
}
