import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/task.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var _taskController;
  List<Task> _tasks = [];
  List<bool> _tasksDone = [];

  void saveData() async {
    final prefs = await SharedPreferences.getInstance();
    Task t = Task.fromString(_taskController.text);

    String? tasks = prefs.getString("tasks");
    List lists = (tasks == null) ? [] : json.decode(tasks);
    print(lists);
    lists.add(json.encode(t.getMap()));
    print(lists);
    prefs.setString('tasks', json.encode(lists));
    _taskController.text = '';
    Navigator.of(context).pop();
    _getTasks();
  }

  void _getTasks() async {
    _tasks = [];
    final prefs = await SharedPreferences.getInstance();
    String? tasks = prefs.getString("tasks");
    List lists = (tasks == null) ? [] : json.decode(tasks);
    for (dynamic d in lists) {
      _tasks.add(Task.fromMap(json.decode(d)));
    }
    print(_tasks);

    _tasksDone = List.generate(_tasks.length, (index) => false);
    setState(() {});
  }

  void updateTasks() async {
    final prefs = await SharedPreferences.getInstance();
    List<Task> pendingList = [];
    for (var i = 0; i < _tasks.length; i++) {
      if (!_tasksDone[i]) pendingList.add(_tasks[i]);
    }
    var pendingListEncode = List.generate(pendingList.length,
        (index) => json.encode(pendingList[index].getMap()));
    prefs.setString('tasks', json.encode(pendingListEncode));
    _getTasks();
  }

  void deleteAllTasks() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('tasks');
    _getTasks();
  }

  @override
  void initState() {
    super.initState();
    _taskController = TextEditingController();
    _getTasks();
  }

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Todo App",
          style: GoogleFonts.montserrat(),
        ),
        actions: [
          IconButton(
            onPressed: updateTasks,
            icon: const Icon(Icons.save),
          ),
          IconButton(
            onPressed: deleteAllTasks,
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
      body: (_tasks.isEmpty)
          ? const Center(
              child: Text("No task added yet"),
            )
          : Column(
              children: _tasks
                  .map(
                    (e) => Container(
                      height: 70,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      padding: const EdgeInsets.only(left: 10),
                      alignment: Alignment.centerLeft,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: Colors.black, width: 0.5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(e.task, style: GoogleFonts.montserrat()),
                          Checkbox(
                            value: _tasksDone[_tasks.indexOf(e)],
                            onChanged: (val) => {
                              setState(
                                () => {_tasksDone[_tasks.indexOf(e)] = val!},
                              )
                            },
                          )
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showModalBottomSheet(
          context: context,
          builder: (BuildContext context) => Container(
            padding: const EdgeInsets.all(10.0),
            height: 250,
            color: Colors.blue[200],
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Add Task",
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontSize: 20.0,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Icon(Icons.close),
                    ),
                  ],
                ),
                const Divider(thickness: 1.2),
                const SizedBox(height: 20),
                TextField(
                  controller: _taskController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: const BorderSide(color: Colors.blue),
                    ),
                    fillColor: Colors.white,
                    filled: true,
                    hintText: 'Enter Task name',
                    hintStyle: GoogleFonts.montserrat(),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    children: [
                      SizedBox(
                        width: (MediaQuery.of(context).size.width / 2) - 20,
                        child: ElevatedButton(
                          onPressed: () => _taskController.text = '',
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.white),
                          ),
                          child: Text(
                            'RESET',
                            style: GoogleFonts.montserrat(color: Colors.black),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: (MediaQuery.of(context).size.width / 2) - 20,
                        child: ElevatedButton(
                          onPressed: () => saveData(),
                          child: Text(
                            'Add',
                            style: GoogleFonts.montserrat(),
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        backgroundColor: Colors.blue,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
