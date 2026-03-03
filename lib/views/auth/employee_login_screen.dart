import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/route_names.dart';

class EmployeeLoginScreen extends StatelessWidget {
  const EmployeeLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Card(
          child: SizedBox(
            width: 420,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Single Login Mode Enabled', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 12),
                  const Text(
                    'This deployment uses one company HR login for all BaoBab HR features.\nPlease continue with the main login screen.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => context.go(RouteNames.login),
                    child: const Text('Go to Main Login'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
