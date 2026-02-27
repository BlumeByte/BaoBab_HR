import 'package:flutter/material.dart';

import '../shared/module_screen_scaffold.dart';

// Import the employee service and model classes. These live
// outside the views directory and expose methods for fetching
// employee records from Supabase. Without these imports the
// compiler will complain that `EmployeeService` and `EmployeeRecord`
// are undefined. The relative paths here go up two directories
// (`../../`) because this file lives under `lib/views/employees`.
import '../../core/services/employee_service.dart';
import '../../models/employee_model.dart';

/// Displays an organizational chart for the current company.
///
/// This screen fetches all employees via [EmployeeService]
/// when it is first created. The data is stored in `_employees` and
/// presented in a series of statistics cards and a pie chart via
/// [ModuleScreenScaffold]. A quick action button shows a snackbar to
/// demonstrate where module‑specific actions could live.
class OrgChartScreen extends StatefulWidget {
  const OrgChartScreen({super.key});

  @override
  State<OrgChartScreen> createState() => _OrgChartScreenState();
}

class _OrgChartScreenState extends State<OrgChartScreen> {
  // Service used to query employee data from Supabase.
  final EmployeeService _employeeService = EmployeeService();
  // Indicates whether the screen is currently loading employee data.
  bool _loading = true;
  // Holds the list of employees returned from the service.
  List<EmployeeRecord> _employees = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// Loads the list of employees. If the call succeeds, update the
  /// local state with the returned rows and mark loading as false.
  /// On failure, still mark loading as false so the user sees an
  /// error state. Guard against updating state after disposal by
  /// checking [mounted].
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
    // Note: `_employees` and `_loading` are currently unused in this
    // scaffold. In a more complete implementation they could drive
    // a tree view or other visualization of the reporting structure.
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
