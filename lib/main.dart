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
      title: 'Simple To Do List',
      theme: ThemeData.dark(),
      home: new ToDoList(),
    );
  }
}

class ToDoList extends StatefulWidget {
  @override
  createState() => _ToDoListState();
}

class _ToDoListState extends State<ToDoList> {
  final _toDoListTextStyle =
      const TextStyle(fontSize: 18.0, color: Colors.teal);
  final _toDoListTextStyleStriked = const TextStyle(
      fontSize: 18.0,
      color: Colors.blueGrey,
      decoration: TextDecoration.lineThrough);
  final _addingToDoListItemController = new TextEditingController();
  final _editingToDoListItemController = new TextEditingController();
  final _toDoListItems = new List<ToDoListItem>();
  final future = getToDoListItems();
  final key = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: key,
        appBar: AppBar(
          title: Text('To Do List Items'),
          actions: <Widget>[
            new IconButton(
              icon: new Icon(Icons.add),
              tooltip: "Add a to do list item",
              onPressed: _showNewToDoListDialog,
            ),
            new PopupMenuButton<Choices>(
              onSelected: (selected) => handleDropDownChoiceSelection(selected),
              itemBuilder: (BuildContext context) => <PopupMenuEntry<Choices>>[
                    const PopupMenuItem<Choices>(
                      value: Choices.removeAll,
                      child: const Text("Remove all items."),
                    )
                  ],
            ),
          ],
        ),
        body: new Builder(builder: (BuildContext context) {
          return _buildList();
        }));
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
      direction: DismissDirection.horizontal,
      key: Key(_item.toJson().toString() + index.toString()),
      background: Container(
        color: Colors.red,
        child: Icon(Icons.delete),
        alignment: Alignment.centerRight,
      ),
      onDismissed: (direction) {
        if (_toDoListItems[index] == _item) {
          setState(() {
            _toDoListItems.removeAt(index);
          });
        }
        replaceToDoListItems(_toDoListItems);

        key.currentState.showSnackBar(SnackBar(
            content: Text("Item ${_item.value} removed."),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                setState(() {
                  _toDoListItems.insert(index, _item);
                  replaceToDoListItems(_toDoListItems);
                });
              },
            )));
      },
      child: ListTile(
        title: Container(
            child: Row(children: [
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Container(
                    child: Text(_item.value,
                        style: _item.isCompleted
                            ? _toDoListTextStyleStriked
                            : _toDoListTextStyle))
              ])),
          new IconButton(
              icon: Icon(
                _item.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: _item.isFavorite ? Colors.redAccent : null,
              ),
              tooltip: "Favorite your item.",
              onPressed: () {
                setState(() {
                  _item.isFavorite = !_item.isFavorite;
                });
                replaceToDoListItems(_toDoListItems);
              }),
          new IconButton(
              icon: Icon(
                _item.isCompleted
                    ? Icons.check_box
                    : Icons.check_box_outline_blank,
                color: _item.isCompleted ? Colors.teal : null,
              ),
              tooltip: "Set your item to complete.",
              onPressed: () {
                setState(() {
                  _item.isCompleted = !_item.isCompleted;
                });
                replaceToDoListItems(_toDoListItems);
              })
        ])),
        onLongPress: () {
          _showEditToDoListDialog(index);
        },
      ),
    );
  }

  Widget _addToDoListItemField() {
    _addingToDoListItemController.clear();
    return TextField(
      controller: _addingToDoListItemController,
      autofocus: true,
      decoration: InputDecoration(
          border: OutlineInputBorder(),
          helperText: "Insert a new to do list item."),
      onSubmitted: (submittedValue) {
        print("Adding todolist item: " + submittedValue);
        this.addToDoListItem(submittedValue);
        _addingToDoListItemController.text = "";
      },
    );
  }

  Widget _editToDoListItemField(int index) {
    ToDoListItem _item = _toDoListItems[index];
    _editingToDoListItemController.text = _item.value;

    return TextField(
        controller: _editingToDoListItemController,
        autofocus: true,
        decoration: InputDecoration(
            border: OutlineInputBorder(),
            helperText: "Edit the to do list item."),
        onSubmitted: (submittedValue) {
          print("Editing todolist at index: $index item: $submittedValue");
          setState(() {
            _item.value = submittedValue;
          });
          replaceToDoListItems(_toDoListItems);
          Navigator.pop(context);
        });
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
  }

  void _showNewToDoListDialog() {
    //TODO Fix issue with deprecated use of child (not sure how).
    showDialog(
        context: context, child: new Dialog(child: _addToDoListItemField()));
  }

  void _showEditToDoListDialog(int index) {
    showDialog(
        context: context,
        child: new Dialog(child: _editToDoListItemField(index)));
  }

  void _showAreYouSureRemoveAllDialog() {
    showDialog(
        context: context,
        child: new AlertDialog(
            title: new Text('Confirm'),
            content: new Text(
                'Are you sure you would like to remove all of your to do list items? They can not be recovered afterwards.'),
            actions: <Widget>[
              new FlatButton(
                  child: Text('Yes'),
                  onPressed: () {
                    setState(() {
                      _toDoListItems.clear();
                    });

                    replaceToDoListItems(_toDoListItems);
                    Navigator.pop(context);
                  }),
              new FlatButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ]));
  }

  handleDropDownChoiceSelection(Choices _choice) {
    switch (_choice) {
      case Choices.removeAll:
        //Are you sure dialog?
        _showAreYouSureRemoveAllDialog();
        break;

      case Choices.settingsPage:
        break;
    }
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

enum Choices {
  removeAll,
  settingsPage,
}
