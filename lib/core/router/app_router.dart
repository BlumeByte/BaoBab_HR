import 'package:go_router/go_router.dart';

import '../../views/announcements/announcements_feed_screen.dart';
import '../../views/attendance/timesheet_screen.dart';
import '../../views/auth/forgot_password_screen.dart';
import '../../views/auth/login_screen.dart';
import '../../views/auth/verify_email_screen.dart';
import '../../views/dashboard/hr_dashboard.dart';
import '../../views/documents/document_library_screen.dart';
import '../../views/employees/employee_directory_screen.dart';
import '../../views/employees/employee_profile_screen.dart';
import '../../views/leave/leave_request_screen.dart';
import '../../views/performance/goals_screen.dart';
import '../../views/recruitment/jobs_screen.dart';
import '../../views/reports/headcount_report_screen.dart';
import '../../views/settings/billing_screen.dart';
import '../../views/settings/company_settings_screen.dart';
import '../../views/shared/main_layout.dart';
import '../providers/auth_provider.dart';
import 'route_names.dart';

GoRouter createRouter(AuthProvider authProvider) {
  String homeByRole() {
    if (authProvider.isSuperAdmin) return RouteNames.superDashboard;
    if (authProvider.isHrAdmin) return RouteNames.hrDashboard;
    return RouteNames.employeeDashboard;
  }

  bool allowedForRole(String path) {
    if (authProvider.isSuperAdmin) return true;

    if (authProvider.isHrAdmin) {
      return {
        RouteNames.hrDashboard,
        RouteNames.employees,
        RouteNames.leave,
        RouteNames.attendance,
        RouteNames.performance,
        RouteNames.recruitment,
        RouteNames.documents,
        RouteNames.reports,
        RouteNames.announcements,
        RouteNames.settings,
        RouteNames.billing,
      }.contains(path);
    }

    return {
      RouteNames.employeeDashboard,
      RouteNames.employeeProfile,
      RouteNames.documents,
      RouteNames.leave,
      RouteNames.announcements,
    }.contains(path);
  }

  return GoRouter(
    initialLocation: RouteNames.login,
    refreshListenable: authProvider,
    redirect: (_, state) {
      final location = state.uri.path;
      final publicRoutes = {
        RouteNames.login,
        RouteNames.forgotPassword,
        RouteNames.verifyEmail,
      };

      final loggedIn = authProvider.isLoggedIn;
      final isPublic = publicRoutes.contains(location);

      if (!loggedIn && !isPublic) return RouteNames.login;

      if (loggedIn &&
          (location == RouteNames.login ||
              location == RouteNames.employeeLogin)) {
        return homeByRole();
      }

      if (loggedIn &&
          !authProvider.isEmailVerified &&
          location != RouteNames.verifyEmail) {
        return RouteNames.verifyEmail;
      }

      if (loggedIn && !isPublic && !allowedForRole(location)) {
        return RouteNames.unauthorized;
      }

      return null;
    },
    routes: [
      GoRoute(path: RouteNames.login, builder: (_, __) => const LoginScreen()),
      GoRoute(
          path: RouteNames.forgotPassword,
          builder: (_, __) => const ForgotPasswordScreen()),
      GoRoute(
          path: RouteNames.verifyEmail,
          builder: (_, __) => const VerifyEmailScreen()),
      ShellRoute(
        builder: (_, __, child) => MainLayout(child: child),
        routes: [
          GoRoute(
              path: RouteNames.superDashboard,
              builder: (_, __) => const SuperDashboard()),
          GoRoute(
              path: RouteNames.hrDashboard,
              builder: (_, __) => const HrDashboard()),
          GoRoute(
              path: RouteNames.employeeDashboard,
              builder: (_, __) => const EmployeeDashboard()),
          GoRoute(
              path: RouteNames.employeeProfile,
              builder: (_, __) => const EmployeeProfileScreen()),
          GoRoute(
              path: RouteNames.employees,
              builder: (_, __) => const EmployeeDirectoryScreen()),
          GoRoute(
              path: RouteNames.leave,
              builder: (_, __) => const LeaveRequestScreen()),
          GoRoute(
              path: RouteNames.attendance,
              builder: (_, __) => const TimesheetScreen()),
          GoRoute(
              path: RouteNames.performance,
              builder: (_, __) => const GoalsScreen()),
          GoRoute(
              path: RouteNames.recruitment,
              builder: (_, __) => const JobsScreen()),
          GoRoute(
              path: RouteNames.documents,
              builder: (_, __) => const DocumentLibraryScreen()),
          GoRoute(
              path: RouteNames.reports,
              builder: (_, __) => const HeadcountReportScreen()),
          GoRoute(
              path: RouteNames.announcements,
              builder: (_, __) => const AnnouncementsFeedScreen()),
          GoRoute(
              path: RouteNames.settings,
              builder: (_, __) => const CompanySettingsScreen()),
          GoRoute(
              path: RouteNames.billing,
              builder: (_, __) => const BillingScreen()),
        ],
      ),
    ],
  );
}
