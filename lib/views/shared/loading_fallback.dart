import 'package:flutter/material.dart';

class LoadingFallback extends StatelessWidget {
  const LoadingFallback({super.key, this.label = 'Loading...'});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 10),
          Text(label),
        ],
      ),
    );
  }
}
