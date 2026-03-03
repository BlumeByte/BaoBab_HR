import 'package:flutter/material.dart';

class SectionTemplate extends StatelessWidget {
  const SectionTemplate({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.actions = const [],
  });

  final String title;
  final String description;
  final IconData icon;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 30),
              const SizedBox(width: 12),
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
            ],
          ),
          const SizedBox(height: 10),
          Text(description),
          const SizedBox(height: 20),
          Wrap(spacing: 12, runSpacing: 12, children: actions),
        ],
      ),
    );
  }
}
