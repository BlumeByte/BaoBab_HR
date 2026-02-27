class LeaveRecord {
  LeaveRecord({
    required this.id,
    required this.employeeEmail,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.status,
  });

  final String id;
  final String employeeEmail;
  final String leaveType;
  final String startDate;
  final String endDate;
  final String reason;
  final String status;

  factory LeaveRecord.fromJson(Map<String, dynamic> json) {
    return LeaveRecord(
      id: json['id'] ?? '',
      employeeEmail: json['employee_email'] ?? '',
      leaveType: json['leave_type'] ?? '',
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      reason: json['reason'] ?? '',
      status: json['status'] ?? 'pending',
    );
  }
}
