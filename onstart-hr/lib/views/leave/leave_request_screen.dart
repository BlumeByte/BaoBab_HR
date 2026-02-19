import 'package:flutter/material.dart';
import '../shared/section_template.dart';

class LeaveRequestScreen extends StatelessWidget {
  const LeaveRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SectionTemplate(
      title: 'Leave Management',
      description: 'Submit, track, and approve leave requests with balance visibility.',
      icon: Icons.beach_access,
    );
  }
}
