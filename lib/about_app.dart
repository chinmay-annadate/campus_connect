import 'package:flutter/material.dart';

class AboutApp extends StatefulWidget {
  const AboutApp({super.key, required this.title});
  final String title;

  @override
  State<AboutApp> createState() => _AboutAppState();
}

class _AboutAppState extends State<AboutApp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: const Center(
        child: Text('This screen will have app info'),
      ),
    );
  }
}
