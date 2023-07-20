import 'package:flutter/foundation.dart';
import 'package:orchid/api/orchid_log.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  /// The shared instance, initialized by init()
  SharedPreferences? _sharedPreferences;

  bool get initialized {
    return _sharedPreferences != null;
  }

  @protected
  /// This should be awaited during app launch.
  Future<void> initSharedPreferences() async {
    if (!initialized) {
      log("Initialized user preferences API");
      _sharedPreferences = await SharedPreferences.getInstance();
    }
  }

  /// This shouldd be awaited in main before launching the app.
  static Future<void> init() async {
    return UserPreferences().initSharedPreferences();
  }

  SharedPreferences sharedPreferences() {
    if (!initialized) {
      throw Exception("UserPreferences uninitialized.");
    }
    return _sharedPreferences!;
  }

  String? getStringForKey(UserPreferenceKey key) {
    return sharedPreferences().getString(key.toString());
  }

  // This method maps null to property removal.
  Future<bool> putStringForKey(UserPreferenceKey key, String? value) async {
    var shared = sharedPreferences();
    if (value == null) {
      return await shared.remove(key.toString());
    }
    return await shared.setString(key.toString(), value);
  }
}

abstract class UserPreferenceKey {
  String toString();
}
