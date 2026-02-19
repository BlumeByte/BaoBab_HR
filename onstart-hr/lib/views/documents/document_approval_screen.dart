import 'package:flutter/material.dart';

class DocumentApprovalScreen extends StatelessWidget {
  const DocumentApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Document Approval Screen',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
