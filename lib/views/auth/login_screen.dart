import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/profile_provider.dart';
import '../../core/router/route_names.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
                  Text('Welcome to Baobab HR',
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 20),
                  TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email')),
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
                      onPressed: () => context.go(RouteNames.forgotPassword),
                      child: const Text('Forgot password?'),
                    ),
                  ),
                  if (auth.errorMessage != null)
                    Text(auth.errorMessage!,
                        style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: auth.isLoading
                          ? null
                          : () async {
                              final success = await context
                                  .read<AuthProvider>()
                                  .login(_emailController.text,
                                      _passwordController.text);
                              if (success && context.mounted) {
                                await context
                                    .read<ProfileProvider>()
                                    .loadProfile();
                                context.go(RouteNames.dashboard);
                              }

                              context
                                  .go(_homeRoute(context.read<AuthProvider>()));
                            },
                      child: auth.isLoading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Login'),
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
