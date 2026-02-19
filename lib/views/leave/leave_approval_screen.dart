import 'package:flutter/material.dart';

class LeaveApprovalScreen extends StatelessWidget {
  const LeaveApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Leave Approval Screen',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
