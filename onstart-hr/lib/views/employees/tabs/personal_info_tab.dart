import 'package:flutter/material.dart';

class PersonalInfoTab extends StatelessWidget {
  const PersonalInfoTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Personal Info Tab',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
