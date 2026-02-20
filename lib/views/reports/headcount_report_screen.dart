import 'package:flutter/material.dart';

class HeadcountReportScreen extends StatelessWidget {
  const HeadcountReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const departments = [
      ('Engineering', 42, 3),
      ('People Ops', 11, 1),
      ('Sales', 26, 4),
      ('Finance', 9, 0),
      ('Operations', 18, 2),
    ];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Reports', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          const Text('Headcount and hiring analytics snapshot by department.'),
          const SizedBox(height: 20),
          Row(
            children: const [
              Expanded(child: _SummaryTile(label: 'Total Headcount', value: '128')),
              SizedBox(width: 12),
              Expanded(child: _SummaryTile(label: 'Growth (QoQ)', value: '+8.4%')),
              SizedBox(width: 12),
              Expanded(child: _SummaryTile(label: 'Attrition', value: '2.1%')),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Card(
              child: ListView.builder(
                itemCount: departments.length,
                itemBuilder: (context, index) {
                  final row = departments[index];
                  return ListTile(
                    title: Text(row.$1),
                    subtitle: Text('Open roles: ${row.$3}'),
                    trailing: Text('${row.$2} employees'),
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

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Text(value, style: Theme.of(context).textTheme.titleLarge), Text(label)],
        ),
      ),
    );
  }
}
