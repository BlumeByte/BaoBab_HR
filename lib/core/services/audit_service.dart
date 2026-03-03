import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_service.dart';

class AuditService {
  AuditService({SupabaseClient? client}) : _client = client ?? SupabaseService.client;

  final SupabaseClient _client;

  Future<void> logAction({
    required String action,
    required String tableName,
    String? recordId,
    Map<String, dynamic>? oldData,
    Map<String, dynamic>? newData,
  }) async {
    try {
      final user = await _client
          .from('users')
          .select('id,company_id')
          .eq('auth_user_id', _client.auth.currentUser?.id ?? '')
          .maybeSingle();

      await _client.from('audit_logs').insert({
        'company_id': user?['company_id'],
        'actor_user_id': user?['id'],
        'table_name': tableName,
        'record_id': recordId,
        'action': action,
        'old_data': oldData,
        'new_data': newData,
      });
    } catch (_) {
      // avoid blocking user actions if audit write fails
    }
  }
}
