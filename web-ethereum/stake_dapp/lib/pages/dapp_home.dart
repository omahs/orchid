import 'package:orchid/api/orchid_eth/orchid_account_detail.dart';
import 'package:orchid/dapp/orchid/dapp_transaction_list.dart';
import 'package:orchid/dapp/orchid_web3/v1/orchid_contract_deployment_v1.dart';
import 'package:orchid/common/rounded_rect.dart';
import 'package:orchid/orchid/orchid.dart';
import 'package:flutter_web3/flutter_web3.dart';
import 'package:orchid/api/orchid_user_config/orchid_user_param.dart';
import 'package:orchid/api/orchid_crypto.dart';
import 'package:orchid/api/orchid_eth/orchid_account.dart';
import 'package:orchid/api/orchid_eth/v1/orchid_eth_v1.dart';
import 'package:orchid/api/orchid_platform.dart';
import 'package:orchid/dapp/orchid_web3/orchid_web3_context.dart';
import 'package:orchid/common/app_dialogs.dart';
import 'package:orchid/orchid/account/account_card.dart';
import 'package:orchid/orchid/field/orchid_labeled_address_field.dart';
import 'package:orchid/dapp/orchid_web3/v1/orchid_eth_v1_web3.dart';
import 'dapp_home_header.dart';

class DappHome extends StatefulWidget {
  const DappHome({Key? key}) : super(key: key);

  @override
  State<DappHome> createState() => _DappHomeState();
}

class _DappHomeState extends State<DappHome> {
  OrchidWeb3Context? _web3Context;
  EthereumAddress? _signer;

  // TODO: Encapsulate this in a provider builder widget (ala TokenPriceBuilder)
  // TODO: Before that we need to add a controller to our PollingBuilder to allow
  // TODO: for refresh on demand.
  AccountDetailPoller? _accountDetail;

  final _signerField = AddressValueFieldController();
  final _scrollController = ScrollController();

  /// The contract version defaulted or selected by the user.
  /// Null if no contacts are available.
  int? _contractVersionSelectedValue;

  int? get _contractVersionSelected {
    return _contractVersionSelectedValue;
  }

  void _selectContractVersion(int? version) {
    // if (version == _contractVersionSelected) { return; }
    log('XXX: version = $version');
    _contractVersionSelectedValue = version;
    if (version != null) {
      _onContractVersionChanged(version);
    }
  }

  Set<int>? get _contractVersionsAvailable {
    return _web3Context?.contractVersionsAvailable;
  }

  bool get _hasAccount =>
      _signer != null && _web3Context?.walletAddress != null;

  @override
  void initState() {
    super.initState();
    _signerField.addListener(_signerFieldChanged);
    initStateAsync();
  }

  void initStateAsync() async {
    await _supportTestAccountConnect();
    await _checkForExistingConnectedAccounts();
  }

  Future<void> _supportTestAccountConnect() async {
    // (TESTING)
    if (OrchidUserParams().test) {
      await Future.delayed(Duration(seconds: 0), () {
        _connectEthereum();
        _signer =
            EthereumAddress.from('0x5eea55E63a62138f51D028615e8fd6bb26b8D354');
        _signerField.textController.text = _signer.toString();
      });
    }
  }

  /// If the user has previously connected accounts reconnect without requiring
  /// the user to hit the connect button.
  Future<void> _checkForExistingConnectedAccounts() async {
    try {
      var accounts = await ethereum?.getAccounts() ?? [];
      if (accounts.isNotEmpty) {
        log('connect: User already has accounts, connecting.');
        await Future.delayed(Duration(seconds: 0), () {
          _connectEthereum();
        });
      } else {
        log('connect: No connected accounts, require the user to initiate.');
      }
    } catch (err) {
      log('connect: Error checking getAccounts: $err');
    }
  }

  void _signerFieldChanged() {
    // signer field changed?
    var oldSigner = _signer;
    _signer = _signerField.value;
    if (_signer != oldSigner) {
      _selectedAccountChanged();
    }

    // Update UI
    setState(() {});
  }

  void _accountDetailUpdated() {
    setState(() {});
  }

  // TODO: replace this account detail management with a provider builder
  void _clearAccountDetail() {
    _accountDetail?.cancel();
    _accountDetail?.removeListener(_accountDetailUpdated);
    _accountDetail = null;
  }

  // TODO: replace this account detail management with a provider builder
  // Start polling the correct account
  void _selectedAccountChanged() async {
    // log("XXX: selectedAccountChanged");
    _clearAccountDetail();
    if (_hasAccount) {
      // Avoid starting the poller in the rare case where there are no contracts
      if (_contractVersionSelected != null) {
        var account = Account.fromSignerAddress(
          signerAddress: _signer!,
          version: _contractVersionSelected!,
          funder: _web3Context!.walletAddress!,
          chainId: _web3Context!.chain.chainId,
        );
        _accountDetail = AccountDetailPoller(
          account: account,
          pollingPeriod: Duration(seconds: 10),
        );
        _accountDetail!.addListener(_accountDetailUpdated);
        _accountDetail!.startPolling();
      }
    }
    setState(() {});
  }

