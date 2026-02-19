import 'package:flutter/material.dart';
import '../shared/section_template.dart';

class AnnouncementsFeedScreen extends StatelessWidget {
  const AnnouncementsFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SectionTemplate(
      title: 'Announcements',
      description: 'Company news feed and upcoming events calendar.',
      icon: Icons.campaign,
    );
  }
}
