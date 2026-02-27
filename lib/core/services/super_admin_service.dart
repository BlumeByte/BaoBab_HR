import 'package:supabase_flutter/supabase_flutter.dart';

import 'audit_service.dart';
import 'notification_service.dart';
import 'supabase_service.dart';

class SuperAdminMetrics {
  const SuperAdminMetrics({
    required this.totalCompanies,
    required this.activeSubscriptions,
    required this.totalEmployees,
    required this.monthlyRevenue,
  });

  final int totalCompanies;
  final int activeSubscriptions;
  final int totalEmployees;
  final double monthlyRevenue;
}

class SuperAdminService {
  SuperAdminService({SupabaseClient? client})
      : _client = client ?? SupabaseService.client,
        _audit = AuditService(client: client ?? SupabaseService.client),
        _notification = NotificationService(client: client ?? SupabaseService.client);

  final SupabaseClient _client;
  final AuditService _audit;
  final NotificationService _notification;

  Future<SuperAdminMetrics> fetchGlobalMetrics() async {
    final companiesCount = await _client.from('companies').select('id').count(CountOption.exact);
    final activeSubCount = await _client
        .from('subscriptions')
        .select('id')
        .inFilter('status', ['active', 'trial'])
        .count(CountOption.exact);
    final employeeCount = await _client.from('employees').select('id').count(CountOption.exact);

    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1).toIso8601String();
    final end = DateTime(now.year, now.month + 1, 1).toIso8601String();
    final payments = await _client
        .from('payments')
        .select('amount,status,paid_at,created_at')
        .eq('status', 'success')
        .gte('paid_at', start)
        .lt('paid_at', end);

    final monthlyRevenue = (payments as List)
        .cast<Map<String, dynamic>>()
        .fold<double>(0, (sum, row) => sum + _num(row['amount']));

    return SuperAdminMetrics(
      totalCompanies: companiesCount.count,
      activeSubscriptions: activeSubCount.count,
      totalEmployees: employeeCount.count,
      monthlyRevenue: monthlyRevenue,
    );
  }

  Future<List<Map<String, dynamic>>> fetchCompanies() async {
    final rows = await _client
        .from('companies')
        .select('id,name,slug,email,is_active,subscription_status,trial_end_at,created_at')
        .order('created_at', ascending: false);
    return (rows as List).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> fetchSubscriptions() async {
    final rows = await _client
        .from('subscriptions')
        .select('id,company_id,plan_name,status,starts_at,ends_at,created_at,companies(name,slug)')
        .order('created_at', ascending: false)
        .limit(100);
    return (rows as List).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> fetchUsersByRole(String role) async {
    final rows = await _client
        .from('users')
        .select('id,company_id,full_name,email,role,is_active,created_at,companies(name,slug)')
        .eq('role', role)
        .eq('is_active', true)
        .isFilter('deleted_at', null)
        .order('created_at', ascending: false)
        .limit(100);
    return (rows as List).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> fetchEmployees() async {
    final rows = await _client
        .from('employees')
        .select('id,company_id,user_id,full_name,work_email,employment_status,created_at,companies(name,slug)')
        .isFilter('deleted_at', null)
        .order('created_at', ascending: false)
        .limit(100);
    return (rows as List).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> fetchAuditLogs() async {
    final rows = await _client
        .from('audit_logs')
        .select('id,company_id,table_name,record_id,action,created_at,companies(name,slug),users(full_name,email)')
        .order('created_at', ascending: false)
        .limit(100);
    return (rows as List).cast<Map<String, dynamic>>();
  }

  Future<void> suspendCompany(String companyId) {
    return _suspendCompanyInternal(companyId);
  }

  Future<void> _suspendCompanyInternal(String companyId) async {
    await _client.from('companies').update({'is_active': false, 'subscription_status': 'cancelled'}).eq('id', companyId);
    await _audit.logAction(action: 'SUSPEND_COMPANY', tableName: 'companies', recordId: companyId);
  }

  Future<void> removeHr(String userId) async {
    final user = await _client.from('users').select('email').eq('id', userId).maybeSingle();
    await _client
        .from('users')
        .update({'is_active': false, 'deleted_at': DateTime.now().toIso8601String()})
        .eq('id', userId)
        .eq('role', 'hr_admin');
    await _audit.logAction(action: 'REMOVE_HR', tableName: 'users', recordId: userId);
    if (user?['email'] != null) {
      await _notification.sendEmailNotification(
        to: user!['email'].toString(),
        subject: 'HR access removed',
        message: 'Your HR admin access has been removed by a Super Admin.',
      );
    }
  }

  Future<void> removeEmployee({required String employeeId, String? userId}) async {
    final employee = await _client.from('employees').select('work_email').eq('id', employeeId).maybeSingle();
    await _client.from('employees').update({
      'employment_status': 'terminated',
      'deleted_at': DateTime.now().toIso8601String(),
    }).eq('id', employeeId);
    if (userId != null && userId.isNotEmpty) {
      await _client
          .from('users')
          .update({'is_active': false, 'deleted_at': DateTime.now().toIso8601String()})
          .eq('id', userId);
    }
    await _audit.logAction(action: 'REMOVE_EMPLOYEE', tableName: 'employees', recordId: employeeId);
    if (employee?['work_email'] != null) {
      await _notification.sendEmailNotification(
        to: employee!['work_email'].toString(),
        subject: 'Employment status updated',
        message: 'Your employee account has been deactivated by an administrator.',
      );
    }
  }

  double _num(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }
}
