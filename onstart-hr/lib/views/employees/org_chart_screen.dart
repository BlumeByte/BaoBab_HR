import 'package:flutter/material.dart';

class OrgChartScreen extends StatelessWidget {
  const OrgChartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Org Chart Screen',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
