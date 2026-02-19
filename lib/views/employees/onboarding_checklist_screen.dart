import 'package:flutter/material.dart';

class OnboardingChecklistScreen extends StatelessWidget {
  const OnboardingChecklistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Onboarding Checklist Screen',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
