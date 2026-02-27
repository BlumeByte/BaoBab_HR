class TimesheetRecord {
  const TimesheetRecord({
    required this.id,
    required this.employeeEmail,
    required this.attendanceDate,
    required this.checkInAt,
    required this.checkOutAt,
    required this.hoursWorked,
    required this.status,
  });

  final String id;
  final String employeeEmail;
  final String attendanceDate;
  final String? checkInAt;
  final String? checkOutAt;
  final double? hoursWorked;
  final String status;

  factory TimesheetRecord.fromJson(Map<String, dynamic> json) {
    return TimesheetRecord(
      id: json['id'] ?? '',
      employeeEmail: json['employee_email'] ?? '',
      attendanceDate: json['attendance_date'] ?? '',
      checkInAt: json['check_in_at'],
      checkOutAt: json['check_out_at'],
      hoursWorked: (json['hours_worked'] != null)
          ? double.tryParse(json['hours_worked'].toString())
          : null,
      status: json['status'] ?? 'absent',
    );
  }
}
