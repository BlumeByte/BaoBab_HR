import 'package:flutter/material.dart';

class ShiftScheduleScreen extends StatelessWidget {
  const ShiftScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Shift Schedule Screen',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
