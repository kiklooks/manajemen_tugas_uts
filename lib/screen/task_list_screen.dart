import 'package:flutter/material.dart';
import 'package:manajemen_tugas_uts/model/Task_model.dart';
import 'package:manajemen_tugas_uts/helper/database_helper.dart';

class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TextEditingController _taskController = TextEditingController();
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Task> _tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() async {
    final tasks = await _databaseHelper.getTasks();
    setState(() {
      _tasks = tasks;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task List'),
      ),
      body: ListView.builder(
        itemCount: _tasks.length,
        itemBuilder: (context, index) {
          final task = _tasks[index];
          return ListTile(
            title: Text(task.name),
            trailing: Checkbox(
              value: task.isDone,
              onChanged: (value) {
                setState(() {
                  task.isDone = value;
                  _databaseHelper.updateTask(task);
                });
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final taskName = await showDialog<String>(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Add Task'),
                content: TextField(
                  controller: _taskController,
                  decoration: InputDecoration(labelText: 'Task Name'),
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(_taskController.text);
                    },
                    child: Text('Add'),
                  ),
                ],
              );
            },
          );

          if (taskName != null && taskName.isNotEmpty) {
            final task = Task(name: taskName);
            await _databaseHelper.insertTask(task);
            _loadTasks();
          }
        },
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () async {
                await _databaseHelper.deleteDoneTasks();
                _loadTasks();
              },
            ),
          ],
        ),
      ),
    );
  }
}
