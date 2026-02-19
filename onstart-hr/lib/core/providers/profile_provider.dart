import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';

class ProfileProvider extends ChangeNotifier {
  String _displayName = 'Alex Morgan';
  String _avatarUrl = AppConstants.defaultAvatar;

  String get displayName => _displayName;
  String get avatarUrl => _avatarUrl;

  void updateProfile({required String name, required String avatarUrl}) {
    _displayName = name.trim().isEmpty ? _displayName : name.trim();
    _avatarUrl = avatarUrl.trim().isEmpty ? AppConstants.defaultAvatar : avatarUrl.trim();
    notifyListeners();
  }
}
