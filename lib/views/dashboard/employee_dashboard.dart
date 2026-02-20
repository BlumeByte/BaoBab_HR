import 'package:flutter/material.dart';

import '../../core/services/employee_service.dart';
import '../../models/employee_model.dart';

class EmployeeDashboard extends StatefulWidget {
  const EmployeeDashboard({super.key});

  @override
  State<EmployeeDashboard> createState() => _EmployeeDashboardState();
}

class _EmployeeDashboardState extends State<EmployeeDashboard> {
  final _service = EmployeeService();
  EmployeeDashboardData? _data;
  bool _loading = true;
  String? _error;

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
      final data = await _service.fetchEmployeeDashboardData();
      if (!mounted) return;
      setState(() {
        _data = data;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Failed to load dashboard: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _clockIn() async {
    try {
      await _service.clockInForCurrentEmployee();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Clock-in saved. You are now active.')));
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Clock-in failed: $e')));
    }
  }

  Future<void> _clockOut() async {
    try {
      await _service.clockOutForCurrentEmployee();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Clock-out saved. Hours worked and days worked updated.')),
      );
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Clock-out failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text(_error!));
    if (_data == null) return const Center(child: Text('No employee data found for this user.'));

    final data = _data!;
    final employee = data.employee;
    final payroll = data.latestPayroll;
    final todayAttendance = data.todayAttendance;
    final status = (todayAttendance?['status'] ?? 'not logged in').toString();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: ListView(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: employee.avatarUrl.isEmpty ? null : NetworkImage(employee.avatarUrl),
                child: employee.avatarUrl.isEmpty ? Text(employee.fullName[0]) : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(employee.fullName, style: Theme.of(context).textTheme.headlineSmall),
                    Text('${employee.jobTitle} • ${employee.department}'),
                    Text(employee.email),
                  ],
                ),
              ),
              OutlinedButton.icon(onPressed: _clockIn, icon: const Icon(Icons.login), label: const Text('Log in to work')),
              const SizedBox(width: 8),
              FilledButton.icon(onPressed: _clockOut, icon: const Icon(Icons.logout), label: const Text('Log out from work')),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _StatCard(title: 'Attendance Status', value: status),
              _StatCard(title: 'Salary (Latest Net)', value: payroll == null ? '-' : ((payroll['net_pay'] ?? 0).toString())),
              _StatCard(title: 'Annual Leave Balance', value: data.leaveBalances['Annual']!.toStringAsFixed(1)),
              _StatCard(title: 'Sick Leave Balance', value: data.leaveBalances['Sick']!.toStringAsFixed(1)),
            ],
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('My Profile', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text('Employment status: ${employee.status}'),
                  Text('Offer letter uploaded: ${employee.offerLetterUrl.isNotEmpty ? 'Yes' : 'No'}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Payslips', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  if (data.payslips.isEmpty)
                    const Text('No payslips yet.')
                  else
                    ...data.payslips.map(
                      (p) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.receipt_long_outlined),
                        title: Text('${p['period_start']} to ${p['period_end']}'),
                        subtitle: Text('Basic: ${p['basic_salary'] ?? 0} | Allowances: ${p['allowances'] ?? 0} | Deductions: ${p['deductions'] ?? 0}'),
                        trailing: Text('Net: ${p['net_pay'] ?? 0}'),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Today Attendance', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  if (todayAttendance == null)
                    const Text('No attendance record yet for today.')
                  else ...[
                    Text('Check-in: ${todayAttendance['check_in_at'] ?? '-'}'),
                    Text('Check-out: ${todayAttendance['check_out_at'] ?? '-'}'),
                    Text('Hours worked: ${todayAttendance['hours_worked'] ?? '-'}'),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.title, required this.value});
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 230,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: Theme.of(context).textTheme.titleLarge),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }
}
