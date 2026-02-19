import 'package:flutter/material.dart';

class CreateGoalScreen extends StatelessWidget {
  const CreateGoalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Create Goal Screen',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
