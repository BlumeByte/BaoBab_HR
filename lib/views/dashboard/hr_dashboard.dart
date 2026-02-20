import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/services/employee_service.dart';
import '../../core/services/supabase_service.dart';

class HrDashboard extends StatefulWidget {
  const HrDashboard({super.key});

  @override
  State<HrDashboard> createState() => _HrDashboardState();
}

class _HrDashboardState extends State<HrDashboard> {
  final _service = EmployeeService();
  HrDashboardStats? _stats;
  List<Map<String, dynamic>> _attendance = const [];
  List<Map<String, dynamic>> _pendingLeaves = const [];
  bool _loading = true;
  String? _error;
  RealtimeChannel? _channel;

  @override
  void initState() {
    super.initState();
    _load();
    _subscribeRealtime();
  }

  void _subscribeRealtime() {
    _channel = SupabaseService.client.channel('hr-live-updates')
      ..onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'attendance',
        callback: (_) => _load(),
      )
      ..onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'leaves',
        callback: (_) => _load(),
      )
      ..onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'leave_requests',
        callback: (_) => _load(),
      )
      ..subscribe();
  }

  @override
  void dispose() {
    if (_channel != null) {
      SupabaseService.client.removeChannel(_channel!);
    }
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final stats = await _service.fetchHrDashboardStats();
      final attendance = await _service.fetchAttendanceLogs(limit: 15);
      final pending = await _service.fetchPendingLeaves(limit: 15);
      if (!mounted) return;
      setState(() {
        _stats = stats;
        _attendance = attendance;
        _pendingLeaves = pending;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Failed to load HR dashboard: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _approveLeave(String leaveId) async {
    try {
      await _service.approveLeave(leaveId: leaveId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Leave approved successfully.')));
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Approve leave failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text(_error!));

    final stats = _stats!;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('HR Dashboard', style: Theme.of(context).textTheme.headlineSmall)),
              FilledButton.icon(onPressed: _load, icon: const Icon(Icons.refresh), label: const Text('Refresh')),
            ],
          ),
          const SizedBox(height: 8),
          const Text('Real-time workforce metrics and HR operations from Supabase.'),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _StatCard(label: 'Total Employees', value: '${stats.totalEmployees}', icon: Icons.people_outline),
              _StatCard(label: 'Present Today', value: '${stats.presentToday}', icon: Icons.check_circle_outline),
              _StatCard(label: 'Absent Today', value: '${stats.absentToday}', icon: Icons.cancel_outlined),
              _StatCard(label: 'Payroll Total', value: stats.payrollTotal.toStringAsFixed(2), icon: Icons.payments_outlined),
              _StatCard(label: 'Leave Pending', value: '${stats.leavePending}', icon: Icons.pending_actions_outlined),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Row(
              children: [
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
                                ? const Center(child: Text('No attendance logs found.'))
                                : ListView.builder(
                                    itemCount: _attendance.length,
                                    itemBuilder: (context, i) {
                                      final row = _attendance[i];
                                      final employee = row['employees'] as Map<String, dynamic>?;
                                      return ListTile(
                                        leading: const Icon(Icons.access_time),
                                        title: Text(employee?['full_name']?.toString() ?? row['employee_id'].toString()),
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
                const SizedBox(width: 12),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Pending Leave Approvals', style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          Expanded(
                            child: _pendingLeaves.isEmpty
                                ? const Center(child: Text('No pending leave requests.'))
                                : ListView.builder(
                                    itemCount: _pendingLeaves.length,
                                    itemBuilder: (context, i) {
                                      final row = _pendingLeaves[i];
                                      final employee = row['employees'] as Map<String, dynamic>?;
                                      return ListTile(
                                        leading: const Icon(Icons.event_note_outlined),
                                        title: Text(employee?['full_name']?.toString() ?? row['employee_id'].toString()),
                                        subtitle: Text(
                                          '${row['leave_type']} • ${row['start_date']} to ${row['end_date']}\nReason: ${row['reason'] ?? '-'}',
                                        ),
                                        isThreeLine: true,
                                        trailing: FilledButton(
                                          onPressed: () => _approveLeave(row['id'].toString()),
                                          child: const Text('Approve'),
                                        ),
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

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.icon});

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(icon),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value, style: Theme.of(context).textTheme.titleLarge),
                  Text(label),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
