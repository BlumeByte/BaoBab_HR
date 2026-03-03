import 'package:flutter/material.dart';

/// Bootstrap function to initialize the app
Future<void> bootstrap(Future<Widget> Function() builder) async {
  // Catch and print errors during initialization
  FlutterError.onError = (details) {
    print(details.exceptionAsString());
  };

  // Run the app - await the Future<Widget> then pass to runApp
  final widget = await builder();
  runApp(widget);
}
