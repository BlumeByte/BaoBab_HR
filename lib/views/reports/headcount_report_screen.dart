import 'package:flutter/material.dart';
import '../shared/section_template.dart';

class HeadcountReportScreen extends StatelessWidget {
  const HeadcountReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SectionTemplate(
      title: 'Reports',
      description: 'View HR analytics for headcount, attendance, leave, and hiring.',
      icon: Icons.bar_chart,
    );
  }
}
