import 'package:flutter/material.dart';

class ClockInOutScreen extends StatelessWidget {
  const ClockInOutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Clock In Out Screen',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
