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
    final workEmail = (map['work_email'] ?? '').toString();
    final personalEmail = (map['personal_email'] ?? '').toString();

    return EmployeeRecord(
      id: (map['id'] ?? '').toString(),
      fullName: (map['full_name'] ?? '').toString(),
      email: workEmail.isNotEmpty ? workEmail : (map['email'] ?? personalEmail).toString(),
      department: (map['department'] ?? 'General').toString(),
      jobTitle: (map['job_title'] ?? 'Employee').toString(),
      status: (map['employment_status'] ?? map['status'] ?? 'active').toString(),
      avatarUrl: (map['profile_photo_url'] ?? map['avatar_url'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'work_email': email,
      'department': department,
      'job_title': jobTitle,
      'employment_status': status,
      'profile_photo_url': avatarUrl,
    };
  }
}
