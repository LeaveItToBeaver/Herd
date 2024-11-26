import 'package:flutter/material.dart';

class PrivateFeedScreen extends StatelessWidget {
  const PrivateFeedScreen({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Private Feed')),
      body: const Center(child: Text('Private Feed Screen')),
    );
  }
}