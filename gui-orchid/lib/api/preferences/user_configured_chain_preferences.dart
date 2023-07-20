// @dart=2.9
import 'dart:convert';
import 'package:orchid/api/orchid_eth/chains.dart';
import 'package:orchid/api/preferences/user_preferences.dart';
import 'package:orchid/api/preferences/user_preferences_vpn.dart';
import '../orchid_log.dart';
import 'observable_preference.dart';

class ObservableUserConfiguredChainPreference
    extends ObservablePreference<List<UserConfiguredChain>> {
  ObservableUserConfiguredChainPreference(UserPreferenceKey key)
      : super(
            key: key,
            getValue: (key) {
              try {
                final value = UserPreferences().getStringForKey(key);
                if (value == null) {
                  return [];
                }
                final jsonList = jsonDecode(value) as List<dynamic>;
                List<UserConfiguredChain> list = jsonList.map((el) {
                  return UserConfiguredChain.fromJson(el);
                }).toList();
                return list;
              } catch (err) {
                log("Error reading preference: $key, $err");
                return [];
              }
            },
            putValue: (key, List<UserConfiguredChain> list) async {
              try {
                final json = jsonEncode(list);
                return UserPreferences().putStringForKey(key, json);
              } catch (err) {
                log("Error saving preference: $key, $err");
              }
            });

  Future<void> add(UserConfiguredChain chain) async {
    var chains = ((this.get()) ?? []) + [chain];
    return await this.set(chains);
  }

  Future<void> remove(UserConfiguredChain chain) async {
    var chains = this.get();
    chains.remove(chain);
    return await this.set(chains);
  }
}
