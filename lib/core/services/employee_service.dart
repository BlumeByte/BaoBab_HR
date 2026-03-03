import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/employee_model.dart';
import 'supabase_service.dart';

class EmployeeDashboardData {
  const EmployeeDashboardData({
    required this.employee,
    required this.leaveBalanceAnnual,
    required this.leaveBalanceSick,
    required this.todayAttendance,
    required this.latestPayroll,
    required this.myLeaves,
  });

  final EmployeeRecord employee;
  final double leaveBalanceAnnual;
  final double leaveBalanceSick;
  final Map<String, dynamic>? todayAttendance;
  final Map<String, dynamic>? latestPayroll;
  final List<Map<String, dynamic>> myLeaves;
}

class HrDashboardStats {
  const HrDashboardStats({
    required this.totalEmployees,
    required this.pendingLeaves,
    required this.presentToday,
  });

  final int totalEmployees;
  final int pendingLeaves;
  final int presentToday;
}

class EmployeeService {
  EmployeeService({SupabaseClient? client}) : _client = client ?? SupabaseService.client;

  final SupabaseClient _client;

  Future<Map<String, dynamic>?> _currentUserRow() async {
    final authUser = _client.auth.currentUser;
    if (authUser == null) return null;
    return _client.from('users').select('id,company_id,auth_user_id,email,role').eq('auth_user_id', authUser.id).maybeSingle();
  }

  Future<EmployeeRecord?> _currentEmployee() async {
    final user = await _currentUserRow();
    if (user == null) return null;

    final email = user['email']?.toString() ?? '';

    final byWork = await _client
        .from('employees')
        .select('id,full_name,department,job_title,employment_status,profile_photo_url,work_email,personal_email')
        .eq('company_id', user['company_id'])
        .eq('work_email', email)
        .maybeSingle();
    if (byWork != null) return EmployeeRecord.fromMap(byWork);

    final byPersonal = await _client
        .from('employees')
        .select('id,full_name,department,job_title,employment_status,profile_photo_url,work_email,personal_email')
        .eq('company_id', user['company_id'])
        .eq('personal_email', email)
        .maybeSingle();

    if (byPersonal == null) return null;
    return EmployeeRecord.fromMap(byPersonal);
  }

  Future<List<EmployeeRecord>> fetchEmployees() async {
    final user = await _currentUserRow();
    if (user == null) return const [];

    final response = await _client
        .from('employees')
        .select('id,full_name,department,job_title,employment_status,profile_photo_url,work_email,personal_email')
        .eq('company_id', user['company_id'])
        .order('full_name', ascending: true);

    return (response as List).map((row) => EmployeeRecord.fromMap(row as Map<String, dynamic>)).toList();
  }

  Future<EmployeeRecord?> fetchEmployeeByEmail(String email) async {
    final user = await _currentUserRow();
    if (user == null) return null;

    final response = await _client
        .from('employees')
        .select('id,full_name,department,job_title,employment_status,profile_photo_url,work_email,personal_email')
        .eq('company_id', user['company_id'])
        .or('work_email.eq.$email,personal_email.eq.$email')
        .maybeSingle();

    if (response == null) return null;
    return EmployeeRecord.fromMap(response);
  }

  Future<void> createEmployee({
    required String fullName,
    required String email,
    required String department,
    required String jobTitle,
    required String avatarUrl,
  }) async {
    final user = await _currentUserRow();
    if (user == null) throw StateError('No logged in user found.');

    await _client.from('employees').insert({
      'company_id': user['company_id'],
      'full_name': fullName,
      'work_email': email,
      'department': department,
      'job_title': jobTitle,
      'employment_status': 'active',
      'profile_photo_url': avatarUrl,
    });
  }

  Future<void> sendLoginLink(String email) async {
    await _client.auth.signInWithOtp(email: email);
  }

  Future<EmployeeDashboardData> fetchEmployeeDashboardData() async {
    final user = await _currentUserRow();
    if (user == null) throw StateError('Please log in first.');
    final employee = await _currentEmployee();
    if (employee == null) throw StateError('No employee record linked to this account.');

    final today = DateTime.now().toIso8601String().split('T').first;

    final attendance = await _client
        .from('attendance')
        .select('id,attendance_date,check_in_at,check_out_at,hours_worked,status')
        .eq('company_id', user['company_id'])
        .eq('employee_id', employee.id)
        .eq('attendance_date', today)
        .maybeSingle();

    final payrollRows = await _client
        .from('payroll')
        .select('period_start,period_end,basic_salary,allowances,deductions,taxes,net_pay,currency,paid_at,created_at')
        .eq('company_id', user['company_id'])
        .eq('employee_id', employee.id)
        .order('created_at', ascending: false)
        .limit(1);

    final leaves = await fetchMyLeaves(limit: 5);

    return EmployeeDashboardData(
      employee: employee,
      leaveBalanceAnnual: 0,
      leaveBalanceSick: 0,
      todayAttendance: attendance,
      latestPayroll: (payrollRows as List).isEmpty ? null : payrollRows.first as Map<String, dynamic>,
      myLeaves: leaves,
    );
  }

