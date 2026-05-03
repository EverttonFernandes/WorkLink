import 'package:flutter/material.dart';

// coverage:ignore-start
void main() {
  runApp(const WorkLinkApp());
}
// coverage:ignore-end

class WorkLinkApp extends StatelessWidget {
  const WorkLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'WorkLink',
      home: Scaffold(
        body: Center(
          child: Text('WorkLink'),
        ),
      ),
    );
  }
}
