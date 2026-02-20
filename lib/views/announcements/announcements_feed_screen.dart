import 'package:flutter/material.dart';

class AnnouncementsFeedScreen extends StatelessWidget {
  const AnnouncementsFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const announcements = [
      ('Q2 All Hands Meeting', 'Friday, 10:00 AM • Main Hall + Live Stream'),
      ('Wellness Week', 'Company-wide activities begin on March 18.'),
      ('Policy Update: Hybrid Work', 'Please review and acknowledge the updated policy.'),
    ];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Announcements', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          const Text('Stay informed with company updates, reminders, and events.'),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.separated(
              itemCount: announcements.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = announcements[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.campaign_outlined),
                    title: Text(item.$1),
                    subtitle: Text(item.$2),
                    trailing: TextButton(onPressed: () {}, child: const Text('View')),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
