import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../shared/module_screen_scaffold.dart';

import '../../core/services/billing_service.dart';

class CompanySetupWizard extends StatefulWidget {
  const CompanySetupWizard({super.key});

  @override
  State<CompanySetupWizard> createState() => _CompanySetupWizardState();
}

class _CompanySetupWizardState extends State<CompanySetupWizard> {
  final BillingService _billingService = BillingService();
  String _selectedPlan = 'Basic';
  bool _submitting = false;

  Future<void> _continueToPayment() async {
    setState(() => _submitting = true);
    try {
      final checkout = await _billingService.initializeCheckout(planName: _selectedPlan);
      final authorizationUrl = checkout['authorization_url']?.toString();
      if (authorizationUrl != null && authorizationUrl.isNotEmpty) {
        await launchUrl(Uri.parse(authorizationUrl), mode: LaunchMode.externalApplication);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Checkout created. Complete payment and return to Billing.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to start Paystack checkout.')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ModuleScreenScaffold(
      title: 'Company Setup Wizard',
      description: 'Complete initial organization setup and operational defaults.',
      stats: const [
        StatItem('Active', '128', Icons.groups_outlined),
        StatItem('Pending', '14', Icons.pending_actions_outlined),
        StatItem('Completed', '86%', Icons.task_alt_outlined),
      ],
      pieData: const [
        PieSliceData(label: 'Completed', value: 58, color: Colors.blue),
        PieSliceData(label: 'In Progress', value: 28, color: Colors.lightBlue),
        PieSliceData(label: 'Pending', value: 14, color: Colors.orange),
      ],
      highlights: const [
        'Automated workflows reduce manual processing time.',
        'Critical tasks are now grouped and prioritized.',
        'Insights are ready for provider and API integration.',
      ],
      primaryAction: FilledButton.icon(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Action executed successfully.')),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Quick action'),
      ),
    );
  }
}
