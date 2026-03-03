import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/providers/profile_provider.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/services/storage_service.dart';

class CompanySettingsScreen extends StatefulWidget {
  const CompanySettingsScreen({super.key});

  @override
  State<CompanySettingsScreen> createState() => _CompanySettingsScreenState();
}

class _CompanySettingsScreenState extends State<CompanySettingsScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _avatarController;
  final _storageService = StorageService();
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileProvider>();
    _nameController = TextEditingController(text: profile.displayName);
    _avatarController = TextEditingController(text: profile.avatarUrl);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _avatarController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadProfileImage() async {
    setState(() => _uploading = true);
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
      if (result == null || result.files.single.bytes == null) return;
      final file = result.files.single;
      final fileName = file.name;
      final url = await _storageService.uploadProfileImage(
        fileName: fileName,
        bytes: file.bytes!,
      );
      _avatarController.text = url;
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: ListView(
        children: [
          Text('Settings', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          const Text('Update profile details and switch between light and dark mode.'),
          const SizedBox(height: 24),
          TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Profile Name')),
          const SizedBox(height: 12),
          TextField(controller: _avatarController, decoration: const InputDecoration(labelText: 'Profile Image URL')),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            children: [
              OutlinedButton.icon(
                onPressed: _uploading ? null : _pickAndUploadProfileImage,
                icon: const Icon(Icons.upload_file),
                label: Text(_uploading ? 'Uploading...' : 'Upload profile image'),
              ),
              if (_avatarController.text.isNotEmpty)
                CircleAvatar(
                  radius: 22,
                  backgroundImage: NetworkImage(_avatarController.text),
                ),
            ],
          ),
          const SizedBox(height: 20),
          SwitchListTile(
            title: const Text('Dark mode'),
            value: themeProvider.isDarkMode,
            onChanged: (value) async => themeProvider.toggleTheme(value),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () async {
              await context.read<ProfileProvider>().updateProfile(
                    name: _nameController.text,
                    avatarUrl: _avatarController.text,
                  );
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile updated')),
              );
            },
            child: const Text('Save settings'),
          ),
        ],
      ),
    );
  }
}
