import 'tasksItemClass.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String baseUrl = 'https://bakerymanagement-efgmhebnd5aggagn.eastus-01.azurewebsites.net/tasks';

// Function to fetch tasks
Future<List<Task>> getTasks() async {
  final response = await http.get(Uri.parse(baseUrl));

  // Debugging
  print('Response status: ${response.statusCode}');
  if (response.statusCode != 200) {
    print('Error details: ${response.body}');
  }

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((task) => Task.fromJson(task)).toList();
  } else {
    throw Exception('Failed to load tasks: ${response.statusCode} - ${response.body}');
  }
}

// Function to add a task
Future<void> addTask({
  required String description,
  required DateTime dueDate,
  required String assignedBy,
}) async {
  final url = Uri.parse(baseUrl);
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      'Description': description,
      'DueDate': dueDate.toIso8601String(),
      'AssignedBy': assignedBy,
    }),
  );

  // Debugging
  print('Response status: ${response.statusCode}');
  print('Response body: ${response.body}');

  if (response.statusCode == 201) {
    print('Task added successfully');
  } else {
    throw Exception('Failed to add task: ${response.statusCode} - ${response.body}');
  }
}

// Similar debugging for updateTask and deleteTask...


// Function to update a task
Future<void> updateTask({
  required int taskId,
  required String description,
  required DateTime dueDate,
  required String assignedBy,
}) async {
  final url = Uri.parse('$baseUrl/$taskId'); // Using the base URL and appending the task ID

  final response = await http.put(
    url,
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      'Description': description,
      'DueDate': dueDate.toIso8601String(),
      'AssignedBy': assignedBy,
    }),
  );

  if (response.statusCode == 200) {
    print('Task updated successfully');
  } else {
    throw Exception('Failed to update task: ${response.body}');
  }
}

// Function to delete a task
Future<void> deleteTask(int taskId) async {
  final url = Uri.parse('$baseUrl/$taskId'); // Using the base URL and appending the task ID

  final response = await http.delete(url);

  if (response.statusCode == 200) {
    print('Task deleted successfully');
  } else {
    throw Exception('Failed to delete task: ${response.body}');
  }
}
