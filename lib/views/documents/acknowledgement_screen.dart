import 'package:flutter/material.dart';

class AcknowledgementScreen extends StatelessWidget {
  const AcknowledgementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Acknowledgement Screen',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
