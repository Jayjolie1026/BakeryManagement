import 'package:flutter/material.dart';
import 'tasksItemClass.dart';
import 'tasksAPI.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Fetch Tasks details from the API
Future<Task> fetchTaskDetails(int id) async {
  try {
    final response = await http.get(Uri.parse('https://bakerymanagement-efgmhebnd5aggagn.eastus-01.azurewebsites.net/tasks/$id'));

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);
      print('Task Details JSON: $json'); // Debugging line
      return Task.fromJson(json);
    } else {
      print('Failed to load task details. Status code: ${response.statusCode}');
      throw Exception('Failed to load task details');
    }
  } catch (e) {
    print('Error: $e');
    throw Exception('Failed to load task details');
  }
}

// Dialog to add a new task
Future<void> showAddTaskDialog(BuildContext context, VoidCallback onTaskAdded) async {
  String taskDescription = '';
  DateTime? taskDueDate;
  String assignedBy = '';

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: const Color(0xFFEEC07B), // Light brown background
        title: const Text(
          'Add Task',
          style: TextStyle(color: Color(0xFF6D3200)), // Dark brown text
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Task Description',
                  labelStyle: TextStyle(color: Color(0xFF6D3200)), // Dark brown label text
                ),
                style: const TextStyle(color: Color(0xFF6D3200)), // Color of the text that's typed
                onChanged: (value) {
                  taskDescription = value;
                },
              ),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Assigned By',
                  labelStyle: TextStyle(color: Color(0xFF6D3200)), // Dark brown label text
                ),
                style: const TextStyle(color: Color(0xFF6D3200)), // Color of the text that's typed
                onChanged: (value) {
                  assignedBy = value;
                },
              ),
              // Date picker for the due date
              TextButton(
                onPressed: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    taskDueDate = pickedDate;
                  }
                },
                child: Text(
                  taskDueDate == null
                      ? 'Select Due Date'
                      : 'Due Date: ${taskDueDate!.toLocal()}'.split(' ')[0],
                  style: TextStyle(color: Color(0xFF6D3200)), // Dark brown text
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF6D3200))),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(const Color(0xFF6D3200)), // Dark brown background
              foregroundColor: MaterialStateProperty.all(const Color(0xFFEEC07B)), // Light brown text
            ),
            onPressed: () async {
              try {
                // Add task using the provided details
                await addTask(
                  taskDescription,
                  taskDueDate!,
                  assignedBy,
                );
                Navigator.of(context).pop();
                onTaskAdded(); // Call the callback to refresh the list
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error adding task: $e')),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      );
    },
  );
}

// Dialog to handle editing a task
Future<bool> handleEditTask(BuildContext context, Task task) async {
  final descriptionController = TextEditingController(text: task.description);
  final assignedByController = TextEditingController(text: task.assignedBy);
  DateTime? dueDate = task.dueDate;

  final result = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: const Color(0xFFEEC07B), // Light brown background
        title: const Text(
          'Update Task Info',
          style: TextStyle(color: Color(0xFF6D3200)), // Dark brown text
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: descriptionController,
                style: const TextStyle(color: Color(0xFF6D3200)),
                decoration: const InputDecoration(
                  labelText: 'Task Description',
                  labelStyle: TextStyle(color: Color(0xFF6D3200)), // Dark brown label text
                ),
              ),
              TextField(
                controller: assignedByController,
                style: const TextStyle(color: Color(0xFF6D3200)),
                decoration: const InputDecoration(
                  labelText: 'Assigned By',
                  labelStyle: TextStyle(color: Color(0xFF6D3200)), // Dark brown label text
                ),
              ),
              TextButton(
                onPressed: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: dueDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    dueDate = pickedDate;
                  }
                },
                child: Text(
                  dueDate == null
                      ? 'Select Due Date'
                      : 'Due Date: ${dueDate!.toLocal()}'.split(' ')[0],
                  style: TextStyle(color: Color(0xFF6D3200)), // Dark brown text
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF6D3200))),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(const Color(0xFF6D3200)), // Dark brown background
              foregroundColor: MaterialStateProperty.all(const Color(0xFFEEC07B)), // Light brown text
            ),
            onPressed: () async {
              try {
                // Update task using the provided details
                await updateTask(
                  task.taskId!, // Assuming task has an id
                  descriptionController.text,
                  dueDate!,
                  assignedByController.text,
                );
                Navigator.of(context).pop(true);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error updating task: $e')),
                );
              }
            },
            child: const Text('Update'),
          ),
        ],
      );
    },
  );

  return result ?? false;
}

// Dialog to confirm deletion of a task
Future<void> showDeleteTaskDialog(BuildContext context, int taskId, VoidCallback onTaskDeleted) async {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: const Color(0xFFEEC07B), // Light brown background
        title: const Text(
          'Delete Task',
          style: TextStyle(color: Color(0xFF6D3200)), // Dark brown text
        ),
        content: const Text(
          'Are you sure you want to delete this task?',
          style: TextStyle(color: Color(0xFF6D3200)), // Dark brown text
        ),
        actions: [
          TextButton(
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF6D3200))),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(const Color(0xFF6D3200)), // Dark brown background
              foregroundColor: MaterialStateProperty.all(const Color(0xFFEEC07B)), // Light brown text
            ),
            onPressed: () async {
              try {
                // Delete the task by its ID
                await deleteTask(taskId);
                Navigator.of(context).pop();
                onTaskDeleted(); // Call the callback to refresh the list
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error deleting task: $e')),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );
}

// Function to add a task using the API
Future<void> addTask(String description, DateTime dueDate, String assignedBy) async {
  try {
    final response = await http.post(
      Uri.parse('https://bakerymanagement-efgmhebnd5aggagn.eastus-01.azurewebsites.net/tasks'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'description': description,
        'dueDate': dueDate.toIso8601String(),
        'assignedBy': assignedBy,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add task. Status code: ${response.statusCode}');
    }
  } catch (e) {
    print('Error adding task: $e');
    throw Exception('Failed to add task');
  }
}

// Function to update a task using the API
Future<void> updateTask(int id, String description, DateTime dueDate, String assignedBy) async {
  try {
    final response = await http.put(
      Uri.parse('https://bakerymanagement-efgmhebnd5aggagn.eastus-01.azurewebsites.net/tasks/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'description': description,
        'dueDate': dueDate.toIso8601String(),
        'assignedBy': assignedBy,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update task. Status code: ${response.statusCode}');
    }
  } catch (e) {
    print('Error updating task: $e');
    throw Exception('Failed to update task');
  }
}

// Function to delete a task using the API
Future<void> deleteTask(int id) async {
  try {
    final response = await http.delete(
      Uri.parse('https://bakerymanagement-efgmhebnd5aggagn.eastus-01.azurewebsites.net/tasks/$id'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete task. Status code: ${response.statusCode}');
    }
  } catch (e) {
    print('Error deleting task: $e');
    throw Exception('Failed to delete task');
  }
}
