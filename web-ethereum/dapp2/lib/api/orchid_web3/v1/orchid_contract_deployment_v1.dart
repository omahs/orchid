import 'package:orchid/api/preferences/dapp_transaction.dart';
import 'package:orchid/api/preferences/user_preferences.dart';
import 'package:orchid/api/preferences/user_preferences_dapp.dart';
import 'package:orchid/orchid/orchid.dart';
import 'package:orchid/api/orchid_eth/v1/orchid_contract_v1.dart';
import 'package:orchid/api/orchid_web3/orchid_web3_context.dart';
import 'package:flutter_web3/src/ethers/ethers.dart';

class OrchidContractDeployment {
  static final v1_addr = OrchidContractV1.lotteryContractAddressV1;

  // We use Nick's method to first deploy out singleton factory contract
  static final factory_addr = '0x83aa38958768b9615b138339cbd8601fc2963d4d';

  // from the derived single-use funder address
  static final factory_deployer_addr =
      '0x6DeE848048413E4305b2d1197e782f9B1Da2d9D8';

  // using this transaction to deploy the factory
  static final factory_deploy_tx_data =
      '0xf87e8085746a528800830186a08080ad601f80600e600039806000f350fe60003681823780368234f58015156014578182fd5b80825250506014600cf31ba02222222222222222222222222222222222222222222222222222222222222222a02222222222222222222222222222222222222222222222222222222222222222';

