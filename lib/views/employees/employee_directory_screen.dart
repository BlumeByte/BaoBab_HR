import 'dart:typed_data';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../core/constants/app_constants.dart';
import '../../core/services/employee_service.dart';
import '../../core/services/storage_service.dart';
import '../../models/employee_model.dart';

class EmployeeDirectoryScreen extends StatefulWidget {
  const EmployeeDirectoryScreen({super.key});

  @override
  State<EmployeeDirectoryScreen> createState() => _EmployeeDirectoryScreenState();
}

class _EmployeeDirectoryScreenState extends State<EmployeeDirectoryScreen> {
  final _service = EmployeeService();
  final _storageService = StorageService();
  bool _loading = true;
  List<EmployeeRecord> _employees = const [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  Future<void> _loadEmployees() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _service.fetchEmployees();
      if (!mounted) return;
      setState(() {
        _employees = data;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Unable to fetch employees. Please verify Supabase table permissions. ($e)';
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _exportCsv() async {
    if (_employees.isEmpty) return;
    final headers = ['Name', 'Email', 'Department', 'Job Title', 'Status'];
    final lines = <String>[headers.join(',')];
    for (final e in _employees) {
      lines.add([
        e.fullName,
        e.email,
        e.department,
        e.jobTitle,
        e.status,
      ].map((v) => '"${v.replaceAll('"', '""')}"').join(','));
    }
    final csv = lines.join('\n');
    await Printing.sharePdf(bytes: Uint8List.fromList(utf8.encode(csv)), filename: 'employees.csv');
  }

  Future<void> _exportPdf() async {
    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        build: (_) => [
          pw.Text('Employees', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 12),
          pw.Table.fromTextArray(
            headers: const ['Name', 'Email', 'Department', 'Job Title', 'Status'],
            data: _employees
                .map((e) => [e.fullName, e.email, e.department, e.jobTitle, e.status])
                .toList(),
          ),
        ],
      ),
    );
    await Printing.layoutPdf(onLayout: (_) async => doc.save());
  }

  Future<void> _showCreateEmployeeDialog() async {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final deptController = TextEditingController();
    final roleController = TextEditingController();
    final avatarController = TextEditingController(text: AppConstants.defaultAvatar);
    String offerLetterUrl = '';

    Future<void> uploadAvatar() async {
      final result = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
      if (result == null || result.files.single.bytes == null) return;
      final file = result.files.single;
      final url = await _storageService.uploadProfileImage(
        fileName: file.name,
        bytes: file.bytes!,
      );
      avatarController.text = url;
    }

    Future<void> uploadOfferLetter() async {
      final result = await FilePicker.platform.pickFiles(withData: true, allowMultiple: false);
      if (result == null || result.files.single.bytes == null) return;
      final file = result.files.single;
      final key = emailController.text.trim().isEmpty ? 'new-employee' : emailController.text.trim();
      offerLetterUrl = await _storageService.uploadOfferLetter(
        employeeId: key,
        fileName: file.name,
        bytes: file.bytes!,
      );
    }

    final created = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setInnerState) => AlertDialog(
          title: const Text('Create employee'),
          content: SizedBox(
            width: 460,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Full name')),
                  TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Work email')),
                  TextField(controller: deptController, decoration: const InputDecoration(labelText: 'Department')),
                  TextField(controller: roleController, decoration: const InputDecoration(labelText: 'Job title')),
                  TextField(controller: avatarController, decoration: const InputDecoration(labelText: 'Avatar URL')),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: () async {
                          await uploadAvatar();
                          setInnerState(() {});
                        },
                        icon: const Icon(Icons.image_outlined),
                        label: const Text('Upload avatar'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: () async {
                          await uploadOfferLetter();
                          setInnerState(() {});
                        },
                        icon: const Icon(Icons.description_outlined),
                        label: const Text('Upload offer letter'),
                      ),
                    ],
                  ),
                  if (offerLetterUrl.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text('Offer letter uploaded', style: Theme.of(context).textTheme.bodySmall),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                try {
                  await _service.createEmployee(
                    fullName: nameController.text.trim(),
                    email: emailController.text.trim(),
                    department: deptController.text.trim(),
                    jobTitle: roleController.text.trim(),
                    avatarUrl: avatarController.text.trim(),
                    offerLetterUrl: offerLetterUrl,
                  );
                  await _service.sendPasswordSetupLink(emailController.text.trim());
                  if (dialogContext.mounted) Navigator.pop(dialogContext, true);
                } catch (e) {
                  if (!dialogContext.mounted) return;
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(content: Text('Failed to create employee: $e')),
                  );
                }
              },
              child: const Text('Save & send password setup link'),
            ),
          ],
        ),
      ),
    );

    nameController.dispose();
    emailController.dispose();
    deptController.dispose();
    roleController.dispose();
    avatarController.dispose();

    if (created == true) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Employee created and password setup link sent.')),
      );
      await _loadEmployees();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('Employee Directory', style: Theme.of(context).textTheme.headlineSmall)),
              OutlinedButton.icon(
                onPressed: _employees.isEmpty ? null : _exportCsv,
                icon: const Icon(Icons.table_chart_outlined),
                label: const Text('Export CSV'),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: _employees.isEmpty ? null : _exportPdf,
                icon: const Icon(Icons.picture_as_pdf_outlined),
                label: const Text('Export PDF'),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: _showCreateEmployeeDialog,
                icon: const Icon(Icons.person_add_alt_1),
                label: const Text('Add employee'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text('Connected to Supabase. Create employees, upload profile pictures and offer letters, and send password setup links.'),
          const SizedBox(height: 20),
          if (_loading) const Expanded(child: Center(child: CircularProgressIndicator())),
          if (_error != null && !_loading) Expanded(child: Center(child: Text(_error!))),
          if (!_loading && _error == null)
            Expanded(
              child: Card(
                child: ListView.separated(
                  itemCount: _employees.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final employee = _employees[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: employee.avatarUrl.isEmpty ? null : NetworkImage(employee.avatarUrl),
                        child: employee.avatarUrl.isEmpty ? Text(employee.fullName.isEmpty ? '?' : employee.fullName[0]) : null,
                      ),
                      title: Text(employee.fullName),
                      subtitle: Text('${employee.department} • ${employee.jobTitle}\n${employee.email}'),
                      isThreeLine: true,
                      trailing: Chip(label: Text(employee.status)),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
