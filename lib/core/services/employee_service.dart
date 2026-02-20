import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/employee_model.dart';
import 'supabase_service.dart';

class EmployeeService {
  Future<List<EmployeeRecord>> fetchEmployees() async {
    final response = await SupabaseService.client.from('employees').select();
    return (response as List)
        .map((row) => EmployeeRecord.fromMap(row as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase()));
  }

  Future<EmployeeRecord?> fetchEmployeeForCurrentUser() async {
    final user = SupabaseService.client.auth.currentUser;
    if (user == null) return null;

    final selectors = <Map<String, String>>[
      {'column': 'user_id', 'value': user.id},
      {'column': 'auth_user_id', 'value': user.id},
      if ((user.email ?? '').isNotEmpty) {'column': 'email', 'value': user.email!},
      if ((user.email ?? '').isNotEmpty) {'column': 'work_email', 'value': user.email!},
      if ((user.email ?? '').isNotEmpty) {'column': 'personal_email', 'value': user.email!},
    ];

    for (final selector in selectors) {
      try {
        final row = await SupabaseService.client
            .from('employees')
            .select()
            .eq(selector['column']!, selector['value']!)
            .maybeSingle();
        if (row != null) return EmployeeRecord.fromMap(row);
      } on PostgrestException catch (e) {
        final missingColumn = e.message.toLowerCase().contains('does not exist');
        if (!missingColumn) rethrow;
      }
    }

    return null;
  }

  Future<void> createEmployee({
    required String fullName,
    required String email,
    required String department,
    required String jobTitle,
    required String avatarUrl,
    String? offerLetterUrl,
  }) async {
    await SupabaseService.client.from('employees').insert({
      'full_name': fullName,
      'email': email,
      'department': department,
      'job_title': jobTitle,
      'status': 'Active',
      'avatar_url': avatarUrl,
      if (offerLetterUrl != null && offerLetterUrl.isNotEmpty) 'offer_letter_url': offerLetterUrl,
    });
  }

  Future<void> sendPasswordSetupLink(String email) async {
    await SupabaseService.client.auth.resetPasswordForEmail(email.trim());
  }

  Future<List<Map<String, dynamic>>> fetchAnnouncements() async {
    try {
      final response = await SupabaseService.client
          .from('announcements')
          .select()
          .order('created_at', ascending: false)
          .limit(5);
      return (response as List).cast<Map<String, dynamic>>();
    } catch (_) {
      return const [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchLeaveRequestsForCurrentUser() async {
    final user = SupabaseService.client.auth.currentUser;
    if (user == null) return const [];

    final employee = await fetchEmployeeForCurrentUser();
    if (employee == null) return const [];

    final filters = [
      {'column': 'employee_id', 'value': employee.id},
      {'column': 'user_id', 'value': user.id},
    ];

    for (final filter in filters) {
      try {
        final response = await SupabaseService.client
            .from('leave_requests')
            .select()
            .eq(filter['column']!, filter['value']!)
            .order('created_at', ascending: false);
        return (response as List).cast<Map<String, dynamic>>();
      } on PostgrestException catch (e) {
        if (!e.message.toLowerCase().contains('does not exist')) rethrow;
      }
    }

    return const [];
  }

  Future<void> createLeaveRequest({
    required String leaveType,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
  }) async {
    final user = SupabaseService.client.auth.currentUser;
    final employee = await fetchEmployeeForCurrentUser();
    if (user == null || employee == null) return;

    await SupabaseService.client.from('leave_requests').insert({
      'employee_id': employee.id,
      'user_id': user.id,
      'leave_type': leaveType,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'reason': reason,
      'status': 'Pending',
    });
  }
}