  // Then we use the factory to deploy the v1 contract
  static final v1_deploy_tx_input =
      '0x60a060405234801561001057600080fd5b50604051611a14380380611a1483398101604081905261002f91610044565b60c01b6001600160c01b031916608052610072565b600060208284031215610055578081fd5b81516001600160401b038116811461006b578182fd5b9392505050565b60805160c01c61197b6100996000398061071152806107815280611020525061197b6000f3fe6080604052600436106100b15760003560e01c80635fe65fef11610069578063a4c0ed361161004e578063a4c0ed36146101a2578063c0ee0b8a146101cf578063c6a69689146101ef576100b1565b80635fe65fef1461016257806384992d5114610182576100b1565b8063248d0fd71161009a578063248d0fd7146100f85780635185c7d71461011857806359c8b7f01461014f576100b1565b806313171586146100b65780631cea28c0146100d8575b600080fd5b3480156100c257600080fd5b506100d66100d1366004611577565b61021c565b005b3480156100e457600080fd5b506100d66100f33660046116dd565b6103ef565b34801561010457600080fd5b506100d6610113366004611682565b6104b1565b34801561012457600080fd5b5061013861013336600461152d565b610607565b604051610146929190611905565b60405180910390f35b6100d661015d366004611425565b610661565b34801561016e57600080fd5b506100d661017d3660046114da565b6106f5565b34801561018e57600080fd5b506100d661019d366004611637565b61089f565b3480156101ae57600080fd5b506101c26101bd36600461143a565b61099e565b60405161014691906118dc565b3480156101db57600080fd5b506100d66101ea36600461143a565b6109b7565b3480156101fb57600080fd5b5061020f61020a3660046113ed565b610a5d565b6040516101469190611798565b805b8015610266577fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0161026183838381811061025557fe5b90506020020135610ac5565b61021e565b506040516000845b80156102bf577fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff016102b289898989858181106102a757fe5b905060c00201610b08565b820191508260405261026e565b5080156103e55760008888896040516020016102dd93929190611840565b604080517fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe081840301815291815281516020928301206000818152928390529120805491925090806103715760405173ffffffffffffffffffffffffffffffffffffffff808c169182918e16907fb224da6575b2c2ffd42454faedb236f7dbe5f92a0c96bb99c0273dbe98464c7e90600090a45b70010000000000000000000000000000000084826fffffffffffffffffffffffffffffffff1601106103a257600080fd5b830180825560405183907f05241a2ddcbea46fa2f8b84beea5d0d8c0fd21414503d644982a75ccf1d986aa906103d9908490611798565b60405180910390a25050505b5050505050505050565b80336040516020016104029291906117a1565b60405160208183030381529060405280519060200120600060405160200161042b9291906117a1565b6040516020818303038152906040528051906020012090505b7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff820191156104ad57600081815260026020908152604091829020339055905161049091839101611798565b604051602081830303815290604052805190602001209050610444565b5050565b73ffffffffffffffffffffffffffffffffffffffff86166104d157600080fd5b6000808773ffffffffffffffffffffffffffffffffffffffff1633308960405160240161050093929190611885565b604080517fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe08184030181529181526020820180517bffffffffffffffffffffffffffffffffffffffffffffffffffffffff167f23b872dd00000000000000000000000000000000000000000000000000000000179052516105819190611807565b6000604051808303816000865af19150503d80600081146105be576040519150601f19603f3d011682016040523d82523d6000602084013e6105c3565b606091505b50915091508180156105e45750808060200190518101906105e491906114be565b6105ed57600080fd5b6105fc33898989898989610eb6565b6103e5338985611225565b600080600080600087878760405160200161062493929190611840565b6040516020818303038152906040528051906020012081526020019081526020016000209050806000015481600101549250925050935093915050565b6106713360003487878787610eb6565b80156106ef5760003373ffffffffffffffffffffffffffffffffffffffff168260405161069d90611882565b60006040518083038185875af1925050503d80600081146106da576040519150601f19603f3d011682016040523d82523d6000602084013e6106df565b606091505b50509050806106ed57600080fd5b505b50505050565b33600090815260016020526040902081806107785784610741577f000000000000000000000000000000000000000000000000000000000000000067ffffffffffffffff164201610744565b60005b825560405160009033907ffcf9bcb7a2649802047845bf82b0575e170753e2fb50c2e1552bcebc3c38ca9f908390a36106ed565b6000856107b1577f000000000000000000000000000000000000000000000000000000000000000067ffffffffffffffff1642016107d3565b7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff5b90505b7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff90910190600085858481811061080957fe5b905060200201602081019061081e9190611397565b905073ffffffffffffffffffffffffffffffffffffffff811661084057600080fd5b73ffffffffffffffffffffffffffffffffffffffff811660008181526001860160205260408082208590555133917ffcf9bcb7a2649802047845bf82b0575e170753e2fb50c2e1552bcebc3c38ca9f91a350816107d657505050505050565b428167ffffffffffffffff1611156108b657600080fd5b60008333846040516020016108cd93929190611840565b604080518083037fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0018152828252805160209182012060008181529182905291902060018101805477ffffffffffffffffffffffffffffffffffffffffffffffff1660c087901b7fffffffffffffffff0000000000000000000000000000000000000000000000001617908190559193509183907fe9d5d4bdc29068f77666497419c28b4aa58fe071a9dc2e1c5fde003d86701a6d9061098e908490611798565b60405180910390a2505050505050565b60006109ac858585856109b7565b506001949350505050565b60048110156109c557600080fd5b81357fffffffff0000000000000000000000000000000000000000000000000000000081167f59c8b7f00000000000000000000000000000000000000000000000000000000014156100b1576000808080610a23866004818a611913565b810190610a3091906113b3565b92965090945092509050610a4989338a87878787610eb6565b610a54893383611225565b505050506106ed565b73ffffffffffffffffffffffffffffffffffffffff808316600090815260016020526040812090918316610a9357549050610abf565b73ffffffffffffffffffffffffffffffffffffffff831660009081526001909101602052604090205490505b92915050565b600081815260026020526040902080544260a082901c11610b035773ffffffffffffffffffffffffffffffffffffffff8116331415610b0357600082555b505050565b6000604082013560c01c606083013560e11c01428111610b2c576000915050610eaf565b826020013560808460400135901c604051602001610b4b9291906117d4565b6040516020818303038152906040528051906020012060001c67ffffffffffffffff1660a18460600135901c67ffffffffffffffff161015610b91576000915050610eaf565b6000469050601960f81b600060f81b308389898960200135604051602001610bb99190611798565b604080517fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe08184030181528282528051602091820120610c119998979695949390928e01359160608f013560011c918f3591016116fe565b60405160208183030381529060405280519060200120905060006001828660600135600116601b0187608001358860a0013560405160008152602001604052604051610c6094939291906118e7565b6020604051602081039080840390855afa158015610c82573d6000803e3d6000fd5b50506040517fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe08101519250606087013560011c9150600090610ccc908a9084908690602001611840565b604080517fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe08184030181529181528151602092830120600081815280845282812073ffffffffffffffffffffffffffffffffffffffff87168252600190945291909120805491935090427fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff9091011015610dc05760c08260010154901c8160010160008c73ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020016000205411610dc0576000975050505050505050610eaf565b506000600260008787604051602001610dda9291906117a1565b60405160208183030381529060405280519060200120815260200190815260200160002090508060000154600014610e1c576000975050505050505050610eaf565b60a087901b3317905580546fffffffffffffffffffffffffffffffff60408a01358116919081168211610e5157819003610e68565b6fffffffffffffffffffffffffffffffff16905060005b80835560405184907f05241a2ddcbea46fa2f8b84beea5d0d8c0fd21414503d644982a75ccf1d986aa90610e9d908490611798565b60405180910390a25096505050505050505b9392505050565b6000868886604051602001610ecd93929190611840565b604080517fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe08184030181529181528151602092830120600081815292839052908220909250908086151580610f225750848914155b15610fc1578254915081610fa2578773ffffffffffffffffffffffffffffffffffffffff168b73ffffffffffffffffffffffffffffffffffffffff168b73ffffffffffffffffffffffffffffffffffffffff167fb224da6575b2c2ffd42454faedb236f7dbe5f92a0c96bb99c0273dbe98464c7e60405160405180910390a45b608082901c9050816fffffffffffffffffffffffffffffffff16890198505b6000806000808a1280610fd357508815155b1561100857505050600183015460c081901c906fffffffffffffffffffffffffffffffff81169060801c67ffffffffffffffff165b600089131561104e575087014267ffffffffffffffff7f000000000000000000000000000000000000000000000000000000000000000016018882101561104e57600080fd5b60008a12156110a45742600182031061106657600080fd5b60008a9003808b141561107857600080fd5b8481111561108557600080fd5b9b8c019b93849003938281111561109b57600080fd5b909103906110c3565b89156110c357898c8111156110b857600080fd5b9b8c90039b93909301925b60008912156110f0576000899003808a14156110de57600080fd5b828111156110eb57600080fd5b909103905b8715611109578b88111561110357600080fd5b878c039b505b801561118e57700100000000000000000000000000000000821061112c57600080fd5b600082156111405782608083901b17611143565b60005b60c085901b179050808760010181905550877fe9d5d4bdc29068f77666497419c28b4aa58fe071a9dc2e1c5fde003d86701a6d826040516111849190611798565b60405180910390a2505b50505070010000000000000000000000000000000089106111ae57600080fd5b70010000000000000000000000000000000081106111cb57600080fd5b608081901b89178281146112175780845560405185907f05241a2ddcbea46fa2f8b84beea5d0d8c0fd21414503d644982a75ccf1d986aa9061120e908490611798565b60405180910390a25b505050505050505050505050565b8015610b03576000808373ffffffffffffffffffffffffffffffffffffffff1685846040516024016112589291906118b6565b604080517fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe08184030181529181526020820180517bffffffffffffffffffffffffffffffffffffffffffffffffffffffff167fa9059cbb00000000000000000000000000000000000000000000000000000000179052516112d99190611807565b6000604051808303816000865af19150503d8060008114611316576040519150601f19603f3d011682016040523d82523d6000602084013e61131b565b606091505b509150915081801561134557508051158061134557508080602001905181019061134591906114be565b6106ed57600080fd5b60008083601f84011261135f578182fd5b50813567ffffffffffffffff811115611376578182fd5b602083019150836020808302850101111561139057600080fd5b9250929050565b6000602082840312156113a8578081fd5b8135610eaf8161193b565b600080600080608085870312156113c8578283fd5b84356113d38161193b565b966020860135965060408601359560600135945092505050565b600080604083850312156113ff578182fd5b823561140a8161193b565b9150602083013561141a8161193b565b809150509250929050565b600080600080608085870312156113c8578384fd5b6000806000806060858703121561144f578384fd5b843561145a8161193b565b935060208501359250604085013567ffffffffffffffff8082111561147d578384fd5b818701915087601f830112611490578384fd5b81358181111561149e578485fd5b8860208285010111156114af578485fd5b95989497505060200194505050565b6000602082840312156114cf578081fd5b8151610eaf81611960565b6000806000604084860312156114ee578283fd5b83356114f981611960565b9250602084013567ffffffffffffffff811115611514578283fd5b6115208682870161134e565b9497909650939450505050565b600080600060608486031215611541578283fd5b833561154c8161193b565b9250602084013561155c8161193b565b9150604084013561156c8161193b565b809150509250925092565b6000806000806000806080878903121561158f578182fd5b863561159a8161193b565b955060208701356115aa8161193b565b9450604087013567ffffffffffffffff808211156115c6578384fd5b818901915089601f8301126115d9578384fd5b8135818111156115e7578485fd5b8a602060c0830285010111156115fb578485fd5b602083019650809550506060890135915080821115611618578384fd5b5061162589828a0161134e565b979a9699509497509295939492505050565b60008060006060848603121561164b578081fd5b83356116568161193b565b925060208401356116668161193b565b9150604084013567ffffffffffffffff8116811461156c578182fd5b60008060008060008060c0878903121561169a578384fd5b86356116a58161193b565b95506020870135945060408701356116bc8161193b565b959894975094956060810135955060808101359460a0909101359350915050565b600080604083850312156116ef578182fd5b50508035926020909101359150565b7fff000000000000000000000000000000000000000000000000000000000000009a8b1681529890991660018901527fffffffffffffffffffffffffffffffffffffffff000000000000000000000000606097881b811660028a0152601689019690965293861b851660368801529190941b909216604a850152605e840192909252607e830152609e82015260be81019190915260de0190565b90815260200190565b91825260601b7fffffffffffffffffffffffffffffffffffffffff00000000000000000000000016602082015260340190565b91825260801b7fffffffffffffffffffffffffffffffff0000000000000000000000000000000016602082015260300190565b60008251815b81811015611827576020818601810151858301520161180d565b818111156118355782828501525b509190910192915050565b7fffffffffffffffffffffffffffffffffffffffff000000000000000000000000606094851b8116825292841b83166014820152921b166028820152603c0190565b90565b73ffffffffffffffffffffffffffffffffffffffff9384168152919092166020820152604081019190915260600190565b73ffffffffffffffffffffffffffffffffffffffff929092168252602082015260400190565b901515815260200190565b93845260ff9290921660208401526040830152606082015260800190565b918252602082015260400190565b60008085851115611922578182fd5b8386111561192e578182fd5b5050820193919092039150565b73ffffffffffffffffffffffffffffffffffffffff8116811461195d57600080fd5b50565b801515811461195d57600080fdfea164736f6c6343000706000a0000000000000000000000000000000000000000000000000000000000015180';

