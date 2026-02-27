import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/employee_service.dart';
import '../../models/employee_model.dart';

class EmployeeDirectoryScreen extends StatefulWidget {
  const EmployeeDirectoryScreen({super.key});

  @override
  State<EmployeeDirectoryScreen> createState() =>
      _EmployeeDirectoryScreenState();
}

class _EmployeeDirectoryScreenState extends State<EmployeeDirectoryScreen> {
  final _service = EmployeeService();
  bool _loading = true;
  List<EmployeeRecord> _employees = [];
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
      final employees = await _service.fetchEmployees();
      if (!mounted) return;
      setState(() => _employees = employees);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Unable to load employees: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _showCreateEmployeeDialog() async {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final deptController = TextEditingController();
    final roleController = TextEditingController();
    final avatarController =
        TextEditingController(text: AppConstants.defaultAvatar);

    final created = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Employee'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Full Name')),
              TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email')),
              TextField(
                  controller: deptController,
                  decoration: const InputDecoration(labelText: 'Department')),
              TextField(
                  controller: roleController,
                  decoration: const InputDecoration(labelText: 'Job Title')),
              TextField(
                  controller: avatarController,
                  decoration: const InputDecoration(labelText: 'Avatar URL')),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              await _service.createEmployee(
                fullName: nameController.text.trim(),
                email: emailController.text.trim(),
                department: deptController.text.trim().isEmpty
                    ? 'General'
                    : deptController.text.trim(),
                jobTitle: roleController.text.trim().isEmpty
                    ? 'Employee'
                    : roleController.text.trim(),
                avatarUrl: avatarController.text.trim(),
              );
              await _service.sendLoginLink(emailController.text.trim());
              if (!context.mounted) return;
              Navigator.pop(context, true);
            },
            child: const Text('Create & Send Login Link'),
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Employee created and login link sent.')));
      await _loadEmployees();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text(_error!));

    final active =
        _employees.where((e) => e.status.toLowerCase() == 'active').length;
    final departments = _employees.map((e) => e.department).toSet().length;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Employee Directory',
                        style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    Text(
                        'Search teammates, review departments, and quickly access employee profiles.',
                        style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: _showCreateEmployeeDialog,
                icon: const Icon(Icons.person_add_alt_1),
                label: const Text('Add Employee'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _StatCard(
                  title: 'Total Employees',
                  value: '${_employees.length}',
                  icon: Icons.people_alt_outlined),
              _StatCard(
                  title: 'Active',
                  value: '$active',
                  icon: Icons.verified_user_outlined),
              _StatCard(
                  title: 'Departments',
                  value: '$departments',
                  icon: Icons.apartment_outlined),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Card(
              child: _employees.isEmpty
                  ? const Center(child: Text('No employees found.'))
                  : ListView.separated(
                      itemCount: _employees.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final employee = _employees[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: employee.avatarUrl.isEmpty
                                ? null
                                : NetworkImage(employee.avatarUrl),
                            child: employee.avatarUrl.isEmpty
                                ? Text(employee.fullName.isEmpty
                                    ? 'E'
                                    : employee.fullName[0])
                                : null,
                          ),
                          title: Text(employee.fullName),
                          subtitle: Text(
                              '${employee.department} • ${employee.jobTitle}\n${employee.email}'),
                          trailing: Chip(label: Text(employee.status)),
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
  const _StatCard(
      {required this.title, required this.value, required this.icon});

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
