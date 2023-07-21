import 'dart:convert';
import 'package:orchid/api/orchid_crypto.dart';
import 'package:orchid/api/orchid_eth/orchid_chain_config.dart';
import 'package:orchid/api/preferences/observable_preference.dart';
import 'package:orchid/api/orchid_eth/orchid_account.dart';
import 'package:orchid/api/preferences/user_configured_chain_preferences.dart';
import 'package:orchid/api/preferences/user_preferences_mock.dart';
import 'package:orchid/api/orchid_eth/orchid_account_mock.dart';
import 'package:orchid/api/vpn/purchase/orchid_pac_transaction.dart';
import 'package:orchid/pages/circuit/model/circuit.dart';
import '../orchid_log.dart';
import 'accounts_preferences.dart';
import 'chain_config_preferences.dart';
import 'user_preferences.dart';

class UserPreferencesVPN {
  static final UserPreferencesVPN _singleton = UserPreferencesVPN._internal();

  factory UserPreferencesVPN() {
    return _singleton;
  }

  UserPreferencesVPN._internal();

  ///
  /// Begin: Circuit
  ///

  ObservablePreference<Circuit> circuit = ObservablePreference(
      key: UserPreferenceKeyVPN.Circuit,
      getValue: (key) {
        return _getCircuit();
      },
      putValue: (key, circuit) {
        return _setCircuit(circuit);
      });

  // Set the circuit / hops configuration
  static Future<bool> _setCircuit(Circuit circuit) async {
    String? value = circuit != null ? jsonEncode(circuit) : null;
    return UserPreferences()
        .putStringForKey(UserPreferenceKeyVPN.Circuit, value);
  }

  // Get the circuit / hops configuration
  // This default to an empty [] circuit if uninitialized.
  static Circuit _getCircuit() {
    if (AccountMock.mockAccounts) {
      return UserPreferencesMock.mockCircuit;
    }
    String? value =
        UserPreferences().getStringForKey(UserPreferenceKeyVPN.Circuit);
    return value == null ? Circuit([]) : Circuit.fromJson(jsonDecode(value));
  }

  ///
  /// End: Circuit
  ///

  ///
  /// Begin: Keys
  ///

  /// Return the user's keys or [] empty array if uninitialized.
  ObservablePreference<List<StoredEthereumKey>> keys = ObservablePreference(
      key: UserPreferenceKeyVPN.Keys,
      getValue: (key) {
        return _getKeys();
      },
      putValue: (key, keys) {
        return _setKeys(keys);
      });

  /// Return the user's keys or [] empty array if uninitialized.
  static List<StoredEthereumKey> _getKeys() {
    if (AccountMock.mockAccounts) {
      return AccountMock.mockKeys;
    }

    String? value =
        UserPreferences().getStringForKey(UserPreferenceKeyVPN.Keys);
    if (value == null) {
      return [];
    }
    try {
      var jsonList = jsonDecode(value) as List<dynamic>;
      return jsonList
          .map((el) {
            try {
              return StoredEthereumKey.fromJson(el);
            } catch (err) {
              log("Error decoding key: $err");
              return null;
            }
          })
          .whereType<StoredEthereumKey>()
          .toList();
    } catch (err) {
      log("Error retrieving keys!: $value, $err");
      return [];
    }
  }

  static Future<bool> _setKeys(List<StoredEthereumKey> keys) async {
    print("setKeys: storing keys: ${jsonEncode(keys)}");
    if (keys == null) {
      return UserPreferences()
          .sharedPreferences()
          .remove(UserPreferenceKeyVPN.Keys.toString());
    }
    try {
      var value = jsonEncode(keys);
      return await UserPreferences()
          .putStringForKey(UserPreferenceKeyVPN.Keys, value);
    } catch (err) {
      log("Error storing keys!: $err");
      return false;
    }
  }

  /// Remove a key from the user's keystore.
  Future<bool> removeKey(StoredEthereumKeyRef keyRef) async {
    var keysList = ((keys.get()) ?? []);
    try {
      keysList.removeWhere((key) => key.uid == keyRef.keyUid);
    } catch (err) {
      log("account: error removing key: $keyRef");
      return false;
    }
    await keys.set(keysList);
    return true;
  }

  /// Add a key to the user's keystore if it does not already exist.
  Future<void> addKey(StoredEthereumKey key) async {
    return addKeyIfNeeded(key);
  }

  /// Add a key to the user's keystore if it does not already exist.
  Future<void> addKeyIfNeeded(StoredEthereumKey key) async {
    log("XXX: addKeyIfNeeded: add key if needed: $key");
    var curKeys = keys.get() ?? [];
    if (!curKeys.contains(key)) {
      log("XXX: addKeyIfNeeded: adding key");
      await keys.set(curKeys + [key]);
    } else {
      log("XXX: addKeyIfNeeded: duplicate key");
    }
  }

  /// Add a list of keys to the user's keystore.
  Future<void> addKeys(List<StoredEthereumKey> newKeys) async {
    var allKeys = ((keys.get()) ?? []) + newKeys;
    await keys.set(allKeys);
  }

  ///
  /// End: Keys
  ///

