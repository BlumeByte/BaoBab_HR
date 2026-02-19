import 'package:flutter/material.dart';

class EmployeeAssetsTab extends StatelessWidget {
  const EmployeeAssetsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Employee Assets Tab',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
