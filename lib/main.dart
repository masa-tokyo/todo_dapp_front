import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:todo_dapp_front/config/firebase_options.dart';
import 'package:todo_dapp_front/model/firestore_todo_list_model.dart';
import 'package:todo_dapp_front/view/todo_list.dart';
import 'package:todo_dapp_front/model/polygon_todo_list_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<PolygonTodoListModel>(
          create: (context) => PolygonTodoListModel(),
        ),
        ChangeNotifierProvider<FirestoreTodoListModel>(
          create: (context) => FirestoreTodoListModel(),
        ),
      ],
      child: const MaterialApp(
        title: 'Flutter TODO',
        home: SetUp(child: TodoList()),
      ),
    );
  }
}

class SetUp extends StatefulWidget {
  const SetUp({Key? key, required this.child}) : super(key: key);
  final Widget child;

  @override
  State<SetUp> createState() => _SetUpState();
}

class _SetUpState extends State<SetUp> {
  bool isLoading = true;

  @override
  void initState() {
    _registerDIContainer().then((value) => setState(() => isLoading = false));
    super.initState();
  }

  Future<bool> _registerDIContainer() async {
    await dotenv.load();
    final getIt = GetIt.instance;
    await getIt.reset();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return isLoading ? const SizedBox.shrink() : widget.child;
  }
}
