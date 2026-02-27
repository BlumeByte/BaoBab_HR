import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/providers/auth_provider.dart';
import '../../core/router/route_names.dart';

class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({super.key});

  String _homeRoute() {
    return RouteNames.hrDashboard;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      body: Center(
        child: Card(
          child: SizedBox(
            width: 460,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Verify your email', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 12),
                  Text('A verification email should be in ${auth.userEmail}. Please verify before continuing.'),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () async {
                        await context.read<AuthProvider>().resendVerification(auth.userEmail);
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Verification email sent.')),
                        );
                      },
                      child: const Text('Resend verification email'),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      await context.read<AuthProvider>().restoreSession();
                      if (!context.mounted) return;
                      final latest = context.read<AuthProvider>();
                      if (latest.isEmailVerified) {
                        context.go(_homeRoute());
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Email is still not verified.')),
                        );
                      }
                    },
                    child: const Text('I already verified, continue'),
                  ),
                  TextButton(
                    onPressed: () async {
                      await context.read<AuthProvider>().logout();
                      if (context.mounted) context.go(RouteNames.login);
                    },
                    child: const Text('Logout'),
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
