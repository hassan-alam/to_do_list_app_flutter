import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

//TODO Set up path as config variable
final _toDoListPath = 'v3toDoListItems.json';
void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(),
      home: new ToDoList(),
    );
  }
}

class ToDoList extends StatefulWidget {
  @override
  createState() => _ToDoListState();
}

class _ToDoListState extends State<ToDoList> {
  final _biggerFont = const TextStyle(fontSize: 18.0);
  final _toDoListItems = new List<ToDoListItem>();
  final future = getToDoListItems();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('To Do List Items')),
      body: _buildList(),
      bottomNavigationBar: _addToDoListItemBar(),
    );
  }

  Widget _buildList() {
    return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _toDoListItems.length,
        itemBuilder: (context, i) {
          print("building listing...");
          return _buildRow(_toDoListItems[i], i);
        });
  }

  Widget _buildRow(ToDoListItem _item, int index) {
    return Dismissible(
      key: Key(_item.toJson().toString()),
      background: Container(color: Colors.red),
      onDismissed: (direction) {
        setState(() {
          _toDoListItems.removeAt(index);
        });

        replaceToDoListItems(_toDoListItems);

        Scaffold
            .of(context)
            .showSnackBar(SnackBar(content: Text("$_item.value")));
      },
      child: ListTile(
        title: Text(_item.value, style: _biggerFont),
        trailing: new IconButton(
            icon: Icon(
              _item.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _item.isFavorite ? Colors.red : null,
            ),
            tooltip: "Favorite your item.",
            onPressed: () {
              setState(() {
                _item.isFavorite = !_item.isFavorite;
              });
              replaceToDoListItems(_toDoListItems);
            }), //TODO: Add another trailing icon for completing the icon
      ),
    );
  }

  Widget _addToDoListItemBar() {
    return TextField(
      decoration: InputDecoration(
          border: OutlineInputBorder(),
          helperText: "Insert a new to do list item.",
          labelText: "New To Do List Item"),
      onSubmitted: (submittedValue) {
        print("Adding todolist item: " + submittedValue);
        this.addToDoListItem(submittedValue);
      },
    );
  }

  void addToDoListItem(String value) {
    ToDoListItem _item = new ToDoListItem(value, false, false);
    setState(() {
      _toDoListItems.add(_item);
    });
    replaceToDoListItems(_toDoListItems);
  }

  @override
  void initState() {
    super.initState();
    future.then((value) => setState(() {
          _toDoListItems.addAll(value);
        }));
  }

  @override
  void deactivate() {
    super.deactivate();
    _toDoListItems.clear();
  }
}

class ToDoListItem {
  String value;
  bool isCompleted;
  bool isFavorite;

  ToDoListItem(this.value, this.isCompleted, this.isFavorite);

  ToDoListItem.fromJson(Map<String, dynamic> json)
      : value = json['value'],
        isCompleted = json['isCompleted'],
        isFavorite = json['isFavorite'];

  Map<String, dynamic> toJson() =>
      {'value': value, 'isCompleted': isCompleted, 'isFavorite': isFavorite};

  static List<ToDoListItem> fromJsonList(List<dynamic> map) {
    final _list = new List<ToDoListItem>();
    map.forEach((f) => _list.add(ToDoListItem.fromJson(f)));
    return _list;
  }
}

Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();

  return directory.path;
}

Future<File> get _localFile async {
  final path = await _localPath;
  return new File('$path/$_toDoListPath');
}

Future<File> replaceToDoListItems(List<ToDoListItem> _list) async {
  final file = await _localFile;
  final stringJsonToWrite = json.encode(_list);
  return file.writeAsString(
    stringJsonToWrite,
    mode: FileMode.writeOnly,
  );
}

Future<List<ToDoListItem>> getToDoListItems() async {
  print("Retrieving from local file system");
  final file = await _localFile;
  if (await file.exists()) {
    final jsonRead = await file.readAsString();
    if (jsonRead.length != 0)
      return ToDoListItem.fromJsonList(json.decode(jsonRead));
  }
  return new List<ToDoListItem>();
}