  static final e18 = BigInt.from(1e18);
  static final e9 = BigInt.from(1e9);

  final OrchidWeb3Context web3context;

  OrchidContractDeployment(this.web3context);

  Web3Provider get web3 => web3context.web3;

  int get chainId => web3context.chain.chainId;

  String get walletAddress => web3context.walletAddress.toString();

  Future<void> deploySingletonFactory() async {
    final factoryDeployerBalance = await web3.getBalance(factory_deployer_addr);
    log('factory_deployer_balance: ${factoryDeployerBalance / e18} ETH');

    // The gas price specified in the factory deploy tx
    final factoryDeployGasPrice = BigInt.from(500) * e9; // 500 GWEI
    // The gas limit specified in the factory deploy tx
    // The actual factory deploy gas use is 59911 but we have to match the tx
    final factoryDeployGasLimit = BigInt.from(100000); // 0x0186a0

    final factoryDeployFundsNeeded =
        factoryDeployGasLimit * factoryDeployGasPrice;
    log('factory deploy funds needed = ${factoryDeployFundsNeeded / e18} ETH');

    final payToFactoryDeployer =
        factoryDeployFundsNeeded - factoryDeployerBalance;
    log('toFundFactoryDeployer = ${payToFactoryDeployer / e18}');

    if (payToFactoryDeployer <= BigInt.zero) {
      log('Factory deployer funds sufficient.');
    } else {
      // Fund the single-use address
      log('Funding factory deployer account with: ${payToFactoryDeployer / e18}');
      final nonce = await web3.getTransactionCount(walletAddress, 'pending');
      final TransactionResponse response1 =
          await web3.getSigner().sendTransaction(
                TransactionRequest(
                  to: factory_deployer_addr,
                  from: walletAddress,
                  value: payToFactoryDeployer,
                  nounce: nonce,
                ),
              );

      UserPreferencesDapp().addTransaction(DappTransaction(
        transactionHash: response1.hash,
        chainId: chainId,
        type: DappTransactionType.fundContractDeployer,
      ));
      final receipt1 = await response1.wait();
      log('fund deployer result: ${receipt1}');
    }

    // Send the pre-signed factory create tx
    // Note: this does not trigger a metamask confirmation!
    log('Deploying orchid singleton factory...');
    final response2 = await web3.sendTransaction(factory_deploy_tx_data);
    UserPreferencesDapp().addTransaction(DappTransaction(
      transactionHash: response2.hash,
      chainId: chainId,
      type: DappTransactionType.deploySingletonFactory,
    ));
    final receipt2 = await response2.wait();
    log('Deploy singleton factory result: ${receipt2}');
  }

