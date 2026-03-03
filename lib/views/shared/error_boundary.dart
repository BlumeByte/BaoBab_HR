import 'package:flutter/material.dart';

class AppErrorBoundary extends StatelessWidget {
  const AppErrorBoundary({super.key, required this.child, this.error});

  final Widget child;
  final Object? error;

  @override
  Widget build(BuildContext context) {
    if (error != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 44, color: Colors.redAccent),
                const SizedBox(height: 8),
                const Text('Something went wrong.'),
                const SizedBox(height: 8),
                Text(error.toString(), textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      );
    }
    return child;
  }
}
