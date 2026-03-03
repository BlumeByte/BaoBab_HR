// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/providers/auth_provider.dart';
import '../../core/providers/profile_provider.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/router/route_names.dart';
import 'loading_widget.dart';

class NavItem {
  const NavItem(this.label, this.icon, this.route);
  final String label;
  final IconData icon;
  final String route;
}

const navItems = [
  NavItem('Dashboard', Icons.dashboard_outlined, RouteNames.hrDashboard),
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
  NavItem('Billing', Icons.credit_card_outlined, RouteNames.billing),
];

class MainLayout extends StatelessWidget {
  const MainLayout({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>();
    final auth = context.watch<AuthProvider>();
    final theme = context.watch<ThemeProvider>();
    final location = GoRouterState.of(context).uri.path;
    final isMobile = MediaQuery.of(context).size.width < 960;

    final dashboardRoute = auth.isSuperAdmin
        ? RouteNames.superDashboard
        : auth.isHrAdmin
            ? RouteNames.hrDashboard
            : RouteNames.employeeDashboard;

    final items = navItems
        .map((item) => item.label == 'Dashboard' ? NavItem(item.label, item.icon, dashboardRoute) : item)
        .toList();

    final visibleNavItems = auth.isSuperAdmin
        ? items
        : auth.isHrAdmin
            ? items.where((item) => item.route != RouteNames.superDashboard).toList()
            : items
                .where((item) => {
                      RouteNames.employeeDashboard,
                      RouteNames.employeeProfile,
                      RouteNames.documents,
                      RouteNames.leave,
                      RouteNames.announcements,
                    }.contains(item.route))
                .toList();

    Widget sidebar() => Container(
          width: isMobile ? 280 : 250,
          color: theme.isDarkMode ? const Color(0xFF263238) : const Color(0xFF4FC3F7),
          child: Column(
            children: [
              const SizedBox(height: 24),
              const Text('Baobab HR', style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              CircleAvatar(backgroundImage: NetworkImage(profile.avatarUrl), radius: 26),
              const SizedBox(height: 8),
              Text(profile.displayName, style: const TextStyle(color: Colors.white)),
              const Divider(color: Colors.white70),
              Expanded(
                child: ListView(
                  children: visibleNavItems
                      .map(
                        (item) => ListTile(
                          leading: Icon(item.icon, color: Colors.white),
                          title: Text(item.label, style: const TextStyle(color: Colors.white)),
                          selected: location == item.route,
                          selectedTileColor: Colors.white24,
                          onTap: () {
                            if (isMobile) Navigator.of(context).pop();
                            context.go(item.route);
                          },
                        ),
                      )
                      .toList(),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.dark_mode_outlined, color: Colors.white),
                title: Text(theme.isDarkMode ? 'Light mode' : 'Dark mode', style: const TextStyle(color: Colors.white)),
                onTap: () => context.read<ThemeProvider>().toggleTheme(!theme.isDarkMode),
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.white),
                title: const Text('Log out', style: TextStyle(color: Colors.white)),
                onTap: () async {
                  await context.read<AuthProvider>().logout();
                  if (context.mounted) context.go(RouteNames.login);
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );

    final body = Stack(
      children: [
        Positioned.fill(child: child),
        if (auth.isLoading)
          Container(
            color: Colors.black.withOpacity(0.1),
            child: const LoadingWidget(),
          ),
      ],
    );

    return Scaffold(
      appBar: isMobile
          ? AppBar(
              title: const Text('Baobab HR'),
            )
          : null,
      drawer: isMobile ? Drawer(child: sidebar()) : null,
      body: isMobile
          ? body
          : Row(
              children: [
                sidebar(),
                Expanded(child: body),
              ],
            ),
    );
  }
}
