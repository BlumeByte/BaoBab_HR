// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/profile_provider.dart';
import '../../core/router/route_names.dart';

class NavItem {
  const NavItem(this.label, this.icon, this.route);
  final String label;
  final IconData icon;
  final String route;
}

const navItems = [
  NavItem('Dashboard', Icons.dashboard_outlined, RouteNames.dashboard),
  NavItem('My Profile', Icons.account_circle_outlined, RouteNames.employeeProfile),
  NavItem('Employees', Icons.people_alt_outlined, RouteNames.employees),
  NavItem('Leave', Icons.beach_access_outlined, RouteNames.leave),
  NavItem('Attendance', Icons.access_time, RouteNames.attendance),
  NavItem('Performance', Icons.insights_outlined, RouteNames.performance),
  NavItem('Recruitment', Icons.work_outline, RouteNames.recruitment),
  NavItem('Documents', Icons.folder_open_outlined, RouteNames.documents),
  NavItem('Reports', Icons.bar_chart_outlined, RouteNames.reports),
  NavItem('Announcements', Icons.campaign_outlined, RouteNames.announcements),
  NavItem('Settings', Icons.settings_outlined, RouteNames.settings),
];

class MainLayout extends StatelessWidget {
  const MainLayout({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>();
    final auth = context.watch<AuthProvider>();
    final location = GoRouterState.of(context).uri.path;
    final visibleNavItems = auth.isEmployeeUser
        ? navItems.where((item) => item.route == RouteNames.employeeProfile || item.route == RouteNames.documents).toList()
        : navItems;

    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 260,
            color: const Color(0xFF4FC3F7),
            child: Column(
              children: [
                const SizedBox(height: 26),
                const Text('Baobab HR',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 24),
                CircleAvatar(
                    backgroundImage: NetworkImage(profile.avatarUrl),
                    radius: 28),
                const SizedBox(height: 8),
                Text(profile.displayName,
                    style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
                const Divider(height: 24, color: Colors.white70),
                Expanded(
                  child: ListView(
                    children: visibleNavItems
                        .map(
                          (item) => ListTile(
                            leading: Icon(item.icon, color: Colors.white),
                            title: Text(item.label, style: const TextStyle(color: Colors.white)),
                            selectedColor: Colors.white,
                            selectedTileColor: Colors.white24,
                            selected: location == item.route,
                            onTap: () => context.go(item.route),
                          ),
                        )
                        .toList(),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.white),
                  title: const Text('Log out', style: TextStyle(color: Colors.white)),
                  onTap: () async {
                    await context.read<AuthProvider>().logout();
                    if (context.mounted) context.go(RouteNames.login);
                  },
                ),
              ],
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}
