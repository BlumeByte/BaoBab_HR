import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/app_constants.dart';
import '../services/supabase_service.dart';

class ProfileProvider extends ChangeNotifier {
  String _displayName = 'Alex Morgan';
  String _avatarUrl = AppConstants.defaultAvatar;
  String _role = 'hr';

  String get displayName => _displayName;
  String get avatarUrl => _avatarUrl;
  String get role => _role;

  Future<void> loadProfile() async {
    final user = SupabaseService.client.auth.currentUser;
    if (user == null) return;

    try {
      final profile = await SupabaseService.client
          .from('profiles')
          .select('full_name, avatar_url, role')
          .eq('id', user.id)
          .maybeSingle();

      if (profile != null) {
        _displayName = (profile['full_name'] ?? _displayName).toString();
        _avatarUrl =
            (profile['avatar_url'] ?? AppConstants.defaultAvatar).toString();
        _role = (profile['role'] ?? _role).toString();
      } else {
        _displayName =
            (user.userMetadata?['full_name'] ?? _displayName).toString();
        _avatarUrl =
            (user.userMetadata?['avatar_url'] ?? AppConstants.defaultAvatar)
                .toString();
        _role = (user.userMetadata?['role'] ?? _role).toString();
      }
      notifyListeners();
    } catch (_) {
      _displayName =
          (user.userMetadata?['full_name'] ?? _displayName).toString();
      _avatarUrl =
          (user.userMetadata?['avatar_url'] ?? AppConstants.defaultAvatar)
              .toString();
      _role = (user.userMetadata?['role'] ?? _role).toString();
      notifyListeners();
    }
  }

  Future<void> updateProfile(
      {required String name, required String avatarUrl}) async {
    final user = SupabaseService.client.auth.currentUser;
    if (user == null) return;

    final nextName = name.trim().isEmpty ? _displayName : name.trim();
    final nextAvatar = avatarUrl.trim().isEmpty
        ? AppConstants.defaultAvatar
        : avatarUrl.trim();

    await SupabaseService.client.from('profiles').upsert({
      'id': user.id,
      'email': user.email,
      'full_name': nextName,
      'avatar_url': nextAvatar,
      'role': _role,
    });

    await SupabaseService.client.auth.updateUser(
      UserAttributes(
        data: {'full_name': nextName, 'avatar_url': nextAvatar, 'role': _role},
      ),
    );

    _displayName = nextName;
    _avatarUrl = nextAvatar;
    notifyListeners();
  }

  void resetLocal() {
    _displayName = 'Alex Morgan';
    _avatarUrl = AppConstants.defaultAvatar;
    _role = 'hr';
    notifyListeners();
  }
}
