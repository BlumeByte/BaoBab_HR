import 'package:flutter/material.dart';

class DocumentLibraryScreen extends StatelessWidget {
  const DocumentLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const docs = [
      ('Employee Handbook 2026', 'Policy', 'Updated 3 days ago'),
      ('Remote Work Agreement', 'Template', 'Updated 1 week ago'),
      ('Performance Review Form', 'Form', 'Updated 2 weeks ago'),
      ('NDA Standard', 'Legal', 'Updated 1 month ago'),
    ];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Documents', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          const Text('Organize templates, policies, and employee files in a secure library.'),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 300,
                childAspectRatio: 1.8,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final doc = docs[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.description_outlined),
                        const SizedBox(height: 8),
                        Text(doc.$1, maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Text(doc.$2),
                        const Spacer(),
                        Text(doc.$3, style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
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
