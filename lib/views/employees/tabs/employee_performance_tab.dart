import 'package:flutter/material.dart';

class EmployeePerformanceTab extends StatelessWidget {
  const EmployeePerformanceTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Employee Performance Tab',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
