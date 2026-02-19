import 'package:flutter/material.dart';
import '../shared/section_template.dart';

class TimesheetScreen extends StatelessWidget {
  const TimesheetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SectionTemplate(
      title: 'Attendance & Timesheets',
      description: 'Review daily attendance, time tracking, and shift exceptions.',
      icon: Icons.access_time,
    );
  }
}
