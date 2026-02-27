import 'package:flutter/material.dart';

import '../../core/services/employee_service.dart';
import '../../core/services/supabase_service.dart';
import '../../models/employee_model.dart';

class EmployeeProfileScreen extends StatefulWidget {
  const EmployeeProfileScreen({super.key});

  @override
  State<EmployeeProfileScreen> createState() => _EmployeeProfileScreenState();
}

class _EmployeeProfileScreenState extends State<EmployeeProfileScreen> {
  final _service = EmployeeService();
  EmployeeRecord? _employee;
  bool _loading = true;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _load();
  }

  Future<void> _load() async {
    if (!_loading) return;
    try {
      final email = SupabaseService.client.auth.currentUser?.email;
      if (email == null || email.isEmpty) {
        setState(() {
          _error = 'Missing employee email.';
          _loading = false;
        });
        return;
      }

      final result = await _service.fetchEmployeeByEmail(email);
      setState(() {
        _employee = result;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Unable to load profile: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Text(_error!));
    }

    if (_employee == null) {
      return const Center(child: Text('No employee record found for your account yet.'));
    }

    final employee = _employee!;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(radius: 34, backgroundImage: NetworkImage(employee.avatarUrl)),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(employee.fullName, style: Theme.of(context).textTheme.headlineSmall),
                      Text(employee.email),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text('Department: ${employee.department}'),
              const SizedBox(height: 8),
              Text('Job Title: ${employee.jobTitle}'),
              const SizedBox(height: 8),
              Text('Employment Status: ${employee.status}'),
            ],
          ),
        ),
      ),
    );
  }
}
