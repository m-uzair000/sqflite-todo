import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_todo/todo_model.dart';

class SqfLiteHelper {
  static const _databaseName = "todo.db";
  static const _databaseVersion = 1;

  static const table = 'todo';

  static const columnId = 'id';
  static const columnTitle = 'title';
  static const columnDescription = 'description';

  SqfLiteHelper._();

  static final SqfLiteHelper instance = SqfLiteHelper._();

  static Database? _database;

  Future<Database?> get database async {
    if (_database != null) {
      return _database;
    }
    _database = await _initializeDatabase();
    return _database;
  }

  Future<Database> _initializeDatabase() async {
    Directory directory =
        await getApplicationDocumentsDirectory(); //returns a directory which stores permanent files
    final path = join(directory.path, _databaseName); //create path to database
    print("in db");

    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY,
            $columnTitle TEXT NOT NULL,
            $columnDescription TEXT NOT NULL
          )
          ''');
  }

  Future<int> addItem(TodoModel item) async {
    final db = await instance.database;

    /// open database

    var val = db!.insert(table, item.toMap(),conflictAlgorithm: ConflictAlgorithm.replace);

    /// toMap() function from TodoModel

    return val;
  }

  Future<List<TodoModel>> getAllItems() async {
    /// returns the data as a list (array)

    final db = await instance.database;

    /// open database

    final maps = await db!.query(table);

    /// query all the rows in a table as an array of maps

    return List.generate(maps.length, (i) {
      /// create a list of memos
      return TodoModel.fromMap(maps[i]);
    });
  }

  Future<int> deleteTodoItem(int id) async {
    //returns number of items deleted
    final db = await instance.database;

    /// open database

    int result = await db!.delete(table,

        /// table name
        where: "id = ?",
        whereArgs: [id]

        /// use whereArgs to avoid SQL injection
        );
    return result;
  }

  deleteAllTodos() async {
    final db = await instance.database;
    db!.rawDelete("Delete * from $table");
  }

  Future<TodoModel> getTodoItem(int id) async {
    /// returns number of items deleted
    final db = await instance.database; /// open database

    var map = await db!.rawQuery('SELECT * FROM $table WHERE id=?', [id]);

    return TodoModel.fromMap(map.first);
  }

  Future<int> updateTodoItem(TodoModel item) async {
    /// returns the number of rows updated

    final db = await instance.database;

    /// open database

    int result = await db!
        .update(table, item.toMap(), where: "id = ?", whereArgs: [item.id]);
    return result;
  }
}
