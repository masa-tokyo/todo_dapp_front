import 'dart:convert';
import 'dart:core';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:todo_dapp_front/task.dart';
import 'package:todo_dapp_front/model/todo_list_model.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/io.dart';

class PolygonTodoListModel extends TodoListModel {
  final String _rpcUrl = "http://10.0.2.2:7545";
  final String _wsUrl = "ws://127.0.0.1:7545/";

  final String _privateKey =
      "0c8211a46c6d0bf50277cca758c7b4e44680dce50f05aee02dec174ddeb3bae9";

  Web3Client? _client;
  String? _abiCode;

  Credentials? _credentials;
  EthereumAddress? _contractAddress;
  EthereumAddress? _ownAddress;
  DeployedContract? _contract;

  ContractFunction? _taskCount;
  ContractFunction? _todos;
  ContractFunction? _createTask;
  ContractFunction? _updateTask;
  ContractFunction? _deleteTask;
  ContractFunction? _toggleComplete;

  PolygonTodoListModel() {
    init();
  }

  Future<void> init() async {
    _client = Web3Client(_rpcUrl, Client(), socketConnector: () {
      return IOWebSocketChannel.connect(_wsUrl).cast<String>();
    });

    await getAbi();
    await getCredentials();
    await getDeployedContract();
  }

  //スマートコントラクトの`ABI`を取得し、デプロイされたコントラクトのアドレスを取り出す。
  Future<void> getAbi() async {
    String abiStringFile =
        await rootBundle.loadString("smartcontract/TodoContract.json");
    var jsonAbi = jsonDecode(abiStringFile);
    _abiCode = jsonEncode(jsonAbi["abi"]);
    _contractAddress =
        EthereumAddress.fromHex(jsonAbi["networks"]["5777"]["address"]);
  }

  //秘密鍵を渡して`Credentials`クラスのインスタンスを生成する。
  Future<void> getCredentials() async {
    _credentials = await _client!.credentialsFromPrivateKey(_privateKey);
    _ownAddress = await _credentials!.extractAddress();
  }

  //`_abiCode`と`_contractAddress`を使用して、スマートコントラクトのインスタンスを作成する。
  Future<void> getDeployedContract() async {
    _contract = DeployedContract(
        ContractAbi.fromJson(_abiCode!, "TodoList"), _contractAddress!);
    _taskCount = _contract!.function("taskCount");
    _updateTask = _contract!.function("updateTask");
    _createTask = _contract!.function("createTask");
    _deleteTask = _contract!.function("deleteTask");
    _toggleComplete = _contract!.function("toggleComplete");
    _todos = _contract!.function("todos");
    await getTodos();
  }

  @override
  getTodos() async {
    List totalTaskList = await _client!
        .call(contract: _contract!, function: _taskCount!, params: []);

    BigInt totalTask = totalTaskList[0];
    taskCount = totalTask.toInt();
    todos.clear();
    for (var i = 0; i < totalTask.toInt(); i++) {
      var temp = await _client!.call(
          contract: _contract!, function: _todos!, params: [BigInt.from(i)]);
      if (temp[1] != "") {
        todos.add(
          Task(
            id: (temp[0] as BigInt).toInt(),
            taskName: temp[1],
            isCompleted: temp[2],
          ),
        );
      }
    }
    isLoading = false;
    todos = todos.reversed.toList();

    notifyListeners();
  }

  @override
  addTask(String taskNameData) async {
    isLoading = true;
    notifyListeners();
    await _client!.sendTransaction(
        _credentials!,
        Transaction.callContract(
            contract: _contract!,
            function: _createTask!,
            parameters: [taskNameData]));
    await getTodos();
  }

  @override
  updateTask(int id, String taskNameData) async {
    isLoading = true;
    notifyListeners();
    await _client!.sendTransaction(
      _credentials!,
      Transaction.callContract(
        contract: _contract!,
        function: _updateTask!,
        parameters: [BigInt.from(id), taskNameData],
      ),
    );
    await getTodos();
  }

  @override
  toggleComplete(int id) async {
    isLoading = true;
    notifyListeners();
    await _client!.sendTransaction(
      _credentials!,
      Transaction.callContract(
        contract: _contract!,
        function: _toggleComplete!,
        parameters: [BigInt.from(id)],
      ),
    );
    await getTodos();
  }

  @override
  deleteTask(int id) async {
    isLoading = true;
    notifyListeners();
    await _client!.sendTransaction(
      _credentials!,
      Transaction.callContract(
        contract: _contract!,
        function: _deleteTask!,
        parameters: [BigInt.from(id)],
      ),
    );
    await getTodos();
  }
}
