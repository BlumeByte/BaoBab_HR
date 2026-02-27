import 'package:supabase_flutter/supabase_flutter.dart';

class SuperAdminService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<AuditLogRecord>> fetchAuditLogs({int limit = 50}) async {
    final response = await _client
        .from('audit_logs')
        .select()
        .order('created_at', ascending: false)
        .limit(limit);

    if (response.error != null) throw response.error!;

    final data = response.data as List<dynamic>;
    return data
        .map((e) => AuditLogRecord.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

class AuditLogRecord {
  AuditLogRecord({
    required this.id,
    required this.userId,
    required this.action,
    required this.tableName,
    required this.recordId,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String action;
  final String tableName;
  final String recordId;
  final DateTime createdAt;

  factory AuditLogRecord.fromJson(Map<String, dynamic> json) {
    return AuditLogRecord(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      action: json['action'] ?? '',
      tableName: json['table_name'] ?? '',
      recordId: json['record_id'] ?? '',
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}