  String? getDefaultCurator() {
    return UserPreferences()
        .getStringForKey(UserPreferenceKeyVPN.DefaultCurator);
  }

  Future<bool> setDefaultCurator(String value) async {
    return UserPreferences()
        .putStringForKey(UserPreferenceKeyVPN.DefaultCurator, value);
  }

  bool getQueryBalances() {
    return UserPreferences()
            .sharedPreferences()
            .getBool(UserPreferenceKeyVPN.QueryBalances.toString()) ??
        true;
  }

  Future<bool> setQueryBalances(bool value) async {
    return UserPreferences()
        .sharedPreferences()
        .setBool(UserPreferenceKeyVPN.QueryBalances.toString(), value);
  }

  /// The PAC transaction or null if there is none.
  ObservablePreference<PacTransaction> pacTransaction = ObservablePreference(
      key: UserPreferenceKeyVPN.PacTransaction,
      getValue: (key) {
        String? value = UserPreferences().getStringForKey(key);
        try {
          return value != null
              ? PacTransaction.fromJson(jsonDecode(value))
              : null;
        } catch (err) {
          log("pacs: Unable to decode v1 transaction, returning null: $value, $err");
          return null;
        }
      },
      putValue: (key, tx) {
        String? value = tx != null ? jsonEncode(tx) : null;
        return UserPreferences().putStringForKey(key, value);
      });

  /// Add to the set of discovered accounts.
  Future<void> addCachedDiscoveredAccounts(List<Account> accounts) async {
    if (accounts.isEmpty) {
      return;
    }
    if (accounts.contains(null)) {
      throw Exception('null account in add to cache');
    }
    var cached = cachedDiscoveredAccounts.get();
    cached.addAll(accounts);
    await cachedDiscoveredAccounts.set(cached);
  }

  Future<void> addAccountsIfNeeded(List<Account> accounts) async {
    // Allow the set to prevent duplication.
    log("XXX: adding accounts: $accounts");
    return addCachedDiscoveredAccounts(accounts);
  }

  /// A set of accounts previously discovered for user identities
  /// Returns {} empty set initially.
  ObservablePreference<Set<Account>> cachedDiscoveredAccounts =
      ObservableAccountSetPreference(
          UserPreferenceKeyVPN.CachedDiscoveredAccounts);

  /// Add a potentially new identity (signer key) and account (funder, chain, version)
  /// without duplication.
  Future<void> ensureSaved(Account account) async {
    await UserPreferencesVPN().addKeyIfNeeded(account.signerKey);
    await UserPreferencesVPN()
        .addCachedDiscoveredAccounts([account]); // setwise, safe
  }

  /// An incrementing internal UI app release notes version used to track
  /// new release messaging.  See class [Release]
  ObservablePreference<ReleaseVersion> releaseVersion = ObservablePreference(
      key: UserPreferenceKeyVPN.ReleaseVersion,
      getValue: (key) {
        return ReleaseVersion(
            (UserPreferences().sharedPreferences()).getInt(key.toString()));
      },
      putValue: (key, value) async {
        var sharedPreferences = UserPreferences().sharedPreferences();
        if (value.version == null) {
          return sharedPreferences.remove(key.toString());
        }
        return sharedPreferences.setInt(key.toString(), value.version);
      });

  /// User preference indicating that the VPN should be enabled to route traffic
  /// per the user's hop configuration.
  /// Note that the actual state of the VPN subsystem is controlled by the OrchidAPI
  /// and may also take into account the monitoring preference.
  ObservableBoolPreference routingEnabled = ObservableBoolPreference(
      UserPreferenceKeyVPN.RoutingEnabled,
      defaultValue: false);

  /// User preference indicating that the Orchid VPN should be enabled to monitor traffic.
  /// Note that the actual state of the VPN subsystem is controlled by the OrchidAPI
  /// and may also take into account the vpn enabled preference.
  ObservableBoolPreference monitoringEnabled = ObservableBoolPreference(
      UserPreferenceKeyVPN.MonitoringEnabled,
      defaultValue: false);

  /// User Chain config overrides
  // Note: Now that we have fully user-configurable chains we should probably
  // Note: fold this into that structure.
  ObservableChainConfigPreference chainConfig =
      ObservableChainConfigPreference(UserPreferenceKeyVPN.ChainConfig);

  /// User Chain config overrides
  // Note: Now that we have fully user-configurable chains we should probably
  // Note: fold this into that structure.
  ChainConfig? chainConfigFor(int chainId) {
    return ChainConfig.map(chainConfig.get())[chainId];
  }

  /// Fully user configured chains.
  ObservableUserConfiguredChainPreference userConfiguredChains =
      ObservableUserConfiguredChainPreference(
          UserPreferenceKeyVPN.UserConfiguredChains);
}

enum UserPreferenceKeyVPN implements UserPreferenceKey {
  Circuit,
  Keys,
  DefaultCurator,
  QueryBalances,
  PacTransaction,
  CachedDiscoveredAccounts,
  ReleaseVersion,
  RoutingEnabled,
  MonitoringEnabled,
  ChainConfig,
  UserConfiguredChains,
}
