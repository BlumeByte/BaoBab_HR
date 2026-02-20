import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/providers/auth_provider.dart';
import '../../core/providers/profile_provider.dart';
import '../../core/router/route_names.dart';

class EmployeeLoginScreen extends StatefulWidget {
  const EmployeeLoginScreen({super.key});

  @override
  State<EmployeeLoginScreen> createState() => _EmployeeLoginScreenState();
}

class _EmployeeLoginScreenState extends State<EmployeeLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
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
                  Text('Employee Login', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 20),
                  TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email')),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password'),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => context.go(RouteNames.login),
                      child: const Text('Back to main login'),
                    ),
                  ),
                  if (auth.errorMessage != null)
                    Text(auth.errorMessage!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: auth.isLoading
                          ? null
                          : () async {
                              final success = await context
                                  .read<AuthProvider>()
                                  .login(_emailController.text, _passwordController.text);
                              if (!success || !context.mounted) return;

                              final authState = context.read<AuthProvider>();
                              if (!authState.isEmployeeUser) {
                                context.go(RouteNames.unauthorized);
                                return;
                              }

                              await context.read<ProfileProvider>().loadProfile();
                              if (!context.mounted) return;

                              if (!context.read<AuthProvider>().isEmailVerified) {
                                context.go(RouteNames.verifyEmail);
                                return;
                              }

                              context.go(RouteNames.employeeDashboard);
                            },
                      child: auth.isLoading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Login as employee'),
                    ),
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
