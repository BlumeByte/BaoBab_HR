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
  List<Map<String, dynamic>> _attendance = const [];
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
      final employees = await _service.fetchEmployees();
      final attendance = await _service.fetchAttendanceLogs(limit: 20);
      if (!mounted) return;
      setState(() {
        _employees = employees;
        _attendance = attendance;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Unable to load employee data: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _showEmployeeForm({EmployeeRecord? employee}) async {
    final name = TextEditingController(text: employee?.fullName ?? '');
    final email = TextEditingController(text: employee?.email ?? '');
    final department = TextEditingController(text: employee?.department ?? '');
    final title = TextEditingController(text: employee?.jobTitle ?? '');
    final avatar = TextEditingController(text: employee?.avatarUrl.isEmpty == true ? AppConstants.defaultAvatar : (employee?.avatarUrl ?? AppConstants.defaultAvatar));
    final status = ValueNotifier<String>((employee?.status ?? 'active').toLowerCase());

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(employee == null ? 'Add Employee' : 'Edit Employee'),
        content: SizedBox(
          width: 460,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: name, decoration: const InputDecoration(labelText: 'Full name')),
                TextField(controller: email, decoration: const InputDecoration(labelText: 'Work email')),
                TextField(controller: department, decoration: const InputDecoration(labelText: 'Department')),
                TextField(controller: title, decoration: const InputDecoration(labelText: 'Job title')),
                TextField(controller: avatar, decoration: const InputDecoration(labelText: 'Profile image URL')),
                const SizedBox(height: 8),
                ValueListenableBuilder<String>(
                  valueListenable: status,
                  builder: (_, value, __) => DropdownButtonFormField<String>(
                    value: value,
                    items: const [
                      DropdownMenuItem(value: 'active', child: Text('Active')),
                      DropdownMenuItem(value: 'on_leave', child: Text('On Leave')),
                      DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                    ],
                    onChanged: (v) => status.value = v ?? 'active',
                    decoration: const InputDecoration(labelText: 'Status'),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              try {
                if (employee == null) {
                  await _service.createEmployee(
                    fullName: name.text.trim(),
                    email: email.text.trim(),
                    department: department.text.trim(),
                    jobTitle: title.text.trim(),
                    avatarUrl: avatar.text.trim(),
                  );
                  await _service.sendPasswordSetupLink(email.text.trim());
                } else {
                  await _service.updateEmployee(
                    employeeId: employee.id,
                    fullName: name.text.trim(),
                    email: email.text.trim(),
                    department: department.text.trim(),
                    jobTitle: title.text.trim(),
                    status: status.value,
                    avatarUrl: avatar.text.trim(),
                  );
                }
                if (dialogContext.mounted) Navigator.pop(dialogContext, true);
              } catch (e) {
                if (!dialogContext.mounted) return;
                ScaffoldMessenger.of(dialogContext).showSnackBar(SnackBar(content: Text('Save failed: $e')));
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    name.dispose();
    email.dispose();
    department.dispose();
    title.dispose();
    avatar.dispose();
    status.dispose();

    if (saved == true) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(employee == null ? 'Employee added successfully.' : 'Employee updated successfully.')),
      );
      await _load();
    }
  }

  Future<void> _deleteEmployee(EmployeeRecord employee) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete employee'),
        content: Text('Are you sure you want to delete ${employee.fullName}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirm != true) return;
    try {
      await _service.deleteEmployee(employee.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Employee deleted.')));
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
    }
  }

  Future<void> _showPayrollDialog(EmployeeRecord employee) async {
    final salary = TextEditingController(text: '0');
    final allowances = TextEditingController(text: '0');
    final deductions = TextEditingController(text: '0');
    final taxes = TextEditingController(text: '0');
    final daysWorked = TextEditingController(text: '22');

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Payroll — ${employee.fullName}'),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: salary, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Basic salary')),
              TextField(controller: allowances, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Allowances')),
              TextField(controller: deductions, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Deductions')),
              TextField(controller: taxes, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Taxes')),
              TextField(controller: daysWorked, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Days worked')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              try {
                final now = DateTime.now();
                await _service.addOrUpdatePayroll(
                  employeeId: employee.id,
                  periodStart: DateTime(now.year, now.month, 1),
                  periodEnd: DateTime(now.year, now.month + 1, 0),
                  basicSalary: double.tryParse(salary.text) ?? 0,
                  allowances: double.tryParse(allowances.text) ?? 0,
                  deductions: double.tryParse(deductions.text) ?? 0,
                  taxes: double.tryParse(taxes.text) ?? 0,
                  daysWorked: int.tryParse(daysWorked.text) ?? 0,
                );
                if (context.mounted) Navigator.pop(context, true);
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Payroll save failed: $e')));
              }
            },
            child: const Text('Save payroll'),
          ),
        ],
      ),
    );

    salary.dispose();
    allowances.dispose();
    deductions.dispose();
    taxes.dispose();
    daysWorked.dispose();

    if (saved == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payroll saved successfully.')));
    }
  }

  Future<void> _addDaysWorked(EmployeeRecord employee) async {
    DateTime selectedDate = DateTime.now();
    String status = 'present';

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setInnerState) => AlertDialog(
          title: Text('Add attendance — ${employee.fullName}'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('Attendance date'),
                  subtitle: Text(selectedDate.toIso8601String().split('T').first),
                  trailing: const Icon(Icons.date_range),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) setInnerState(() => selectedDate = picked);
                  },
                ),
                DropdownButtonFormField<String>(
                  value: status,
                  items: const [
                    DropdownMenuItem(value: 'present', child: Text('Present')),
                    DropdownMenuItem(value: 'absent', child: Text('Absent')),
                    DropdownMenuItem(value: 'late', child: Text('Late')),
                  ],
                  onChanged: (v) => setInnerState(() => status = v ?? 'present'),
                  decoration: const InputDecoration(labelText: 'Status'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                try {
                  await _service.addAttendanceLog(employeeId: employee.id, date: selectedDate, status: status);
                  if (dialogContext.mounted) Navigator.pop(dialogContext, true);
                } catch (e) {
                  if (!dialogContext.mounted) return;
                  ScaffoldMessenger.of(dialogContext).showSnackBar(SnackBar(content: Text('Attendance save failed: $e')));
                }
              },
              child: const Text('Save attendance'),
            ),
          ],
        ),
      ),
    );

    if (saved == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Attendance updated.')));
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text(_error!));

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('Employee Management', style: Theme.of(context).textTheme.headlineSmall)),
              OutlinedButton.icon(onPressed: _load, icon: const Icon(Icons.refresh), label: const Text('Refresh')),
              const SizedBox(width: 8),
              FilledButton.icon(onPressed: () => _showEmployeeForm(), icon: const Icon(Icons.person_add), label: const Text('Add employee')),
            ],
          ),
          const SizedBox(height: 8),
          const Text('Add, edit, delete employees, manage salary details, allowances, deductions, departments and days worked.'),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Card(
                    child: ListView.separated(
                      itemCount: _employees.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final e = _employees[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: e.avatarUrl.isEmpty ? null : NetworkImage(e.avatarUrl),
                            child: e.avatarUrl.isEmpty ? Text(e.fullName.isEmpty ? '?' : e.fullName[0]) : null,
                          ),
                          title: Text(e.fullName),
                          subtitle: Text('${e.department} • ${e.jobTitle}\n${e.email}'),
                          isThreeLine: true,
                          trailing: Wrap(
                            spacing: 8,
                            children: [
                              IconButton(onPressed: () => _showEmployeeForm(employee: e), icon: const Icon(Icons.edit_outlined), tooltip: 'Edit employee'),
                              IconButton(onPressed: () => _showPayrollDialog(e), icon: const Icon(Icons.payments_outlined), tooltip: 'Salary/allowances/deductions'),
                              IconButton(onPressed: () => _addDaysWorked(e), icon: const Icon(Icons.calendar_month_outlined), tooltip: 'Add days worked'),
                              IconButton(onPressed: () => _deleteEmployee(e), icon: const Icon(Icons.delete_outline), tooltip: 'Delete employee'),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Attendance Logs', style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          Expanded(
                            child: _attendance.isEmpty
                                ? const Center(child: Text('No attendance logs available.'))
                                : ListView.builder(
                                    itemCount: _attendance.length,
                                    itemBuilder: (context, i) {
                                      final row = _attendance[i];
                                      final emp = row['employees'] as Map<String, dynamic>?;
                                      return ListTile(
                                        dense: true,
                                        title: Text(emp?['full_name']?.toString() ?? row['employee_id'].toString()),
                                        subtitle: Text('${row['attendance_date']} • ${row['status']}'),
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
