import 'package:flutter/material.dart';

class LeaveReportScreen extends StatelessWidget {
  const LeaveReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Leave Report Screen',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
