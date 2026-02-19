import 'package:flutter/material.dart';

class EmployeeDirectoryScreen extends StatelessWidget {
  const EmployeeDirectoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const employees = [
      ('Amina Yusuf', 'Engineering', 'Senior Developer', 'Active'),
      ('Kofi Mensah', 'People Ops', 'HR Business Partner', 'Active'),
      ('Grace Kimani', 'Finance', 'Payroll Specialist', 'On Leave'),
      ('Ravi Patel', 'Sales', 'Account Executive', 'Probation'),
    ];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Employee Directory', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Search teammates, review departments, and quickly access employee profiles.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: const [
              _StatCard(title: 'Total Employees', value: '128', icon: Icons.people_alt_outlined),
              _StatCard(title: 'Departments', value: '9', icon: Icons.apartment_outlined),
              _StatCard(title: 'Open Onboarding', value: '6', icon: Icons.fact_check_outlined),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Card(
              child: ListView.separated(
                itemCount: employees.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final employee = employees[index];
                  return ListTile(
                    leading: CircleAvatar(child: Text(employee.$1.substring(0, 1))),
                    title: Text(employee.$1),
                    subtitle: Text('${employee.$2} • ${employee.$3}'),
                    trailing: Chip(label: Text(employee.$4)),
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

class _StatCard extends StatelessWidget {
  const _StatCard({required this.title, required this.value, required this.icon});

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value, style: Theme.of(context).textTheme.titleLarge),
                  Text(title),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
