import 'package:flutter/material.dart';
import '../shared/section_template.dart';

class DocumentLibraryScreen extends StatelessWidget {
  const DocumentLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SectionTemplate(
      title: 'Documents',
      description: 'Centralized employee files, templates, and acknowledgements.',
      icon: Icons.folder,
    );
  }
}
