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

  /// User configuration JS for app customization and testing.
  ObservableStringPreference userConfig =
      ObservableStringPreference(_UserPreferenceKeyUI.UserConfig);

  /// User locale override (e.g. en, pt_BR)
  ObservableStringPreference languageOverride =
      ObservableStringPreference(_UserPreferenceKeyUI.LanguageOverride);

  /// Identicons UI
  ObservableBoolPreference useBlockiesIdenticons = ObservableBoolPreference(
      _UserPreferenceKeyUI.UseBlockiesIdenticons,
      defaultValue: true);
}

enum _UserPreferenceKeyUI implements UserPreferenceKey {
  UserConfig,
  LanguageOverride,
  UseBlockiesIdenticons,
}
