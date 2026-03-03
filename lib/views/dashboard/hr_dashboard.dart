import 'package:flutter/material.dart';

import '../shared/module_screen_scaffold.dart';

class HrDashboard extends StatelessWidget {
  const HrDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return ModuleScreenScaffold(
      title: 'HR Dashboard',
      description: 'Monitor workforce status, pending approvals, and operational KPIs.',
      stats: const [
        StatItem('Employees', '128', Icons.groups_outlined),
        StatItem('Pending Leaves', '14', Icons.pending_actions_outlined),
        StatItem('Attendance Today', '92%', Icons.access_time_outlined),
      ],
      pieData: const [
        PieSliceData(label: 'Present', value: 92, color: Colors.blue),
        PieSliceData(label: 'Late', value: 5, color: Colors.orange),
        PieSliceData(label: 'Absent', value: 3, color: Colors.redAccent),
      ],
      highlights: const [
        'Centralized view for leave and attendance decisions.',
        'Recruitment and onboarding workflow visibility.',
        'Compliance and policy adherence checks in one place.',
      ],
      primaryAction: FilledButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.rule_folder_outlined),
        label: const Text('Review approvals'),
      ),
    );
  }
}
