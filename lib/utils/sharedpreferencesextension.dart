import 'package:shared_preferences/shared_preferences.dart';


enum SharedPreferencesKeys {
  playerId,
  username,
  password,
}

extension SharedPreferencesExtension on SharedPreferences {
  Future<void> setStringKey(SharedPreferencesKeys key, String value) async {
    await setString(key.toString().split('.').last, value);
  }

  String? getStringKey(SharedPreferencesKeys key) {
    return getString(key.toString().split('.').last);
  }
}