import 'package:flutter/cupertino.dart';
import 'package:todo_dapp_front/task.dart';

abstract class TodoListModel extends ChangeNotifier {
  List<Task> todos = [];
  bool isLoading = true;
  int? taskCount;

  Future<void> getTodos();
  Future<void> addTask(String taskNameData);
  Future<void> updateTask(int id, String taskNameData);
  Future<void> toggleComplete(int id);
  Future<void> deleteTask(int id);
}
