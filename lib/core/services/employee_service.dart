import '../../models/employee_model.dart';
import 'supabase_service.dart';

class EmployeeService {
  Future<List<EmployeeRecord>> fetchEmployees() async {
    final response = await SupabaseService.client
        .from('employees')
        .select()
        .order('full_name', ascending: true);

    return (response as List)
        .map((row) => EmployeeRecord.fromMap(row as Map<String, dynamic>))
        .toList();
  }

  Future<EmployeeRecord?> fetchEmployeeByEmail(String email) async {
    final response = await SupabaseService.client
        .from('employees')
        .select()
        .eq('email', email)
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
    await SupabaseService.client.from('employees').insert({
      'full_name': fullName,
      'email': email,
      'department': department,
      'job_title': jobTitle,
      'status': 'Active',
      'avatar_url': avatarUrl,
    });
  }

  Future<void> sendLoginLink(String email) async {
    await SupabaseService.client.auth.signInWithOtp(email: email);
  }
}
