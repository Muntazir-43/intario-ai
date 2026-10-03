import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/profile_state.dart';

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier();
});

class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier()
      : super(const ProfileState(
          name: "Guest User",
          email: "guest@intario.ai",
        )) {
    _loadProfile();
  }

  static const String _nameKey = 'profile_name';
  static const String _avatarKey = 'profile_avatar_path';

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_nameKey) ?? "Guest User";
    final avatarPath = prefs.getString(_avatarKey);
    
    state = state.copyWith(
      name: name,
      avatarPath: avatarPath,
    );
  }

  Future<void> setName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, name);
    state = state.copyWith(name: name);
  }

  Future<void> setAvatar(String? path) async {
    final prefs = await SharedPreferences.getInstance();
    if (path == null) {
      await prefs.remove(_avatarKey);
    } else {
      await prefs.setString(_avatarKey, path);
    }
    state = state.copyWith(avatarPath: path);
  }
}
