import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:todo_dapp_front/task.dart';
import 'dart:convert';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:todo_dapp_front/task.dart';
import 'package:todo_dapp_front/model/todo_list_model.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/io.dart';

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
    }).toList();

    isLoading = false;
    todos = todos.reversed.toList();

    notifyListeners();
  }

  //1.to-doを作成する機能
  @override
  addTask(String taskNameData) async {
    isLoading = true;
    notifyListeners();

    final ref = _db.collection('todos');
    await ref.add({
      'id': todos.length,
      'taskName': taskNameData,
      'isCompleted': false,
    });

    await getTodos();
  }

  //2.to-doを更新する機能
  @override
  updateTask(int id, String taskNameData) async {
    isLoading = true;
    notifyListeners();

    await getTodos();
  }

  //3.to-doの完了・未完了を切り替える機能
  @override
  toggleComplete(int id) async {
    isLoading = true;
    notifyListeners();
    final ref = _db.collection('todos');
    final snap = await ref.where(id, isEqualTo: id).get();
    final target = snap.docs[0];
    await ref
        .doc(target.id)
        .update({'isCompleted': !target.data()['isCompleted']});

    await getTodos();
  }

  //4.to-doを削除する機能
  @override
  deleteTask(int id) async {
    isLoading = true;
    notifyListeners();

    await _db
        .collection('todos')
        .where(id, isEqualTo: id)
        .get()
        .then((value) async {
      await Future.forEach(value.docs, (todo) {
        todo as QueryDocumentSnapshot;
        todo.reference.delete();
      });
    });

    await getTodos();
  }
}
