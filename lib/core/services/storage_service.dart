import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';

import 'supabase_service.dart';

class StorageService {
  Future<String> uploadProfileImage({
    required String fileName,
    required Uint8List bytes,
  }) async {
    final userId = SupabaseService.client.auth.currentUser?.id ?? 'public';
    final path = 'profiles/$userId/$fileName';
    await SupabaseService.client.storage.from('profile-images').uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );
    return SupabaseService.client.storage.from('profile-images').getPublicUrl(path);
  }

  Future<String> uploadOfferLetter({
    required String employeeId,
    required String fileName,
    required Uint8List bytes,
  }) async {
    final path = 'offer-letters/$employeeId/$fileName';
    await SupabaseService.client.storage.from('employee-documents').uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );
    return SupabaseService.client.storage.from('employee-documents').getPublicUrl(path);
  }
}
