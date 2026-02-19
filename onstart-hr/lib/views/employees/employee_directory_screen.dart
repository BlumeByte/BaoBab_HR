import 'package:flutter/material.dart';
import '../shared/section_template.dart';

class EmployeeDirectoryScreen extends StatelessWidget {
  const EmployeeDirectoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SectionTemplate(
      title: 'Employee Directory',
      description: 'Browse all employees, org info, and lifecycle actions.',
      icon: Icons.people,
    );
  }
}
