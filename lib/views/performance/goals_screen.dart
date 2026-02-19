import 'package:flutter/material.dart';
import '../shared/section_template.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SectionTemplate(
      title: 'Performance',
      description: 'Manage goals, reviews, and feedback cycles.',
      icon: Icons.insights,
    );
  }
}
