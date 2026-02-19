import 'package:flutter/material.dart';

class CompanySwitcher extends StatelessWidget {
  const CompanySwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Company Switcher',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
