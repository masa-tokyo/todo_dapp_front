import 'package:flutter/cupertino.dart';
import 'package:todo_dapp_front/task.dart';

abstract class TodoListModel extends ChangeNotifier {
  List<Task> todos = [];
  bool isLoading = true;
  int? taskCount;

  Future<void> getTodos();
  //1.to-doを作成する機能
  Future<void> addTask(String taskNameData);
  //2.to-doを更新する機能
  Future<void> updateTask(int id, String taskNameData);
  //3.to-doの完了・未完了を切り替える機能
  Future<void> toggleComplete(int id);
  //4.to-doを削除する機能
  Future<void> deleteTask(int id);
}
