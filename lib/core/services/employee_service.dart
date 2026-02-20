import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/employee_model.dart';
import 'supabase_service.dart';

class HrDashboardStats {
  const HrDashboardStats({
    required this.totalEmployees,
    required this.presentToday,
    required this.absentToday,
    required this.payrollTotal,
    required this.leavePending,
  });

  final int totalEmployees;
  final int presentToday;
  final int absentToday;
  final double payrollTotal;
  final int leavePending;
}

class EmployeeService {
  Future<List<EmployeeRecord>> fetchEmployees() async {
    final response = await SupabaseService.client.from('employees').select();
    return (response as List)
        .map((row) => EmployeeRecord.fromMap(row as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase()));
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
      'work_email': email,
      'department': department,
      'job_title': jobTitle,
      'employment_status': 'active',
      'profile_photo_url': avatarUrl,
      if (offerLetterUrl != null && offerLetterUrl.isNotEmpty) 'offer_letter_url': offerLetterUrl,
    });
  }

  Future<void> updateEmployee({
    required String employeeId,
    required String fullName,
    required String email,
    required String department,
    required String jobTitle,
    required String status,
    required String avatarUrl,
  }) async {
    await SupabaseService.client.from('employees').update({
      'full_name': fullName,
      'work_email': email,
      'department': department,
      'job_title': jobTitle,
      'employment_status': status.toLowerCase(),
      'profile_photo_url': avatarUrl,
    }).eq('id', employeeId);
  }

  Future<void> deleteEmployee(String employeeId) async {
    await SupabaseService.client.from('employees').delete().eq('id', employeeId);
  }

  Future<void> addOrUpdatePayroll({
    required String employeeId,
    required DateTime periodStart,
    required DateTime periodEnd,
    required double basicSalary,
    required double allowances,
    required double deductions,
    required double taxes,
    required int daysWorked,
  }) async {
    final user = await _currentAppUser();
    if (user == null) return;

    final basePayload = {
      'company_id': user['company_id'],
      'employee_id': employeeId,
      'period_start': periodStart.toIso8601String().split('T').first,
      'period_end': periodEnd.toIso8601String().split('T').first,
      'basic_salary': basicSalary,
      'allowances': allowances,
      'deductions': deductions,
      'taxes': taxes,
      'days_worked': daysWorked,
    };

    try {
      await SupabaseService.client.from('payroll').upsert(basePayload);
    } on PostgrestException catch (e) {
      if (!e.message.toLowerCase().contains('days_worked')) rethrow;
      final fallbackPayload = Map<String, dynamic>.from(basePayload)..remove('days_worked');
      await SupabaseService.client.from('payroll').upsert(fallbackPayload);
    }
  }

  Future<void> addAttendanceLog({
    required String employeeId,
    required DateTime date,
    required String status,
  }) async {
    final user = await _currentAppUser();
    if (user == null) return;

    await SupabaseService.client.from('attendance').upsert({
      'company_id': user['company_id'],
      'employee_id': employeeId,
      'attendance_date': date.toIso8601String().split('T').first,
      'status': status.toLowerCase(),
    });
  }

  Future<List<Map<String, dynamic>>> fetchAttendanceLogs({int limit = 50}) async {
    return ((await SupabaseService.client
            .from('attendance')
            .select('id, employee_id, attendance_date, status, check_in_at, check_out_at, employees(full_name)')
            .order('attendance_date', ascending: false)
            .limit(limit))
        as List)
        .cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> fetchPendingLeaves({int limit = 50}) async {
    try {
      final rows = await SupabaseService.client
          .from('leaves')
          .select('id, employee_id, leave_type, start_date, end_date, reason, status, employees(full_name)')
          .eq('status', 'pending')
          .order('created_at', ascending: false)
          .limit(limit);
      return (rows as List).cast<Map<String, dynamic>>();
    } on PostgrestException {
      final rows = await SupabaseService.client
          .from('leave_requests')
          .select('id, employee_id, leave_type, start_date, end_date, reason, status')
          .eq('status', 'Pending')
          .order('created_at', ascending: false)
          .limit(limit);
      return (rows as List).cast<Map<String, dynamic>>();
    }
  }

  Future<void> approveLeave({required String leaveId}) async {
    try {
      await SupabaseService.client.from('leaves').update({'status': 'approved'}).eq('id', leaveId);
    } on PostgrestException {
      await SupabaseService.client.from('leave_requests').update({'status': 'Approved'}).eq('id', leaveId);
    }
  }

  Future<HrDashboardStats> fetchHrDashboardStats() async {
    final today = DateTime.now();
    final monthStart = DateTime(today.year, today.month, 1).toIso8601String().split('T').first;
    final todayString = today.toIso8601String().split('T').first;

    final employees = await SupabaseService.client.from('employees').select('id', const FetchOptions(count: CountOption.exact));
    final totalEmployees = employees.count ?? 0;

    final presentRows = await SupabaseService.client
        .from('attendance')
        .select('id', const FetchOptions(count: CountOption.exact))
        .eq('attendance_date', todayString)
        .ilike('status', 'present');
    final presentToday = presentRows.count ?? 0;

    final absentRows = await SupabaseService.client
        .from('attendance')
        .select('id', const FetchOptions(count: CountOption.exact))
        .eq('attendance_date', todayString)
        .ilike('status', 'absent');

    final payrollRows = await SupabaseService.client
        .from('payroll')
        .select('net_pay')
        .gte('period_start', monthStart);

    double payrollTotal = 0;
    for (final row in (payrollRows as List)) {
      payrollTotal += (row['net_pay'] as num?)?.toDouble() ?? 0;
    }

    int leavePending = 0;
    try {
      final leaves = await SupabaseService.client
          .from('leaves')
          .select('id', const FetchOptions(count: CountOption.exact))
          .eq('status', 'pending');
      leavePending = leaves.count ?? 0;
    } on PostgrestException {
      final leaves = await SupabaseService.client
          .from('leave_requests')
          .select('id', const FetchOptions(count: CountOption.exact))
          .eq('status', 'Pending');
      leavePending = leaves.count ?? 0;
    }

    return HrDashboardStats(
      totalEmployees: totalEmployees,
      presentToday: presentToday,
      absentToday: absentRows.count ?? (totalEmployees - presentToday).clamp(0, totalEmployees),
      payrollTotal: payrollTotal,
      leavePending: leavePending,
    );
  }

  Future<void> sendPasswordSetupLink(String email) async {
    await SupabaseService.client.auth.resetPasswordForEmail(email.trim());
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
        if (!e.message.toLowerCase().contains('does not exist')) rethrow;
      }
    }

    return null;
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

  Future<Map<String, dynamic>?> _currentAppUser() async {
    final authUser = SupabaseService.client.auth.currentUser;
    if (authUser == null) return null;
    return await SupabaseService.client
        .from('users')
        .select('id,company_id')
        .eq('auth_user_id', authUser.id)
        .maybeSingle();
  }
}
