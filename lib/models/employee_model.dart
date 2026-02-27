/// Employee model
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

  factory EmployeeRecord.fromJson(Map<String, dynamic> json) {
    return EmployeeRecord(
      id: json['id'] ?? '',
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      department: json['department'] ?? '',
      jobTitle: json['job_title'] ?? '',
      status: json['status'] ?? 'active',
      avatarUrl: json['avatar_url'] ?? '',
    );
  }
}