  Future<void> clockInForCurrentEmployee() async {
    final user = await _currentUserRow();
    if (user == null) throw StateError('Please log in first.');
    final employee = await _currentEmployee();
    if (employee == null) throw StateError('No employee record linked to this account.');

    final now = DateTime.now();
    final today = now.toIso8601String().split('T').first;

    final existing = await _client
        .from('attendance')
        .select('id,check_in_at')
        .eq('company_id', user['company_id'])
        .eq('employee_id', employee.id)
        .eq('attendance_date', today)
        .maybeSingle();

    if (existing == null) {
      await _client.from('attendance').insert({
        'company_id': user['company_id'],
        'employee_id': employee.id,
        'attendance_date': today,
        'check_in_at': now.toIso8601String(),
        'status': 'present',
      });
      return;
    }

    if (existing['check_in_at'] == null) {
      await _client.from('attendance').update({'check_in_at': now.toIso8601String(), 'status': 'present'}).eq('id', existing['id']);
    }
  }

  Future<void> clockOutForCurrentEmployee() async {
    final user = await _currentUserRow();
    if (user == null) throw StateError('Please log in first.');
    final employee = await _currentEmployee();
    if (employee == null) throw StateError('No employee record linked to this account.');

    final today = DateTime.now().toIso8601String().split('T').first;

    final existing = await _client
        .from('attendance')
        .select('id,check_in_at,check_out_at')
        .eq('company_id', user['company_id'])
        .eq('employee_id', employee.id)
        .eq('attendance_date', today)
        .maybeSingle();

    if (existing == null) {
      throw StateError('You need to clock in before clocking out.');
    }

    await _client.from('attendance').update({'check_out_at': DateTime.now().toIso8601String()}).eq('id', existing['id']);
  }

  Future<HrDashboardStats> fetchHrDashboardStats() async {
    final user = await _currentUserRow();
    if (user == null) throw StateError('Please log in first.');

    final totalEmployees = await _client.from('employees').select('id').eq('company_id', user['company_id']);
    final pendingLeaves = await _client
        .from('leaves')
        .select('id')
        .eq('company_id', user['company_id'])
        .eq('status', 'pending');
    final today = DateTime.now().toIso8601String().split('T').first;
    final presentToday = await _client
        .from('attendance')
        .select('id')
        .eq('company_id', user['company_id'])
        .eq('attendance_date', today)
        .eq('status', 'present');

    return HrDashboardStats(
      totalEmployees: (totalEmployees as List).length,
      pendingLeaves: (pendingLeaves as List).length,
      presentToday: (presentToday as List).length,
    );
  }

  Future<List<Map<String, dynamic>>> fetchAttendanceLogs({int limit = 20}) async {
    final user = await _currentUserRow();
    if (user == null) return const [];

    final rows = await _client
        .from('attendance')
        .select('id,employee_id,attendance_date,check_in_at,check_out_at,hours_worked,status,created_at')
        .eq('company_id', user['company_id'])
        .order('attendance_date', ascending: false)
        .limit(limit);

    return (rows as List).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> fetchPendingLeaves({int limit = 20}) async {
    final user = await _currentUserRow();
    if (user == null) return const [];

    final rows = await _client
        .from('leaves')
        .select('id,employee_id,leave_type,start_date,end_date,total_days,reason,status,created_at')
        .eq('company_id', user['company_id'])
        .eq('status', 'pending')
        .order('created_at', ascending: false)
        .limit(limit);

    return (rows as List).cast<Map<String, dynamic>>();
  }

  Future<void> approveLeave({required String leaveId}) async {
    final user = await _currentUserRow();
    if (user == null) throw StateError('Please log in first.');

    await _client
        .from('leaves')
        .update({'status': 'approved', 'approved_at': DateTime.now().toIso8601String(), 'approved_by_user_id': user['id']})
        .eq('company_id', user['company_id'])
        .eq('id', leaveId);
  }

  Future<List<Map<String, dynamic>>> fetchMyAttendanceLogs({int limit = 20}) async {
    final user = await _currentUserRow();
    if (user == null) return const [];
    final employee = await _currentEmployee();
    if (employee == null) return const [];

    final rows = await _client
        .from('attendance')
        .select('id,attendance_date,check_in_at,check_out_at,hours_worked,status')
        .eq('company_id', user['company_id'])
        .eq('employee_id', employee.id)
        .order('attendance_date', ascending: false)
        .limit(limit);

    return (rows as List).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> fetchMyLeaves({int limit = 20}) async {
    final user = await _currentUserRow();
    if (user == null) return const [];
    final employee = await _currentEmployee();
    if (employee == null) return const [];

    final rows = await _client
        .from('leaves')
        .select('id,leave_type,start_date,end_date,total_days,reason,status,created_at')
        .eq('company_id', user['company_id'])
        .eq('employee_id', employee.id)
        .order('created_at', ascending: false)
        .limit(limit);

    return (rows as List).cast<Map<String, dynamic>>();
  }
}
