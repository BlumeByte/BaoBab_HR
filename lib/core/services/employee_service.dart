import '../../models/employee_model.dart';

/// Stub implementation of the employee service.
///
/// This minimal version returns an empty list from [fetchEmployees]. In
/// a production environment, replace this stub with an implementation
/// that queries your data source (for example, via Supabase or a REST
/// API) and returns a list of [EmployeeRecord] objects.
class EmployeeService {
  EmployeeService();

  /// Fetches all employees for the current company.
  Future<List<EmployeeRecord>> fetchEmployees() async {
    return const [];
  }

  /// Fetches a list of pending leave requests.
  ///
  /// This stubbed implementation returns an empty list by default. In a real
  /// application you would connect to your data source (for example Supabase)
  /// and query the `leaves` table for rows where the status is `pending`.
  /// The optional [limit] argument can be used to limit the number of
  /// records returned from the backend.
  Future<List<Map<String, dynamic>>> fetchPendingLeaves({int limit = 20}) async {
    return const [];
  }

  /// Fetches the current user's leave requests.
  ///
  /// This stubbed implementation returns an empty list by default. In a real
  /// application you would connect to your data source (for example Supabase)
  /// and query the `leaves` table for rows associated with the current
  /// employee. The optional [limit] argument can be used to limit the
  /// number of records returned from the backend.
  Future<List<Map<String, dynamic>>> fetchMyLeaves({int limit = 20}) async {
    return const [];
  }
}