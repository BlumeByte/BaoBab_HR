import 'package:flutter/material.dart';
import '../shared/section_template.dart';

class HrDashboard extends StatelessWidget {
  const HrDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return const SectionTemplate(
      title: 'HR Dashboard',
      description: 'BambooHR-inspired home with workforce summary, quick access, and key metrics.',
      icon: Icons.dashboard,
      actions: [
        _MetricCard(label: 'Employees', value: '128'),
        _MetricCard(label: 'Open Roles', value: '14'),
        _MetricCard(label: 'On Leave', value: '9'),
        _MetricCard(label: 'Pending Approvals', value: '6'),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(value, style: Theme.of(context).textTheme.headlineMedium),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}
