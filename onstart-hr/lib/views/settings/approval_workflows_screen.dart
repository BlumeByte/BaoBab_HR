import 'package:flutter/material.dart';

class ApprovalWorkflowsScreen extends StatelessWidget {
  const ApprovalWorkflowsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Approval Workflows Screen',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
