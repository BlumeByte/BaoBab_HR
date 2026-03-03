import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/services/billing_service.dart';

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  final BillingService _billingService = BillingService();

  bool _loading = true;
  bool _processing = false;
  SubscriptionSnapshot? _subscription;
  List<Map<String, dynamic>> _history = const [];

  @override
  void initState() {
    super.initState();
    _verifyFromReturnUrl();
  }

  Future<void> _verifyFromReturnUrl() async {
    final reference = Uri.base.queryParameters['reference'];
    if (reference != null && reference.isNotEmpty) {
      try {
        await _billingService.verifyCheckout(reference: reference);
      } catch (_) {
        // Keep billing accessible even when verification fails.
      }
    }
    await _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final subscription = await _billingService.fetchCurrentSubscription();
    final history = await _billingService.fetchPaymentHistory();
    if (!mounted) return;
    setState(() {
      _subscription = subscription;
      _history = history;
      _loading = false;
    });
  }

  Future<void> _startCheckout(String plan) async {
    setState(() => _processing = true);
    try {
      final response = await _billingService.initializeCheckout(planName: plan);
      final url = response['authorization_url']?.toString();
      if (url != null && url.isNotEmpty) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      }
      await _load();
    } finally {
      if (mounted) {
        setState(() => _processing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sub = _subscription;

    return Scaffold(
      appBar: AppBar(title: const Text('Billing')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: ListTile(
                    title: Text('Plan: ${sub?.plan ?? 'Basic'}'),
                    subtitle: Text('Status: ${sub?.status ?? 'expired'}'),
                    trailing: Text('Expiry: ${sub?.expiresAt?.toIso8601String().split('T').first ?? 'N/A'}'),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final plan in const ['Basic', 'Pro', 'Enterprise'])
                      FilledButton(
                        onPressed: _processing ? null : () => _startCheckout(plan),
                        child: Text('Checkout $plan'),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                Text('Payment History', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                if (_history.isEmpty)
                  const Text('No payments yet.')
                else
                  ..._history.map(
                    (row) => Card(
                      child: ListTile(
                        title: Text('${row['currency'] ?? 'NGN'} ${row['amount'] ?? 0}'),
                        subtitle: Text('Status: ${row['status'] ?? 'pending'} • Ref: ${row['paystack_reference'] ?? '-'}'),
                        trailing: Text((row['paid_at'] ?? row['created_at'] ?? '').toString().split('T').first),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
