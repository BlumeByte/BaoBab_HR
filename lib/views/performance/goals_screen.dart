import 'package:flutter/material.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const goals = [
      ('Improve onboarding completion to 95%', 'People Ops', 72),
      ('Reduce average hiring time to 28 days', 'Recruitment', 54),
      ('Launch quarterly feedback cycle', 'Managers', 86),
    ];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Performance', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          const Text('Track goals, review progress, and maintain continuous feedback loops.'),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.separated(
              itemCount: goals.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final goal = goals[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(goal.$1, style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 4),
                        Text('Owner: ${goal.$2}'),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(value: goal.$3 / 100),
                        const SizedBox(height: 8),
                        Text('${goal.$3}% complete'),
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
