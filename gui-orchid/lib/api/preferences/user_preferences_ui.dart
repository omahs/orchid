import 'package:orchid/api/preferences/observable_preference.dart';
import 'user_preferences.dart';

class UserPreferencesUI {
  static final UserPreferencesUI _singleton = UserPreferencesUI._internal();

  factory UserPreferencesUI() {
    return _singleton;
  }

  UserPreferencesUI._internal();

  ///
  /// UI
  ///

  /// User locale override (e.g. en, pt_BR)
  ObservableStringPreference languageOverride =
      ObservableStringPreference(UserPreferenceKeyUI.LanguageOverride);

  /// Identicons UI
  ObservableBoolPreference useBlockiesIdenticons = ObservableBoolPreference(
      UserPreferenceKeyUI.UseBlockiesIdenticons,
      defaultValue: true);
}

enum UserPreferenceKeyUI implements UserPreferenceKey {
  LanguageOverride,
  UseBlockiesIdenticons,
}
