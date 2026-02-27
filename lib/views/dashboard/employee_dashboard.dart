import 'package:flutter/material.dart';

import '../shared/module_screen_scaffold.dart';

/// Dashboard for regular employees.
///
/// Displays summary statistics, a pie chart of progress and a set of
/// highlights relevant to the logged in employee. This widget is
/// implemented as a [StatelessWidget] because it does not manage any
/// internal state and simply renders static UI elements.
class EmployeeDashboard extends StatelessWidget {
  const EmployeeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return ModuleScreenScaffold(
      title: 'Employee Dashboard',
      description:
          'View your leave, attendance, payroll highlights, and personal tasks.',
      stats: const [
        StatItem('Attendance', 'Present', Icons.event_available_outlined),
        StatItem('Leave Balance', '12 days', Icons.beach_access_outlined),
        StatItem('Tasks Due', '3', Icons.task_outlined),
      ],
      pieData: const [
        PieSliceData(label: 'Completed', value: 70, color: Colors.blue),
        PieSliceData(label: 'In Progress', value: 20, color: Colors.lightBlue),
        PieSliceData(label: 'Pending', value: 10, color: Colors.orange),
      ],
      highlights: const [
        'Track your daily attendance and timesheet status.',
        'See leave balance and upcoming approvals.',
        'Quickly navigate to your profile and documents.',
      ],
      primaryAction: FilledButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.person_outline),
        label: const Text('Open my profile'),
      ),
    );
  }
}
