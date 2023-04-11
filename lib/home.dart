import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_todo/sqflite_helper.dart';
import 'package:sqflite_todo/todo_model.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home>  {
  SqfLiteHelper dbHelper = SqfLiteHelper.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SQFLite Database"),
        centerTitle: true,
      ),
      body: FutureBuilder<List<TodoModel>>(
        future: dbHelper.getAllItems(),
        builder: (
          BuildContext context,
          AsyncSnapshot<List<TodoModel>> snapshot,
        ) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child:  CircularProgressIndicator());
          } else if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return const Center(
                child: Text("List is Empty"),
              );
            } else if (snapshot.hasData) {
              var todoList = snapshot.data!;
              return todoList.isEmpty
                  ? const Center(
                      child: Text("List is Empty"),
                    )
                  : ListView.separated(
                      itemBuilder: (_, index) {
                        return ListTile(
                          title: Text(todoList[index].title),
                          subtitle: Text(todoList[index].description),
                          trailing: PopupMenuButton(
                            onSelected: (value) {
                              if (value == 'edit') {
                                showDialog(
                                    context: context,
                                    builder: (_) => insertDataDialog(context,
                                        todoModel: todoList[index]));
                              } else if (value == 'delete') {
                                _deleteTask(context, todoList[index].id);
                              }
                            },
                            itemBuilder: (BuildContext bc) {
                              return const [
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Text("Edit"),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Text("Delete"),
                                ),
                              ];
                            },
                          ),
                        );
                      },
                      separatorBuilder: (_, index) {
                        return const Divider();
                      },
                      itemCount: todoList.length,
                    );
            } else {
              return const Text('Empty data');
            }
          } else {
            return Text('State: ${snapshot.connectionState}');
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context, builder: (_) => insertDataDialog(context));
        },
        child: const Center(
          child: Icon(Icons.add),
        ),
      ),
    );
  }

  void _deleteTask(context, int id) {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: const Text('Delete Task'),
            content: const Text('Are you sure to remove the Task?'),
            actions: [
              TextButton(
                  onPressed: () {
                    dbHelper.deleteTodoItem(id);
                    Navigator.of(context).pop();
                    setState(() {});
                  },
                  child: const Text('Yes')),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('No'))
            ],
          );
        });
  }

  insertDataDialog(context, {TodoModel? todoModel}) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    TextEditingController title = TextEditingController();
    TextEditingController description = TextEditingController();
    if (todoModel != null) {
      title.text = todoModel.title;
      description.text = todoModel.description;
    }
    return AlertDialog(
      scrollable: true,
      title: Text(
        todoModel != null ? 'New Task' : 'Update Task',
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 16,
        ),
      ),
      content: SizedBox(
        height: height * 0.35,
        width: width,
        child: Form(
          key: formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: title,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "required";
                  }
                  return null;
                },
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  hintText: 'Title',
                  hintStyle: const TextStyle(fontSize: 14),
                  icon: const Icon(CupertinoIcons.square_list),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: description,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "required";
                  }
                  return null;
                },
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  hintText: 'Description',
                  hintStyle: const TextStyle(fontSize: 14),
                  icon: const Icon(CupertinoIcons.bubble_left_bubble_right),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            primary: Colors.grey,
          ),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (formKey.currentState!.validate()) {
              if (todoModel == null) {
                TodoModel todo =
                    TodoModel(title: title.text, description: description.text);
                dbHelper.addItem(todo);
              } else {
                todoModel.title = title.text;
                todoModel.description = description.text;
                dbHelper.updateTodoItem(todoModel);
              }
              Navigator.of(context).pop();
              setState(() {});
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
