import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:todo_dapp_front/model/firestore_todo_list_model.dart';
import 'package:todo_dapp_front/view/todo_bottom_sheet.dart';
import 'package:todo_dapp_front/model/polygon_todo_list_model.dart';

class TodoList extends StatelessWidget {
  const TodoList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final listModel = dotenv.env['USE_POLYGON'] == 'true'
        ? Provider.of<PolygonTodoListModel>(context, listen: true)
        : Provider.of<FirestoreTodoListModel>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dapp Todo"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showTodoBottomSheet(context, onCreate: (controller) {
            listModel.addTask(controller.text);
            Navigator.pop(context);
          });
        },
        child: const Icon(Icons.add),
      ),
      body: listModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: listModel.todos.length,
                    itemBuilder: (context, index) => ListTile(
                      title: InkWell(
                        onTap: () {
                          final task = listModel.todos[index];
                          showTodoBottomSheet(context, task: task,
                              onUpdate: (controller) {
                            listModel.updateTask(task.id!, controller.text);
                            Navigator.pop(context);
                          }, onDelete: () {
                            listModel.deleteTask(task.id!);
                            Navigator.pop(context);
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            vertical: 2,
                            horizontal: 12,
                          ),
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              //チェックボックス
                              Checkbox(
                                value: listModel.todos[index].isCompleted,
                                onChanged: (val) {
                                  listModel.toggleComplete(
                                      listModel.todos[index].id!);
                                },
                              ),
                              //タスク名
                              Text(listModel.todos[index].taskName!),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
