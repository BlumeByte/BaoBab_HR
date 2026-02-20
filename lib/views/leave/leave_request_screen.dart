import 'package:flutter/material.dart';

class LeaveRequestScreen extends StatelessWidget {
  const LeaveRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const requests = [
      ('Amina Yusuf', 'Annual Leave', 'Apr 10 - Apr 14', 'Approved'),
      ('Grace Kimani', 'Sick Leave', 'Mar 05', 'Pending'),
      ('Ravi Patel', 'Compassionate', 'Mar 18 - Mar 20', 'Needs review'),
    ];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Leave Management', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          const Text('Submit new requests, monitor balances, and process approvals from one place.'),
          const SizedBox(height: 20),
          Row(
            children: const [
              Expanded(child: _BalanceCard(label: 'Annual Leave', days: '12 days left')),
              SizedBox(width: 12),
              Expanded(child: _BalanceCard(label: 'Sick Leave', days: '5 days left')),
              SizedBox(width: 12),
              Expanded(child: _BalanceCard(label: 'Personal Leave', days: '2 days left')),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Card(
              child: ListView.separated(
                itemCount: requests.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final request = requests[index];
                  return ListTile(
                    leading: const Icon(Icons.event_note_outlined),
                    title: Text('${request.$1} • ${request.$2}'),
                    subtitle: Text(request.$3),
                    trailing: Chip(label: Text(request.$4)),
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

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.label, required this.days});

  final String label;
  final String days;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(days),
          ],
        ),
      ),
    );
  }
}
