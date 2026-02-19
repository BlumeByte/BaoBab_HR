import 'package:flutter/material.dart';

class EmploymentTab extends StatelessWidget {
  const EmploymentTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Employment Tab',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
