// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/providers/auth_provider.dart';
import '../../core/providers/profile_provider.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/router/route_names.dart';
import 'loading_widget.dart';
import 'toast.dart';

class NavItem {
  const NavItem(this.label, this.icon, this.route);
  final String label;
  final IconData icon;
  final String route;
}

const navItems = [
  NavItem('Super Dashboard', Icons.admin_panel_settings_outlined, RouteNames.superDashboard),
  NavItem('HR Dashboard', Icons.dashboard_outlined, RouteNames.hrDashboard),
  NavItem('Employee Dashboard', Icons.space_dashboard_outlined, RouteNames.employeeDashboard),
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
    final theme = context.watch<ThemeProvider>();
    final location = GoRouterState.of(context).uri.path;
    final isMobile = MediaQuery.of(context).size.width < 1024;

    final visibleNavItems = auth.isSuperAdmin
        ? navItems
        : auth.isHrAdmin
            ? navItems
                .where((item) =>
                    item.route != RouteNames.superDashboard && item.route != RouteNames.employeeDashboard)
                .toList()
            : navItems
                .where((item) => {
                      RouteNames.employeeDashboard,
                      RouteNames.employeeProfile,
                      RouteNames.documents,
                      RouteNames.leave,
                      RouteNames.announcements,
                    }.contains(item.route))
                .toList();

    final sidebarColor = theme.isDarkMode ? const Color(0xFFA5D6A7) : const Color(0xFF4FC3F7);

    Widget sidebar() {
      return Container(
        width: isMobile ? 300 : 260,
        color: sidebarColor,
        child: Column(
          children: [
            const SizedBox(height: 26),
            const Text(
              'Baobab HR',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 24),
            CircleAvatar(backgroundImage: NetworkImage(profile.avatarUrl), radius: 28),
            const SizedBox(height: 8),
            Text(
              profile.displayName,
              style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
            ),
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
                        onTap: () {
                          if (isMobile) Navigator.of(context).pop();
                          context.go(item.route);
                        },
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      );
    }

    Future<void> onMenuSelected(_TopBarMenu value) async {
      if (value == _TopBarMenu.settings) {
        context.go(RouteNames.settings);
        return;
      }

      if (value == _TopBarMenu.toggleTheme) {
        await context.read<ThemeProvider>().toggleTheme(!theme.isDarkMode);
        if (!context.mounted) return;
        AppToast.show(context, theme.isDarkMode ? 'Dark mode enabled' : 'Light mode enabled');
        return;
      }

      if (value == _TopBarMenu.logout) {
        await context.read<AuthProvider>().logout();
        if (!context.mounted) return;
        AppToast.show(context, 'Logged out successfully');
        context.go(RouteNames.login);
      }
    }

    Widget topBar = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.2))),
      ),
      child: Row(
        children: [
          if (isMobile)
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
          if (isMobile) const SizedBox(width: 8),
          Expanded(
            child: Text(
              'BaoBab HR Workspace',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          if (auth.isLoading || theme.isSaving)
            const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
          const SizedBox(width: 8),
          PopupMenuButton<_TopBarMenu>(
            onSelected: onMenuSelected,
            itemBuilder: (context) => const [
              PopupMenuItem(value: _TopBarMenu.settings, child: Text('Settings')),
              PopupMenuItem(value: _TopBarMenu.toggleTheme, child: Text('Toggle dark mode')),
              PopupMenuItem(value: _TopBarMenu.logout, child: Text('Logout')),
            ],
            child: Row(
              children: [
                CircleAvatar(backgroundImage: NetworkImage(profile.avatarUrl), radius: 18),
                const SizedBox(width: 8),
                Text(profile.displayName),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ],
      ),
    );

    final bodyContent = Column(
      children: [
        topBar,
        Expanded(
          child: Stack(
            children: [
              Positioned.fill(child: child),
              if (auth.isLoading)
                Container(
                  color: Colors.black.withOpacity(0.08),
                  child: const LoadingWidget(),
                ),
            ],
          ),
        ),
      ],
    );

    return Scaffold(
      drawer: isMobile ? Drawer(child: sidebar()) : null,
      body: isMobile
          ? bodyContent
          : Row(
              children: [
                sidebar(),
                Expanded(child: bodyContent),
              ],
            ),
    );
  }
}

enum _TopBarMenu { settings, toggleTheme, logout }
