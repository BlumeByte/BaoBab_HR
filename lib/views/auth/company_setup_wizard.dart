import 'package:flutter/material.dart';

class CompanySetupWizard extends StatelessWidget {
  const CompanySetupWizard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Company Setup Wizard',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
