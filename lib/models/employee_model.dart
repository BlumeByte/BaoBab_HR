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

  factory EmployeeRecord.fromMap(Map<String, dynamic> map) {
    return EmployeeRecord(
      id: (map['id'] ?? '').toString(),
      fullName: (map['full_name'] ?? '').toString(),
      email: (map['email'] ?? '').toString(),
      department: (map['department'] ?? 'General').toString(),
      jobTitle: (map['job_title'] ?? 'Employee').toString(),
      status: (map['status'] ?? 'Active').toString(),
      avatarUrl: (map['avatar_url'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'department': department,
      'job_title': jobTitle,
      'status': status,
      'avatar_url': avatarUrl,
    };
  }
}
