class EmployeeRecord {
  const EmployeeRecord({
    required this.id,
    required this.fullName,
    required this.email,
    required this.department,
    required this.jobTitle,
    required this.status,
    required this.avatarUrl,
    required this.offerLetterUrl,
    required this.userId,
  });

  final String id;
  final String fullName;
  final String email;
  final String department;
  final String jobTitle;
  final String status;
  final String avatarUrl;
  final String offerLetterUrl;
  final String userId;

  factory EmployeeRecord.fromMap(Map<String, dynamic> map) {
    String readFirst(List<String> keys, {String fallback = ''}) {
      for (final key in keys) {
        final value = map[key];
        if (value != null && value.toString().trim().isNotEmpty) return value.toString();
      }
      return fallback;
    }

    return EmployeeRecord(
      id: readFirst(['id']),
      fullName: readFirst(['full_name', 'name'], fallback: 'Unknown Employee'),
      email: readFirst(['email', 'work_email', 'personal_email']),
      department: readFirst(['department', 'department_name'], fallback: 'General'),
      jobTitle: readFirst(['job_title', 'title', 'position'], fallback: 'Employee'),
      status: readFirst(['status', 'employment_status'], fallback: 'Active'),
      avatarUrl: readFirst(['avatar_url', 'profile_photo_url']),
      offerLetterUrl: readFirst(['offer_letter_url', 'offer_url']),
      userId: readFirst(['user_id', 'auth_user_id']),
    );
  }
}
