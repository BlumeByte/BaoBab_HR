/// Stub implementation of the SuperAdminService.
///
/// This minimal class is provided so that widgets depending on
/// [SuperAdminService] can compile without pulling in the full
/// Supabase-based implementation. In a production environment,
/// replace this file with the complete service that interacts with
/// your backend.
class SuperAdminService {
  /// Creates a [SuperAdminService]. In the full implementation you
  /// would pass a database client here (for example, a Supabase
  /// client). Because this stub does not interact with a backend, the
  /// constructor takes no parameters.
  SuperAdminService();

  /// Fetches a list of audit log entries. Each entry is represented
  /// as a map of string keys to dynamic values. The default
  /// implementation returns an empty list. Replace this stub with
  /// your own logic to fetch audit logs from your data source.
  Future<List<Map<String, dynamic>>> fetchAuditLogs() async {
    return const [];
  }
}