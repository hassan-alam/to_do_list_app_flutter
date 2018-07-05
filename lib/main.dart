import 'package:flutter/material.dart';

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
  //TODO add persistence to _toDoListItems
  final _toDoListItems = List<ToDoListItem>();

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
        itemBuilder: (context, i) {
          print("building listing...");
          while (i < _toDoListItems.length || i == 0) {
            return _buildRow(_toDoListItems[i]);
          }
        });
  }

  Widget _buildRow(ToDoListItem _item) {
    return ListTile(
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
          }), //TODO: Add another trailing icon for completing the icon
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
    setState(() {
      _toDoListItems.add(new ToDoListItem(value, false, false));
    });
  }
}

class ToDoListItem {
  String value;
  bool isCompleted;
  bool isFavorite;

  ToDoListItem(this.value, this.isCompleted, this.isFavorite);
}