  // This must be wide enough to accommodate the tab names.
  final mainColumnWidth = 800.0;
  final altColumnWidth = 500.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DappHomeHeader(
          web3Context: _web3Context,
          setNewContext: _setNewContext,
          contractVersionsAvailable: _contractVersionsAvailable,
          contractVersionSelected: _contractVersionSelected,
          selectContractVersion: _selectContractVersion,
          deployContract: _deployContract,
          connectEthereum: _connectEthereum,
          disconnect: _disconnect,
        ).padx(24).top(30).bottom(24),
        _buildMainColumn(),
      ],
    );
  }

  // main info column
  Expanded _buildMainColumn() {
    return Expanded(
      child: Theme(
        data: Theme.of(context).copyWith(
          highlightColor: OrchidColors.tappable,
          scrollbarTheme: ScrollbarThemeData(
            thumbColor:
                MaterialStateProperty.all(Colors.white.withOpacity(0.4)),
            // isAlwaysShown: true,
            trackVisibility: MaterialStateProperty.all(true),
          ),
        ),
        child: Scrollbar(
          controller: _scrollController,
          child: SingleChildScrollView(
            physics: OrchidPlatform.isWeb ? ClampingScrollPhysics() : null,
            controller: _scrollController,
            child: Center(
              child: SizedBox(
                width: mainColumnWidth,
                child: Column(
                  children: [
                    if (_contractVersionsAvailable != null &&
                        _contractVersionsAvailable!.isEmpty)
                      RoundedRect(
                        backgroundColor: OrchidColors.dark_background,
                        child: Text(s
                                .theOrchidContractHasntBeenDeployedOnThisChainYet)
                            .subtitle
                            .height(1.7)
                            .withColor(OrchidColors.status_yellow)
                            .pad(24),
                      ).center.bottom(24),

                    DappTransactionList(
                      refreshUserData: _refreshUserData,
                      width: mainColumnWidth,
                    ).top(24),

                    // signer field
                    ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: altColumnWidth),
                        child: OrchidLabeledAddressField(
                          label: s.orchidIdentity,
                          controller: _signerField,
                          contentPadding: EdgeInsets.only(
                              top: 8, bottom: 18, left: 16, right: 16),
                        ).top(24).padx(8)),

                    // account card
                    AnimatedVisibility(
                      show: _hasAccount,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                            minWidth: altColumnWidth, maxWidth: altColumnWidth),
                        child: AccountCard(
                          // todo: the key here just allows us to expanded when details are available
                          // todo: maybe make that the default behavior of the card
                          key: Key(_accountDetail?.funder.toString() ?? 'null'),
                          minHeight: true,
                          showAddresses: false,
                          showContractVersion: false,
                          accountDetail: _accountDetail,
                          // initiallyExpanded: _accountDetail != null,
                          initiallyExpanded: false,
                          // partial values from the connection panel
                          partialAccountFunderAddress:
                              _web3Context?.walletAddress,
                          partialAccountSignerAddress: _signer,
                        ).top(24).padx(8),
                      ),
                    ),

                    // tabs
                    // Divider(color: Colors.white.withOpacity(0.3)).bottom(8),
                    AnimatedVisibility(
                      // show: _hasAccount,
                      show: true,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: altColumnWidth),
                        child: Container(),
                      ).padx(8).top(16),
                    ),

                    // _buildFooter().padx(24).bottom(24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _deployContract() async {
    final deploy = OrchidContractDeployment(_web3Context!);
    if (await deploy.deployIfNeeded()) {
      _onAccountOrChainChange();
    }
  }

  Future<void> _connectEthereum() async {
    log("XXX: connectEthereum");
    try {
      await _tryConnectEthereum();
    } on EthereumException catch (err) {
      // Infer the "request already pending" exception from the exception text.
      if (err.message.contains('already pending for origin')) {
        log("XXX: inferring request pending from exception message: err=$err");
        DappHomeUtil.showRequestPendingMessage(context);
      } else {
        log("Unknown EthereumException in connect: $err");
      }
    } catch (err) {
      log("Unknown err in connect ethereum: $err");
    }
  }

  Future<void> _tryConnectEthereum() async {
    if (!Ethereum.isSupported) {
      AppDialogs.showAppDialog(
          context: context,
          title: s.noWallet,
          bodyText: s.noWalletOrBrowserNotSupported);
      return;
    }

    if (ethereum == null) {
      log("no ethereum provider");
      return;
    }
    var web3 = await OrchidWeb3Context.fromEthereum(ethereum!);
    _setNewContext(web3);
  }

  // Init a new context, disconnecting any old context and registering listeners
  void _setNewContext(OrchidWeb3Context? web3Context) async {
    log('set new context: $web3Context');

    // Clear the old context, removing listeners and disposing of it properly.
    _web3Context?.disconnect();

    // Register listeners on the new context
    web3Context?.onAccountsChanged((accounts) {
      log('web3: accounts changed: $accounts');
      if (accounts.isEmpty) {
        _setNewContext(null);
      } else {
        _onAccountOrChainChange();
      }
    });
    web3Context?.onChainChanged((chainId) {
      log('web3: chain changed: $chainId');
      _onAccountOrChainChange();
    });
    // _context?.onConnect(() { log('web3: connected'); });
    // _context?.onDisconnect(() { log('web3: disconnected'); });
    web3Context?.onWalletUpdate(() {
      // Update the UI
      setState(() {});
    });

    // Install the new context here and as the UI provider
    _web3Context = web3Context;
    try {
      _setAppWeb3Provider(web3Context);
    } catch (err, stack) {
      log('set new context: error setting app web3 provider: $err,\n$stack');
    }

    // The context was replaced or updated. Check various attributes.
    // check the contract
    // if (_web3Context != null) {
    //   if (_contractVersionsAvailable == null ||
    //       _contractVersionsAvailable.isEmpty) {
    //     await _noContract();
    //   }
    // }

    try {
      _web3Context?.refresh();
    } catch (err) {
      log('set new context: error in refreshing context: $err');
    }

    // Default the contract version
    if (_contractVersionsAvailable != null) {
      final selectedVersion =
          _web3Context!.contractVersionsAvailable!.contains(1)
              ? 1
              : _web3Context!.contractVersionsAvailable!.contains(0)
                  ? 0
                  : null;
      _selectContractVersion(selectedVersion);
    } else {
      _selectContractVersion(null);
    }
    // XXX
    // if (OrchidUserParams().test) {
    //   _contractVersionSelected = 0;
    // }

    try {
      _selectedAccountChanged();
    } catch (err) {
      log('set new context: error in selected account changed: $err');
    }
    setState(() {});
  }

  // For contracts that may exist on chains other than main net we ensure that
  // all requests go through the web3 context.
  void _setAppWeb3Provider(OrchidWeb3Context? web3Context) {
    // log("XXX: setAppWeb3Provider: $web3Context");
    if (web3Context != null &&
        _contractVersionSelected != null &&
        _contractVersionSelected! > 0) {
      OrchidEthereumV1.setWeb3Provider(OrchidEthereumV1Web3Impl(web3Context));
    } else {
      OrchidEthereumV1.setWeb3Provider(null);
    }
  }

  /// Update on change of address or chain by rebuilding the web3 context.
  void _onAccountOrChainChange() async {
    if (_web3Context == null) {
      return;
    }

    // Check chain before constructing web3
    // var chainId = await ethereum.getChainId();
    // if (!Chains.isKnown(chainId)) {
    //   return _invalidChain();
    // }

    // Recreate the context wrapper
    var context = null;
    try {
      if (_web3Context?.ethereumProvider != null) {
        context = await OrchidWeb3Context.fromEthereum(
            _web3Context!.ethereumProvider!);
      } else {
        context = await OrchidWeb3Context.fromWalletConnect(
            _web3Context!.walletConnectProvider!);
      }
    } catch (err) {
      log('Error constructing web context:');
    }
    _setNewContext(context);
  }

  void _onContractVersionChanged(int version) async {
    _selectedAccountChanged();
    _setAppWeb3Provider(_web3Context);
    // Update the UI
    setState(() {});
  }

  // Refresh the wallet and account balances
  void _refreshUserData() {
    _web3Context?.refresh();
    // TODO: Encapsulate this in a provider builder widget (ala TokenPriceBuilder)
    // TODO: Before that we need to add a controller to our PollingBuilder to allow
    // TODO: for refresh on demand.
    _accountDetail?.refresh();
  }

  Future<void> _disconnect() async {
    _web3Context?.disconnect();
    setState(() {
      _clearAccountDetail();
      _web3Context = null;
      _contractVersionSelectedValue = null;
    });
  }

  @override
  void dispose() {
    _signerField.removeListener(_signerFieldChanged);
    super.dispose();
  }
}

class DappHomeUtil {
  static void showRequestPendingMessage(BuildContext context) {
    AppDialogs.showAppDialog(
      context: context,
      title: context.s.checkWallet,
      bodyText: context.s.checkYourWalletAppOrExtensionFor,
    );
  }
}
