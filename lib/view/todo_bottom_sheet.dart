import 'package:flutter/material.dart';
import 'package:todo_dapp_front/task.dart';

showTodoBottomSheet(BuildContext context,
    {void Function(TextEditingController controller)? onCreate,
    void Function(TextEditingController controller)? onUpdate,
    void Function()? onDelete,
    Task? task}) {
  TextEditingController _titleController =
      TextEditingController(text: task?.taskName ?? "");

  return showModalBottomSheet<void>(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.only(top: 10),
          margin: const EdgeInsets.all(10),
          height: 300,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: 6,
                  width: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(
                  height: 18,
                ),
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    contentPadding: EdgeInsets.only(
                      left: 14.0,
                      bottom: 20.0,
                      top: 20.0,
                    ),
                    hintText: 'Enter a search term',
                    hintStyle: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                ),
                const SizedBox(
                  height: 12,
                ),
                if (task == null)
                  buildButton(context, 'Create', () async {
                    if (onCreate != null) {
                      onCreate(_titleController);
                    }
                  }),
                if (task != null)
                  buildButton(context, 'Update', () async {
                    if (onUpdate != null) {
                      onUpdate(_titleController);
                    }
                  }),
                if (task != null)
                  buildButton(context, 'Delete', () async {
                    if (onDelete != null) {
                      onDelete();
                    }
                  })
              ],
            ),
          ),
        );
      });
}

TextButton buildButton(BuildContext context, String text, Function onPressed) {
  return TextButton(
      onPressed: () async {
        onPressed();
        Navigator.pop(context);
      },
      child: Container(
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
            ),
          ),
        ),
        height: 50,
        padding: const EdgeInsets.symmetric(vertical: 10),
        width: double.infinity,
        decoration: BoxDecoration(
          color: text == "Delete" ? Colors.red : Colors.blue,
          borderRadius: BorderRadius.circular(15),
        ),
      ));
}
