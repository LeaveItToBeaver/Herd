import 'package:flutter/material.dart';

class PublicFeedScreen extends StatelessWidget {
  const PublicFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Public Feed')),
      body: const Center(child: Text('Public Feed Screen')),
    );
  }
}