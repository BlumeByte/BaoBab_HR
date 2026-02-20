import 'package:flutter/material.dart';

import '../../core/services/employee_service.dart';
import '../../models/employee_model.dart';

class EmployeeProfileScreen extends StatefulWidget {
  const EmployeeProfileScreen({super.key});

  @override
  State<EmployeeProfileScreen> createState() => _EmployeeProfileScreenState();
}

class _EmployeeProfileScreenState extends State<EmployeeProfileScreen> {
  final _service = EmployeeService();
  EmployeeRecord? _employee;
  List<Map<String, dynamic>> _announcements = const [];
  List<Map<String, dynamic>> _leaveRequests = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final employee = await _service.fetchEmployeeForCurrentUser();
      final announcements = await _service.fetchAnnouncements();
      final leaveRequests = await _service.fetchLeaveRequestsForCurrentUser();
      if (!mounted) return;
      setState(() {
        _employee = employee;
        _announcements = announcements;
        _leaveRequests = leaveRequests;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Unable to load profile: $e';
        _loading = false;
      });
    }
  }

  Future<void> _requestLeave() async {
    final reasonController = TextEditingController();
    String leaveType = 'Annual';
    DateTimeRange? range;

    final submitted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setInnerState) => AlertDialog(
          title: const Text('Apply for leave'),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: leaveType,
                  items: const [
                    DropdownMenuItem(value: 'Annual', child: Text('Annual Leave')),
                    DropdownMenuItem(value: 'Maternity', child: Text('Maternity Leave')),
                    DropdownMenuItem(value: 'Sick', child: Text('Sick Leave')),
                    DropdownMenuItem(value: 'Compassionate', child: Text('Compassionate Leave')),
                    DropdownMenuItem(value: 'Other', child: Text('Other')),
                  ],
                  onChanged: (value) => setInnerState(() => leaveType = value ?? 'Annual'),
                  decoration: const InputDecoration(labelText: 'Leave type'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: reasonController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Reason'),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime.now().subtract(const Duration(days: 365)),
                        lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                      );
                      if (picked != null) setInnerState(() => range = picked);
                    },
                    icon: const Icon(Icons.date_range_outlined),
                    label: Text(
                      range == null
                          ? 'Select dates'
                          : '${range!.start.toLocal().toString().split(' ').first} - ${range!.end.toLocal().toString().split(' ').first}',
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                if (range == null) return;
                await _service.createLeaveRequest(
                  leaveType: leaveType,
                  startDate: range!.start,
                  endDate: range!.end,
                  reason: reasonController.text.trim(),
                );
                if (dialogContext.mounted) Navigator.pop(dialogContext, true);
              },
              child: const Text('Submit request'),
            ),
          ],
        ),
      ),
    );

    reasonController.dispose();

    if (submitted == true) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Leave request submitted to HR/Admin.')),
      );
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text(_error!));
    if (_employee == null) {
      return const Center(
        child: Text('No employee record found for this account. Ask HR to link your employee profile.'),
      );
    }

    final employee = _employee!;
    final approved = _leaveRequests.where((r) => (r['status'] ?? '').toString().toLowerCase() == 'approved').length;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: ListView(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundImage: employee.avatarUrl.isEmpty ? null : NetworkImage(employee.avatarUrl),
                child: employee.avatarUrl.isEmpty ? Text(employee.fullName[0]) : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(employee.fullName, style: Theme.of(context).textTheme.headlineSmall),
                    Text('${employee.jobTitle} • ${employee.department}'),
                    Text(employee.email),
                    if (employee.offerLetterUrl.isNotEmpty)
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.description_outlined),
                        label: const Text('Offer letter uploaded'),
                      ),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: _requestLeave,
                icon: const Icon(Icons.event_available_outlined),
                label: const Text('Apply for leave'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _InfoTile(title: 'Status', value: employee.status)),
              const SizedBox(width: 12),
              Expanded(child: _InfoTile(title: 'Approved leave requests', value: '$approved')),
              const SizedBox(width: 12),
              Expanded(child: _InfoTile(title: 'Total leave requests', value: '${_leaveRequests.length}')),
            ],
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('My leave requests', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  if (_leaveRequests.isEmpty)
                    const Text('No leave requests yet.')
                  else
                    ..._leaveRequests.take(8).map(
                          (request) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.beach_access_outlined),
                            title: Text('${request['leave_type'] ?? 'Leave'} • ${request['status'] ?? 'Pending'}'),
                            subtitle: Text(
                              '${request['start_date'] ?? ''} - ${request['end_date'] ?? ''}\nReason: ${request['reason'] ?? '-'}',
                            ),
                            isThreeLine: true,
                          ),
                        ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Company news', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  if (_announcements.isEmpty)
                    const Text('No news available.')
                  else
                    ..._announcements.map(
                      (item) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.campaign_outlined),
                        title: Text((item['title'] ?? 'Announcement').toString()),
                        subtitle: Text((item['content'] ?? item['description'] ?? '').toString()),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: Theme.of(context).textTheme.titleLarge),
            Text(title),
          ],
        ),
      ),
    );
  }
}
