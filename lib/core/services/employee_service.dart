import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/employee_model.dart';
import '../../models/leave_model.dart';
import '../../models/timesheet_model.dart';

class EmployeeService {
  final supabase = Supabase.instance.client;

  // Fetch all employees
  Future<List<EmployeeRecord>> fetchEmployees() async {
    final data = await supabase.from('employees').select();
    return (data as List<dynamic>)
        .map((e) => EmployeeRecord.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // Create employee
  Future<void> createEmployee({
    required String fullName,
    required String email,
    required String department,
    required String jobTitle,
    required String avatarUrl,
  }) async {
    await supabase.from('employees').insert({
      'full_name': fullName,
      'email': email,
      'department': department,
      'job_title': jobTitle,
      'avatar_url': avatarUrl,
      'status': 'active',
    });
  }

  // Send login link via Supabase Auth
  Future<void> sendLoginLink(String email) async {
    await supabase.auth.signInWithOtp(email: email);
  }

  // Fetch employee by email
  Future<EmployeeRecord?> fetchEmployeeByEmail(String email) async {
    final data =
        await supabase.from('employees').select().eq('email', email).limit(1);
    if ((data as List).isEmpty) return null;
    return EmployeeRecord.fromJson(data[0] as Map<String, dynamic>);
  }

  // Fetch pending leaves
  Future<List<LeaveRecord>> fetchPendingLeaves({int limit = 20}) async {
    final data = await supabase
        .from('leaves')
        .select()
        .eq('status', 'pending')
        .limit(limit);
    return (data as List<dynamic>)
        .map((e) => LeaveRecord.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // Fetch my leaves by email
  Future<List<LeaveRecord>> fetchMyLeaves(String email,
      {int limit = 20}) async {
    final data = await supabase
        .from('leaves')
        .select()
        .eq('employee_email', email)
        .limit(limit);
    return (data as List<dynamic>)
        .map((e) => LeaveRecord.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // Fetch attendance logs
  Future<List<TimesheetRecord>> fetchAttendanceLogs({int limit = 30}) async {
    final data = await supabase.from('attendance_logs').select().limit(limit);
    return (data as List<dynamic>)
        .map((e) => TimesheetRecord.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
