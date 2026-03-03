import 'package:flutter/material.dart';

class JobsScreen extends StatelessWidget {
  const JobsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const jobs = [
      ('Senior Flutter Engineer', 'Engineering', '12 applicants', 'Interviewing'),
      ('HR Generalist', 'People Ops', '8 applicants', 'Screening'),
      ('Account Executive', 'Sales', '17 applicants', 'Offer stage'),
    ];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recruitment', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          const Text('Manage open positions, candidate funnels, and hiring pipeline health.'),
          const SizedBox(height: 20),
          Expanded(
            child: Card(
              child: ListView.builder(
                itemCount: jobs.length,
                itemBuilder: (context, index) {
                  final job = jobs[index];
                  return ListTile(
                    leading: const Icon(Icons.work_outline),
                    title: Text(job.$1),
                    subtitle: Text('${job.$2} • ${job.$3}'),
                    trailing: Chip(label: Text(job.$4)),
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
