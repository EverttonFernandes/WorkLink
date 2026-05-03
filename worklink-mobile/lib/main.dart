import 'package:flutter/material.dart';

import 'app/worklink_app_configuration.dart';

// coverage:ignore-start
void main() {
  runApp(const WorkLinkApp());
}
// coverage:ignore-end

class WorkLinkApp extends StatelessWidget {
  const WorkLinkApp({
    super.key,
    this.applicationConfiguration = const WorkLinkAppConfiguration(),
  });

  final WorkLinkAppConfiguration applicationConfiguration;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: applicationConfiguration.applicationName,
      home: Scaffold(
        body: Center(
          child: Text(applicationConfiguration.applicationName),
        ),
      ),
    );
  }
}
