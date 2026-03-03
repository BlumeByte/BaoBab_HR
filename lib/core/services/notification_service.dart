import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_service.dart';

class NotificationService {
  NotificationService({SupabaseClient? client}) : _client = client ?? SupabaseService.client;

  final SupabaseClient _client;

  Future<void> sendEmailNotification({
    required String to,
    required String subject,
    required String message,
  }) async {
    try {
      await _client.functions.invoke(
        'send-email-notification',
        body: {'to': to, 'subject': subject, 'message': message},
      );
    } catch (_) {
      // non-blocking notification failure
    }
  }
}
