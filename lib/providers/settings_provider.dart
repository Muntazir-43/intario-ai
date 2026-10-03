import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState {
  final ThemeMode themeMode;
  final bool autoSave;
  final bool pushNotifications;
  final bool isPro;

  const SettingsState({
    this.themeMode         = ThemeMode.light, // Default set to Light Mode
    this.autoSave          = true,
    this.pushNotifications = true,
    this.isPro             = false,
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    bool? autoSave,
    bool? pushNotifications,
    bool? isPro,
  }) {
    return SettingsState(
      themeMode:         themeMode         ?? this.themeMode,
      autoSave:          autoSave          ?? this.autoSave,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      isPro:             isPro             ?? this.isPro,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(const SettingsState()) {
    _loadSettings();
  }

  static const _keyThemeMode     = 'themeMode';
  static const _keyAutoSave      = 'autoSave';
  static const _keyNotifications = 'pushNotifications';
  static const _keyIsPro         = 'isPro';

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load saved index
    final savedIndex = prefs.getInt(_keyThemeMode);
    
    // Migration Logic: 
    // If no setting exists OR it was set to System (index 0), default to Light (index 1)
    final themeIndex = (savedIndex == null || savedIndex == 0) 
        ? ThemeMode.light.index 
        : savedIndex;
    
    state = state.copyWith(
      themeMode:         ThemeMode.values[themeIndex],
      autoSave:          prefs.getBool(_keyAutoSave)       ?? true,
      pushNotifications: prefs.getBool(_keyNotifications)  ?? true,
      isPro:             prefs.getBool(_keyIsPro)         ?? false,
    );
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyThemeMode,      state.themeMode.index);
    await prefs.setBool(_keyAutoSave,       state.autoSave);
    await prefs.setBool(_keyNotifications,  state.pushNotifications);
    await prefs.setBool(_keyIsPro,         state.isPro);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _persist();
  }

  Future<void> toggleAutoSave() async {
    state = state.copyWith(autoSave: !state.autoSave);
    await _persist();
  }

  Future<void> toggleNotifications() async {
    state = state.copyWith(pushNotifications: !state.pushNotifications);
    await _persist();
  }

  Future<void> setProStatus(bool isPro) async {
    state = state.copyWith(isPro: isPro);
    await _persist();
  }
}

final settingsProvider =
StateNotifierProvider<SettingsNotifier, SettingsState>(
      (ref) => SettingsNotifier(),
);
