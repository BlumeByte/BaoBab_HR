class ReportExportService {
  String toCsv(List<String> headers, List<List<String>> rows) {
    final escapedHeaders = headers.map(_escape).join(',');
    final body = rows.map((row) => row.map(_escape).join(',')).join('\n');
    return '$escapedHeaders\n$body';
  }

  String _escape(String value) {
    final escaped = value.replaceAll('"', '""');
    return '"$escaped"';
  }
}
