import 'package:flutter/material.dart';

import '../shared/module_screen_scaffold.dart';

// Import the SuperAdminService from the core services layer. This
// service exposes a `fetchAuditLogs` method used by the state class
// below. Without this import the compiler would complain that
// `SuperAdminService` is undefined. The relative path goes up two
// directories because this file lives under `lib/views/settings`.
import '../../core/services/super_admin_service.dart';

/// Displays a paginated list of audit logs for the super admin.
///
/// This screen uses a [StatefulWidget] so that it can manage
/// asynchronous loading of data via [SuperAdminService.fetchAuditLogs].
/// The `_rows` list holds the fetched audit entries and `_loading`
/// flags whether the data is still being loaded. Currently the
/// list of rows is unused in the UI scaffold; in a complete
/// implementation you would display the logs in a table or list.
class AuditLogsScreen extends StatefulWidget {
  const AuditLogsScreen({super.key});

  @override
  State<AuditLogsScreen> createState() => _AuditLogsScreenState();
}

class _AuditLogsScreenState extends State<AuditLogsScreen> {
  final SuperAdminService _service = SuperAdminService();
  bool _loading = true;
  List<Map<String, dynamic>> _rows = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final rows = await _service.fetchAuditLogs();
      if (!mounted) return;
      setState(() {
        _rows = rows;
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
      title: 'Audit Logs',
      description: 'Review configuration and data-access changes in a single log.',
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