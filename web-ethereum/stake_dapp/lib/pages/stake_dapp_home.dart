import 'package:orchid/api/orchid_eth/token_type.dart';
import 'package:orchid/api/orchid_eth/tokens.dart';
import 'package:orchid/dapp/orchid/dapp_transaction_list.dart';
import 'package:orchid/common/rounded_rect.dart';
import 'package:orchid/gui-orchid/lib/orchid/orchid_panel.dart';
import 'package:orchid/orchid/field/orchid_labeled_token_value_field.dart';
import 'package:orchid/orchid/orchid.dart';
import 'package:orchid/api/orchid_user_config/orchid_user_param.dart';
import 'package:orchid/api/orchid_crypto.dart';
import 'package:orchid/api/orchid_platform.dart';
import 'package:orchid/dapp/orchid_web3/orchid_web3_context.dart';
import 'package:orchid/common/app_dialogs.dart';
import 'package:orchid/orchid/field/orchid_labeled_address_field.dart';
import 'package:orchid/stake_dapp/orchid_web3_stake_v0.dart';
import 'dapp_home_base.dart';
import 'dapp_home_header.dart';

class StakeDappHome extends StatefulWidget {
  const StakeDappHome({Key? key}) : super(key: key);

  @override
  State<StakeDappHome> createState() => _StakeDappHomeState();
}

class _StakeDappHomeState extends DappHomeStateBase<StakeDappHome> {
  // This must be wide enough to accommodate the tab names.
  final mainColumnWidth = 800.0;
  final altColumnWidth = 500.0;

  EthereumAddress? _stakee;
  final _stakeeField = AddressValueFieldController();

  bool get _hasAccount => _stakee != null && web3Context?.walletAddress != null;

  final _scrollController = ScrollController();

  final _stakedAmountController =
      TypedTokenValueFieldController(type: Tokens.OXT);

  @override
  void initState() {
    super.initState();
    _stakeeField.addListener(_stakeeFieldChanged);
    initStateAsync();
  }

  void initStateAsync() async {
    await _supportTestAccountConnect();
    await checkForExistingConnectedAccounts();
  }

  Future<void> _supportTestAccountConnect() async {
    // (TESTING)
    if (OrchidUserParams().test) {
      await Future.delayed(Duration(seconds: 0), () {
        connectEthereum();
        _stakee =
            EthereumAddress.from('0x5eea55E63a62138f51D028615e8fd6bb26b8D354');
        _stakeeField.textController.text = _stakee.toString();
      });
    }
  }

  void _stakeeFieldChanged() {
    // signer field changed?
    var oldSigner = _stakee;
    _stakee = _stakeeField.value;
    if (_stakee != oldSigner) {
      _selectedStakeeChanged();
    }

    // Update UI
    setState(() {});
  }

  // Start polling the correct account
  void _selectedStakeeChanged() async {
    // XXX
    if (_stakee != null && web3Context != null) {
      _stakedAmountController.value =
          await OrchidWeb3StakeV0(web3Context!).orchidGetStake(_stakee!);
      log("XXX: heft = $_stakedAmountController");
    } else {
      _stakedAmountController.value = null;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DappHomeHeader(
          web3Context: web3Context,
          setNewContext: setNewContext,
          contractVersionsAvailable: contractVersionsAvailable,
          contractVersionSelected: contractVersionSelected,
          selectContractVersion: selectContractVersion,
          deployContract: deployContract,
          connectEthereum: connectEthereum,
          disconnect: disconnect,
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
                    if (contractVersionsAvailable != null &&
                        contractVersionsAvailable!.isEmpty)
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

                    // stakee field
                    ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: altColumnWidth),
                        child: OrchidLabeledAddressField(
                          label: "Stakee Address", // localize
                          controller: _stakeeField,
                          contentPadding: EdgeInsets.only(
                              top: 8, bottom: 18, left: 16, right: 16),
                        ).top(24).padx(8)),

                    // Current staked amount
                    AnimatedVisibility(
                      show: _stakee != null &&
                          _stakedAmountController.value != null,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: altColumnWidth),
                        child: OrchidLabeledTokenValueField(
                          // localize
                          label: "Staked amount",
                          type: Tokens.OXT,
                          readOnly: true,
                          enabled: false,
                          controller: _stakedAmountController,
                        ).width(double.infinity).pady(24).padx(8),

                      ),
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

  // Refresh the wallet and account balances
  void _refreshUserData() {
    web3Context?.refresh();
  }

  // Init a new context, disconnecting any old context and registering listeners
  @override
  void setNewContext(OrchidWeb3Context? web3Context) async {
    super.setNewContext(web3Context);

    try {
      _selectedStakeeChanged();
    } catch (err) {
      log('set new context: error in selected account changed: $err');
    }
  }

  @override
  void onContractVersionChanged(int version) async {
    super.onContractVersionChanged(version);
    // todo: does this need to be done first?
    try {
      _selectedStakeeChanged();
    } catch (err) {
      log('on contract version changed: error in selected account changed: $err');
    }
  }

  @override
  Future<void> disconnect() async {
    // setState(() {
    //   _clearAccountDetail();
    // });
    super.disconnect();
  }

  @override
  void dispose() {
    _stakeeField.removeListener(_stakeeFieldChanged);
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
