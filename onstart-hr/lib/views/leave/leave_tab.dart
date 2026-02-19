import 'package:flutter/material.dart';

class LeaveTab extends StatelessWidget {
  const LeaveTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Leave Tab',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
