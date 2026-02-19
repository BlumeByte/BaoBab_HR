import 'package:flutter/material.dart';

class TimesheetScreen extends StatelessWidget {
  const TimesheetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const logs = [
      ('Mon, Mar 4', '08:58', '17:31', '8h 33m'),
      ('Tue, Mar 5', '09:11', '18:02', '8h 51m'),
      ('Wed, Mar 6', '08:47', '17:15', '8h 28m'),
      ('Thu, Mar 7', '09:06', '17:44', '8h 38m'),
    ];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Attendance & Timesheets', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          const Text('Review check-ins, detect anomalies, and track productive hours by team.'),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: const [
              _KpiTile(label: 'Present Today', value: '111'),
              _KpiTile(label: 'Late Clock-ins', value: '7'),
              _KpiTile(label: 'Missing Punches', value: '3'),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Card(
              child: ListView.builder(
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  final log = logs[index];
                  return ListTile(
                    leading: const Icon(Icons.schedule),
                    title: Text(log.$1),
                    subtitle: Text('In: ${log.$2} • Out: ${log.$3}'),
                    trailing: Text(log.$4),
                  );
                },
              ),
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
