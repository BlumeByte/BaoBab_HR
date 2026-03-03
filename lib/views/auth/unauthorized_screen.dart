import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/route_names.dart';

class UnauthorizedScreen extends StatelessWidget {
  const UnauthorizedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Unauthorized', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                const Text('You do not have permission to access this page.'),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => context.go(RouteNames.login),
                  child: const Text('Go to login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
