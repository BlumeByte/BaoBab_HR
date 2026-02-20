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
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('Employee Directory', style: Theme.of(context).textTheme.headlineSmall)),
              FilledButton.icon(
                onPressed: _showCreateEmployeeDialog,
                icon: const Icon(Icons.person_add_alt_1),
                label: const Text('Add employee'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text('Create employee records in Supabase and send login links for self-service access.'),
          const SizedBox(height: 20),
          if (_loading) const Expanded(child: Center(child: CircularProgressIndicator())),
          if (_error != null && !_loading) Expanded(child: Center(child: Text(_error!))),
          if (!_loading && _error == null)
            Expanded(
              child: Card(
                child: ListView.separated(
                  itemCount: _employees.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final employee = _employees[index];
                    return ListTile(
                      leading: CircleAvatar(backgroundImage: NetworkImage(employee.avatarUrl)),
                      title: Text(employee.fullName),
                      subtitle: Text('${employee.department} • ${employee.jobTitle}\n${employee.email}'),
                      isThreeLine: true,
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
