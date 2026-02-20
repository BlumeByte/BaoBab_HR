import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/providers/theme_provider.dart';

class SidebarNavigation extends StatelessWidget {
  const SidebarNavigation({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<ThemeProvider>().isDarkMode;
    return Drawer(
      child: Container(
        color: isDarkMode ? const Color(0xFFA5D6A7) : const Color(0xFF4FC3F7),
        child: DefaultTextStyle(
          style: const TextStyle(color: Colors.white),
          child: IconTheme(
            data: const IconThemeData(color: Colors.white),
            child: ListView(children: children),
          ),
        ),
      ),
    );
  }
}
