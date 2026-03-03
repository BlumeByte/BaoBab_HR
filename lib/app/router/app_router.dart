import 'package:baobab_hr/screens/attendance/attendance_screen.dart';
import 'package:baobab_hr/screens/auth/login_screen.dart';
import 'package:baobab_hr/screens/dashboard/admin_dashboard.dart';
import 'package:baobab_hr/screens/dashboard/employee_dashboard.dart';
import 'package:baobab_hr/screens/leaves/leave_screen.dart';
import 'package:baobab_hr/screens/payroll/payroll_screen.dart';
import 'package:baobab_hr/screens/profile/profile_screen.dart';
import 'package:baobab_hr/screens/splash/splash_screen.dart';
import 'package:baobab_hr/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authService = ref.watch(authServiceProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) async {
      final isAuthenticated = authService.currentUser != null;

      // Use state.uri.path instead of state.location
      if (isAuthenticated) {
        final userRole = await authService.getUserRole();
        if (state.uri.path == '/login' || state.uri.path == '/splash') {
          return userRole == 'admin' ? '/admin' : '/employee';
        }
      } else if (state.uri.path != '/login' && state.uri.path != '/splash') {
        return '/login';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/employee',
        name: 'employee',
        builder: (context, state) => const EmployeeDashboard(),
      ),
      GoRoute(
        path: '/admin',
        name: 'admin',
        builder: (context, state) => const AdminDashboard(),
      ),
      GoRoute(
        path: '/attendance',
        name: 'attendance',
        builder: (context, state) => const AttendanceScreen(),
      ),
      GoRoute(
        path: '/leaves',
        name: 'leaves',
        builder: (context, state) => const LeaveScreen(),
      ),
      GoRoute(
        path: '/payroll',
        name: 'payroll',
        builder: (context, state) => const PayrollScreen(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
});
