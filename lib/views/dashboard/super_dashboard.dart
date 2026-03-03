import 'package:flutter/material.dart';

import '../../core/services/super_admin_service.dart';

class SuperDashboard extends StatefulWidget {
  const SuperDashboard({super.key});

  @override
  State<SuperDashboard> createState() => _SuperDashboardState();
}

class _SuperDashboardState extends State<SuperDashboard> {
  final _service = SuperAdminService();
  SuperAdminMetrics? _metrics;
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
      final metrics = await _service.fetchGlobalMetrics();
      if (!mounted) return;
      setState(() => _metrics = metrics);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Unable to load super admin metrics: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text(_error!));

    final metrics = _metrics;
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Super Admin Dashboard', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          const Text('Cross-company controls, tenant analytics, and platform governance.'),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _MetricCard(label: 'Companies', value: '${metrics?.totalCompanies ?? 0}', icon: Icons.apartment_outlined),
              _MetricCard(label: 'Active Subs', value: '${metrics?.activeSubscriptions ?? 0}', icon: Icons.verified_outlined),
              _MetricCard(label: 'Employees', value: '${metrics?.totalEmployees ?? 0}', icon: Icons.groups_outlined),
              _MetricCard(label: 'Monthly Revenue', value: '${metrics?.monthlyRevenue.toStringAsFixed(2) ?? '0.00'}', icon: Icons.payments_outlined),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value, required this.icon});

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
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
