import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_service.dart';

class SubscriptionSnapshot {
  const SubscriptionSnapshot({
    required this.plan,
    required this.status,
    required this.expiresAt,
    required this.isActive,
  });

  final String plan;
  final String status;
  final DateTime? expiresAt;
  final bool isActive;

  factory SubscriptionSnapshot.fromMap(Map<String, dynamic> row) {
    final status = (row['status'] ?? 'expired').toString().toLowerCase();
    final endsAtRaw = row['ends_at'] ?? row['trial_end_at'];
    final expiresAt = endsAtRaw == null ? null : DateTime.tryParse(endsAtRaw.toString());

    return SubscriptionSnapshot(
      plan: (row['plan_name'] ?? 'Basic').toString(),
      status: status,
      expiresAt: expiresAt,
      isActive: {'active', 'trial'}.contains(status),
    );
  }
}

class BillingService {
  BillingService({SupabaseClient? client}) : _client = client ?? SupabaseService.client;

  final SupabaseClient _client;

  Future<Map<String, dynamic>?> _currentUserRow() async {
    final authUser = _client.auth.currentUser;
    if (authUser == null) return null;
    return _client.from('users').select('id, company_id, email').eq('auth_user_id', authUser.id).maybeSingle();
  }

  Future<SubscriptionSnapshot?> fetchCurrentSubscription() async {
    final user = await _currentUserRow();
    if (user == null) return null;

    final rows = await _client
        .from('subscriptions')
        .select('plan_name,status,trial_end_at,ends_at,created_at')
        .eq('company_id', user['company_id'])
        .order('created_at', ascending: false)
        .limit(1);

    if ((rows as List).isEmpty) return null;
    return SubscriptionSnapshot.fromMap((rows).first as Map<String, dynamic>);
  }

  Future<List<Map<String, dynamic>>> fetchPaymentHistory() async {
    final user = await _currentUserRow();
    if (user == null) return const [];

    final rows = await _client
        .from('payments')
        .select('id,amount,currency,status,payment_provider,paystack_reference,paid_at,created_at')
        .eq('company_id', user['company_id'])
        .order('created_at', ascending: false)
        .limit(50);

    return (rows as List).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> initializeCheckout({required String planName}) async {
    final payload = {'plan': planName};
    final response = await _client.functions.invoke('paystack-initialize', body: payload);
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw StateError('Unexpected checkout response from paystack-initialize.');
    }
    return data;
  }

  Future<Map<String, dynamic>> verifyCheckout({required String reference}) async {
    final response = await _client.functions.invoke('paystack-verify', body: {'reference': reference});
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw StateError('Unexpected verification response from paystack-verify.');
    }
    return data;
  }
}
