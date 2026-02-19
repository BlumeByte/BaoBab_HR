import 'package:flutter/material.dart';

class RecruitmentReportScreen extends StatelessWidget {
  const RecruitmentReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Recruitment Report Screen',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
