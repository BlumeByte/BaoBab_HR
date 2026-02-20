import 'package:flutter/material.dart';

import '../shared/module_screen_scaffold.dart';

class SuperDashboard extends StatelessWidget {
  const SuperDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return ModuleScreenScaffold(
      title: 'Super Admin Dashboard',
      description: 'Cross-company controls, tenant analytics, and platform-wide governance.',
      stats: const [
        StatItem('Companies', '42', Icons.apartment_outlined),
        StatItem('Active Subscriptions', '37', Icons.verified_outlined),
        StatItem('Platform MRR', '\$24,980', Icons.payments_outlined),
      ],
      pieData: const [
        PieSliceData(label: 'Active', value: 37, color: Colors.blue),
        PieSliceData(label: 'Trial', value: 4, color: Colors.lightBlue),
        PieSliceData(label: 'Expired', value: 1, color: Colors.orange),
      ],
      highlights: const [
        'Monitor all tenant companies from one secure dashboard.',
        'Track subscription health and payment conversion.',
        'Review audit and compliance posture at platform level.',
      ],
      primaryAction: FilledButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.admin_panel_settings_outlined),
        label: const Text('Manage platform'),
      ),
    );
  }
}
