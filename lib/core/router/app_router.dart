import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../../views/announcements/announcements_feed_screen.dart';
import '../../views/attendance/timesheet_screen.dart';
import '../../views/auth/forgot_password_screen.dart';
import '../../views/auth/login_screen.dart';
import '../../views/dashboard/hr_dashboard.dart';
import '../../views/documents/document_library_screen.dart';
import '../../views/employees/employee_directory_screen.dart';
import '../../views/employees/employee_profile_screen.dart';
import '../../views/leave/leave_request_screen.dart';
import '../../views/performance/goals_screen.dart';
import '../../views/recruitment/jobs_screen.dart';
import '../../views/reports/headcount_report_screen.dart';
import '../../views/settings/company_settings_screen.dart';
import '../../views/shared/main_layout.dart';
import 'route_names.dart';

GoRouter createRouter(AuthProvider authProvider) {
  return GoRouter(
    initialLocation: RouteNames.login,
    refreshListenable: authProvider,
    redirect: (context, state) {
      final loggedIn = authProvider.isLoggedIn;
      final location = state.uri.path;
      final isPublic = location == RouteNames.login || location == RouteNames.forgotPassword;

      if (!loggedIn && !isPublic) return RouteNames.login;

      if (loggedIn && isPublic) {
        return authProvider.isEmployeeUser ? RouteNames.employeeProfile : RouteNames.dashboard;
      }

      if (loggedIn && authProvider.isEmployeeUser && location != RouteNames.employeeProfile) {
        return RouteNames.employeeProfile;
      }

      return null;
    },
    routes: [
      GoRoute(path: RouteNames.login, builder: (_, __) => const LoginScreen()),
      GoRoute(path: RouteNames.forgotPassword, builder: (_, __) => const ForgotPasswordScreen()),
      ShellRoute(
        builder: (_, __, child) => MainLayout(child: child),
        routes: [
          GoRoute(path: RouteNames.dashboard, builder: (_, __) => const HrDashboard()),
          GoRoute(path: RouteNames.employeeProfile, builder: (_, __) => const EmployeeProfileScreen()),
          GoRoute(path: RouteNames.employees, builder: (_, __) => const EmployeeDirectoryScreen()),
          GoRoute(path: RouteNames.leave, builder: (_, __) => const LeaveRequestScreen()),
          GoRoute(path: RouteNames.attendance, builder: (_, __) => const TimesheetScreen()),
          GoRoute(path: RouteNames.performance, builder: (_, __) => const GoalsScreen()),
          GoRoute(path: RouteNames.recruitment, builder: (_, __) => const JobsScreen()),
          GoRoute(path: RouteNames.documents, builder: (_, __) => const DocumentLibraryScreen()),
          GoRoute(path: RouteNames.reports, builder: (_, __) => const HeadcountReportScreen()),
          GoRoute(path: RouteNames.announcements, builder: (_, __) => const AnnouncementsFeedScreen()),
          GoRoute(path: RouteNames.settings, builder: (_, __) => const CompanySettingsScreen()),
        ],
      ),
    ],
  );
}
