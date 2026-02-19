import 'package:flutter/material.dart';
import '../shared/section_template.dart';

class JobsScreen extends StatelessWidget {
  const JobsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SectionTemplate(
      title: 'Recruitment',
      description: 'Track jobs, candidates, interviews, and offers.',
      icon: Icons.work,
    );
  }
}
