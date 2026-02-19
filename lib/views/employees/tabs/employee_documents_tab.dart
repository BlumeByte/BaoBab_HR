import 'package:flutter/material.dart';

class EmployeeDocumentsTab extends StatelessWidget {
  const EmployeeDocumentsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Employee Documents Tab',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
