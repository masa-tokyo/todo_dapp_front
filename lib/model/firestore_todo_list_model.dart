import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todo_dapp_front/task.dart';
import 'package:todo_dapp_front/model/todo_list_model.dart';

class FirestoreTodoListModel extends TodoListModel {
  FirestoreTodoListModel() {
    getTodos();
  }

  final _db = FirebaseFirestore.instance;

  @override
  getTodos() async {
    final todosSnap = await _db.collection('todos').get();
    todos = todosSnap.docs.map((e) {
      final todo = e.data();
      return Task(
        id: todo['id'],
        taskName: todo['taskName'],
        isCompleted: todo['isCompleted'],
      );
    }).toList()
      ..sort((a, b) => a.id!.compareTo(b.id!));

    isLoading = false;
    notifyListeners();
  }

  @override
  addTask(String taskNameData) async {
    isLoading = true;
    notifyListeners();

    await _db.collection('todos').add({
      'id': todos.last.id! + 1,
      'taskName': taskNameData,
      'isCompleted': false,
    });
    await getTodos();
  }

  @override
  updateTask(int id, String taskNameData) async {
    isLoading = true;
    notifyListeners();

    final snap = await _db.collection('todos').where('id', isEqualTo: id).get();
    final target = snap.docs[0];
    await target.reference.update({
      'taskName': taskNameData,
    });

    await getTodos();
  }

  @override
  toggleComplete(int id) async {
    isLoading = true;
    notifyListeners();
    final snap = await _db.collection('todos').where('id', isEqualTo: id).get();
    final target = snap.docs[0];
    await target.reference
        .update({'isCompleted': !target.data()['isCompleted']});

    await getTodos();
  }

  @override
  deleteTask(int id) async {
    isLoading = true;
    notifyListeners();

    await _db
        .collection('todos')
        .where('id', isEqualTo: id)
        .get()
        .then((value) async {
      final target = value.docs[0];
      await target.reference.delete();
    });

    await getTodos();
  }
}
