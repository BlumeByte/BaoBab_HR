import 'package:flutter/material.dart';

class EmployeeLeaveTab extends StatelessWidget {
  const EmployeeLeaveTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Employee Leave Tab',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
