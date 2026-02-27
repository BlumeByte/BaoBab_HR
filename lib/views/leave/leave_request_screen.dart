import 'package:flutter/material.dart';
import '../../core/services/employee_service.dart';
import '../../models/leave_model.dart';
import '../../core/services/supabase_service.dart';

class LeaveRequestScreen extends StatefulWidget {
  const LeaveRequestScreen({super.key});

  @override
  State<LeaveRequestScreen> createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends State<LeaveRequestScreen> {
  final _service = EmployeeService();
  bool _loading = true;
  String? _error;

  List<LeaveRecord> _pendingLeaves = [];
  List<LeaveRecord> _myLeaves = [];

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
      final email = SupabaseService.client.auth.currentUser?.email ?? '';
      if (email.isEmpty) {
        setState(() {
          _error = 'Unable to determine your email.';
          _loading = false;
        });
        return;
      }

      // Fetch leaves from Supabase via typed methods
      final pending = await _service.fetchPendingLeaves(limit: 20);
      final mine = await _service.fetchMyLeaves(email, limit: 20);

      if (!mounted) return;
      setState(() {
        _pendingLeaves = pending;
        _myLeaves = mine;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Unable to load leave records: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text(_error!));

    final approvedCount =
        _myLeaves.where((e) => e.status.toLowerCase() == 'approved').length;

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Leave Management',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          const Text(
              'Track personal leave requests and company-wide pending approvals.'),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                  child: _BalanceCard(
                      label: 'My Requests',
                      days: '${_myLeaves.length} records')),
              const SizedBox(width: 12),
              Expanded(
                  child: _BalanceCard(
                      label: 'Pending Approvals',
                      days: '${_pendingLeaves.length} pending')),
              const SizedBox(width: 12),
              Expanded(
                  child: _BalanceCard(
                      label: 'Approved (Mine)', days: '$approvedCount')),
            ],
          ),
          const SizedBox(height: 20),
          Text('My Leave Requests',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: _myLeaves.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No leave requests found.'))
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _myLeaves.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final leave = _myLeaves[index];
                      return ListTile(
                        leading: const Icon(Icons.event_note_outlined),
                        title: Text(
                            '${leave.leaveType} • ${leave.startDate} → ${leave.endDate}'),
                        subtitle:
                            Text(leave.reason.isEmpty ? '-' : leave.reason),
                        trailing: Chip(label: Text(leave.status)),
                      );
                    },
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
            Text(days, style: Theme.of(context).textTheme.titleLarge),
            Text(label),
          ],
        ),
      ),
    );
  }
}