  Future<void> deployV1Contract() async {
    // use the singleton factory to deploy the contract
    final nonce = await web3.getTransactionCount(walletAddress, 'pending');
    // log('deploy v1 nonce = ${nonce}');

    final gasPrice = await web3.getGasPrice();
    log('gas price = ${gasPrice / e9} GWEI');

    log("Deploying orchid v1 contract...");
    // TODO: Convert to EIP1559
    final TransactionResponse response = await web3.getSigner().sendTransaction(
          TransactionRequest(
            to: factory_addr,
            from: walletAddress,
            gasLimit: BigInt.from(0x16a0c9),
            gasPrice: gasPrice,
            data: v1_deploy_tx_input,
            nounce: nonce,
          ),
        );
    UserPreferencesDapp().addTransaction(DappTransaction(
      transactionHash: response.hash,
      chainId: chainId,
      type: DappTransactionType.deployContract,
    ));
    final receipt = await response.wait();
    log('deploy contract v1 result: ${receipt}');
  }

  Future<bool> v1ContractDeployed() async {
    final code = await web3.getCode(v1_addr);
    final deployed = code != '0x';
    log('Contract deployed : $deployed');
    return deployed;
  }

  Future<bool> singletonFactoryDeployed() async {
    final code = await web3.getCode(factory_addr);
    final deployed = code != '0x';
    log('Singleton factory deployed: $deployed');
    return deployed;
  }

  void logStatus() async {
    await v1ContractDeployed();
    await singletonFactoryDeployed();
  }

  /// returns true if the contract was deployed
  Future<bool> deployIfNeeded() async {
    // Is the contract already deployed?
    if (!await v1ContractDeployed()) {
      // Is the orchid singleton factory deployed?
      if (!await singletonFactoryDeployed()) {
        // Use Nick's method to deploy the singleton factory
        await deploySingletonFactory();
      }
      await deployV1Contract();
      return true;
    }
    return false;
  }
}
