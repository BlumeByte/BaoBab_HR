import 'package:flutter/material.dart';

import '../shared/module_screen_scaffold.dart';

class OrgChartScreen extends StatelessWidget {
  const OrgChartScreen({super.key});

  @override
  State<OrgChartScreen> createState() => _OrgChartScreenState();
}

class _OrgChartScreenState extends State<OrgChartScreen> {
  final EmployeeService _employeeService = EmployeeService();
  bool _loading = true;
  List<EmployeeRecord> _employees = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final rows = await _employeeService.fetchEmployees();
      if (!mounted) return;
      setState(() {
        _employees = rows;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ModuleScreenScaffold(
      title: 'Organization Chart',
      description: 'Visualize reporting lines and department structures.',
      stats: const [
        StatItem('Active', '128', Icons.groups_outlined),
        StatItem('Pending', '14', Icons.pending_actions_outlined),
        StatItem('Completed', '86%', Icons.task_alt_outlined),
      ],
      pieData: const [
        PieSliceData(label: 'Completed', value: 58, color: Colors.blue),
        PieSliceData(label: 'In Progress', value: 28, color: Colors.lightBlue),
        PieSliceData(label: 'Pending', value: 14, color: Colors.orange),
      ],
      highlights: const [
        'Automated workflows reduce manual processing time.',
        'Critical tasks are now grouped and prioritized.',
        'Insights are ready for provider and API integration.',
      ],
      primaryAction: FilledButton.icon(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Action executed successfully.')),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Quick action'),
      ),
    );
  }
}
