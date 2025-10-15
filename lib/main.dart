import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_todo_app/firebase_options.web.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: firebaseWebOptions);
  runApp(ToDoApp());
}

class ToDoApp extends StatelessWidget {
  const ToDoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "To Do App",
      theme: ThemeData.dark(),
      home: ToDoScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ToDoScreen extends StatelessWidget {
  final CollectionReference todos = FirebaseFirestore.instance.collection(
    "todos",
  );

  ToDoScreen({super.key});

  final TextEditingController controller = TextEditingController();

  void addTodo() {
    final text = controller.text;
    if (text.isNotEmpty) {
      todos.add({'title': text, 'done': false});
      controller.clear();
    }
  }

  void deleteTodo(DocumentSnapshot doc) {
    todos.doc(doc.id).delete();
  }

  void toggleDone(DocumentSnapshot doc) {
    todos.doc(doc.id).update({'done': !doc['done']});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("To Do App")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller:
                        controller, //input (no caso o controler lá de cima)
                    decoration: InputDecoration(
                      hintText: "Nova Tarefa",
                    ), //Decoração, texto estático
                  ),
                ),
                IconButton(onPressed: addTodo, icon: Icon(Icons.add)),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: todos.snapshots(),
              builder: (context, snapshot) {
                //Estado do carregamento
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                //Caso de erro
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Ocorreu um erro no carregamento dos dados",
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                }

                //Caso não haja registro
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("Nenhum registro encontrado"));
                }

                final docs = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (_, index) {
                    final doc = docs[index];
                    return ListTile(
                      title: Text(
                        doc['title'],
                        style: TextStyle(
                          decoration: doc['done']
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      leading: Checkbox(value: doc['done'], onChanged: (_) => toggleDone(doc)),
                      trailing: IconButton(onPressed: () => deleteTodo(doc), icon: const Icon(Icons.delete)),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
