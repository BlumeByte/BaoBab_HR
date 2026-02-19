import 'package:flutter/material.dart';

class EmployeeFormScreen extends StatelessWidget {
  const EmployeeFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Employee Form Screen',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
