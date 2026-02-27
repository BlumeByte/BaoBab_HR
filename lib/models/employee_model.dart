/// Stub representation of an employee record.
///
/// This minimal model includes fields that are commonly used by the
/// application: an identifier, full name, email, department, job
/// title, status, and avatar URL. In a full implementation you
/// might add additional fields and helper methods, or use code
/// generation to produce this class from your database schema.
class EmployeeRecord {
  const EmployeeRecord({
    required this.id,
    required this.fullName,
    required this.email,
    required this.department,
    required this.jobTitle,
    required this.status,
    required this.avatarUrl,
  });

  final String id;
  final String fullName;
  final String email;
  final String department;
  final String jobTitle;
  final String status;
  final String avatarUrl;
}