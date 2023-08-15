import 'package:flutter_web3/flutter_web3.dart';
import 'package:orchid/api/orchid_crypto.dart';
import 'package:orchid/api/orchid_eth/token_type.dart';
import 'package:orchid/api/orchid_eth/tokens.dart';
import 'package:orchid/api/orchid_eth/v0/orchid_contract_v0.dart';
import 'package:orchid/api/orchid_log.dart';
import 'package:orchid/dapp/orchid_web3/orchid_erc20.dart';
import 'package:orchid/dapp/orchid_web3/orchid_web3_context.dart';

class OrchidWeb3StakeV0 {
  final OrchidWeb3Context context;
  final Contract _directoryContract;
  final OrchidERC20 _oxt;

  OrchidWeb3StakeV0(this.context)
      : this._directoryContract = Contract(
            OrchidContractV0.directoryContractAddressString,
            OrchidContractV0.directoryAbi,
            context.web3),
        this._oxt = OrchidERC20(context: context, tokenType: Tokens.OXT);

  /// Transfer the int amount from the user to the specified directory address.
  /// Amount won't exceed walletBalance.
  Future<List<String> /*TransactionId*/ > orchidStakeFunds({
    required EthereumAddress funder,
    required EthereumAddress stakee,
    required Token amount,
    required OrchidWallet wallet,
    required BigInt delay,
  }) async {
    amount.assertType(Tokens.OXT);
    log("Stake funds amount: $amount, stakee: $stakee, delay: $delay");
    var walletBalance = await _oxt.getERC20Balance(wallet.address!);
    amount = Token.min(amount, walletBalance);

    List<String> txHashes = [];

    // Check allowance and skip approval if sufficient.
    // function allowance(address owner, address spender) external view returns (uint256)
    Token oxtAllowance = await _oxt.getERC20Allowance(
      owner: wallet.address!,
      spender: OrchidContractV0.lotteryContractAddressV0,
    );
    if (oxtAllowance < amount) {
      log("oxtAllowance increase required: $oxtAllowance < $amount");
      var approveTxHash = await _oxt.approveERC20(
        owner: wallet.address!,
        spender: OrchidContractV0.directoryContractAddress,
        amount: amount, // Amount is the new total approval amount
      );
      txHashes.add(approveTxHash);
      // arbitrary delay
      await Future.delayed(Duration(milliseconds: 1000));
    } else {
      log("oxtAllowance sufficient: $oxtAllowance");
    }

    // Do the stake call
    var contract = _directoryContract.connect(context.web3.getSigner());
    TransactionResponse tx = await contract.send(
      'push',
      [
        stakee.toString(),
        amount.intValue.toString(),
        delay.toString(),
      ],
      TransactionOverride(
          gasLimit: BigInt.from(OrchidContractV0.gasLimitDirectoryPush)),
    );
    txHashes.add(tx.hash);
    return txHashes;
  }

  Future<Token> orchidGetStake(EthereumAddress stakee) async {
    log("Get stake for: $stakee");
    var result = await _directoryContract.call('heft', [
      stakee.toString(), // 0x ?
    ]);
    log("XXX: heft = $result");
    try {
      return Tokens.OXT.fromIntString(result.toString());
    } catch (err) {
      log("Error parsing heft result: $err");
      return Tokens.OXT.zero;
    }
  }
}
