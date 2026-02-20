import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/services/employee_service.dart';
import '../../models/employee_model.dart';

class EmployeeDirectoryScreen extends StatefulWidget {
  const EmployeeDirectoryScreen({super.key});

  @override
  State<EmployeeDirectoryScreen> createState() => _EmployeeDirectoryScreenState();
}

class _EmployeeDirectoryScreenState extends State<EmployeeDirectoryScreen> {
  final _service = EmployeeService();
  bool _loading = true;
  List<EmployeeRecord> _employees = const [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  Future<void> _loadEmployees() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _service.fetchEmployees();
      setState(() {
        _employees = data;
      });
    } catch (e) {
      setState(() {
        _error = 'Unable to fetch employees. Please verify Supabase table permissions. ($e)';
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _showCreateEmployeeDialog() async {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final deptController = TextEditingController();
    final roleController = TextEditingController();
    final avatarController = TextEditingController(text: AppConstants.defaultAvatar);

    final created = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create employee'),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Full name')),
              TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Work email')),
              TextField(controller: deptController, decoration: const InputDecoration(labelText: 'Department')),
              TextField(controller: roleController, decoration: const InputDecoration(labelText: 'Job title')),
              TextField(controller: avatarController, decoration: const InputDecoration(labelText: 'Avatar URL')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              try {
                await _service.createEmployee(
                  fullName: nameController.text,
                  email: emailController.text,
                  department: deptController.text,
                  jobTitle: roleController.text,
                  avatarUrl: avatarController.text,
                );
                await _service.sendLoginLink(emailController.text.trim());
                if (context.mounted) Navigator.pop(context, true);
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to create employee: $e')),
                );
              }
            },
            child: const Text('Save & send login'),
          ),
        ],
      ),
    );

    nameController.dispose();
    emailController.dispose();
    deptController.dispose();
    roleController.dispose();
    avatarController.dispose();

    if (created == true) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Employee created and login link sent.')),
      );
      await _loadEmployees();
    }
  }

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
