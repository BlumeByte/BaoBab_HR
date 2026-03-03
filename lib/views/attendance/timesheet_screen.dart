import 'package:flutter/material.dart';

import '../../core/services/employee_service.dart';

class TimesheetScreen extends StatefulWidget {
  const TimesheetScreen({super.key});

  @override
  State<TimesheetScreen> createState() => _TimesheetScreenState();
}

class _TimesheetScreenState extends State<TimesheetScreen> {
  final _service = EmployeeService();
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _logs = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final logs = await _service.fetchAttendanceLogs(limit: 30);
      if (!mounted) return;
      setState(() => _logs = logs);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Unable to load attendance: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text(_error!));

    final presentToday = _logs.where((e) => e['status']?.toString() == 'present').length;
    final missingPunch = _logs.where((e) => e['check_in_at'] == null || e['check_out_at'] == null).length;

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Attendance & Timesheets', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          const Text('Review check-ins, detect anomalies, and track productive hours by team.'),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _KpiTile(label: 'Records Loaded', value: '${_logs.length}'),
              _KpiTile(label: 'Present', value: '$presentToday'),
              _KpiTile(label: 'Missing Punches', value: '$missingPunch'),
            ],
          ),
          const SizedBox(height: 20),
          if (_logs.isEmpty)
            const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('No attendance logs found.')))
          else
            Card(
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _logs.length,
                itemBuilder: (context, index) {
                  final log = _logs[index];
                  return ListTile(
                    leading: const Icon(Icons.schedule),
                    title: Text('${log['attendance_date']}'),
                    subtitle: Text('In: ${log['check_in_at'] ?? '-'} • Out: ${log['check_out_at'] ?? '-'}'),
                    trailing: Text((log['hours_worked'] ?? '-').toString()),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _KpiTile extends StatelessWidget {
  const _KpiTile({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Text(value, style: Theme.of(context).textTheme.titleLarge), Text(label)],
          ),
        ),
      ),
    );
  }
}
