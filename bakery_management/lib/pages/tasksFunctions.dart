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

Future<bool> showAddTaskDialog(BuildContext context, String userId) async {
  bool taskAdded = false; // Variable to track if a task was added

  taskAdded = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AddTaskDialog(userId: userId);
    },
  ) ?? false; // Return false if the dialog is dismissed or cancelled

  return taskAdded;
}

class AddTaskDialog extends StatefulWidget {
  final String userId;

  const AddTaskDialog({Key? key, required this.userId}) : super(key: key);

  @override
  _AddTaskDialogState createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  String taskDescription = '';
  DateTime? taskDueDate;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFFEEC07B), // Light brown background
      title: const Text(
        'Add Task',
        style: TextStyle(
          color: Color(0xFF6D3200),
          fontSize: 25,
          fontWeight: FontWeight.bold, // Bold text
          decoration: TextDecoration.underline, // Underline text
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Task Description Input
            TextField(
              decoration: InputDecoration(
                labelText: 'Task Description',
                labelStyle: const TextStyle(color: Color(0xFF6D3200)), // Dark brown label text
                counterText: '${taskDescription.length}/100', // Character counter
              ),
              style: const TextStyle(color: Color(0xFF6D3200)), // Color of the text that's typed
              maxLines: null, // Allows the TextField to grow
              maxLength: 100, // Limit input to 100 characters
              onChanged: (value) {
                setState(() {
                  taskDescription = value;
                });
              },
            ),
            const SizedBox(height: 10), // Reduced space between elements
            
            // Button to select due date
            TextButton(
              onPressed: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2101),
                );

                if (pickedDate != null) {
                  // Set the selected due date and rebuild the widget
                  setState(() {
                    taskDueDate = pickedDate;
                  });
                }
              },
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: taskDueDate == null
                          ? 'Select Due Date'
                          : 'Due: ${taskDueDate!.toLocal().toIso8601String().split('T')[0]}', // Format the date
                      style: const TextStyle(
                        color: Color(0xFF6D3200), // Dark brown text
                        decoration: TextDecoration.underline, // Underlined text
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Cancel', style: TextStyle(color: Color(0xFF6D3200))),
          onPressed: () {
            Navigator.of(context).pop(false); // Return false when cancelled
          },
        ),
        ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(const Color(0xFF6D3200)), // Dark brown background
            foregroundColor: MaterialStateProperty.all(const Color(0xFFEEC07B)), // Light brown text
          ),
          onPressed: () async {
            var assID = widget.userId;
            print('Assigned ID function: $assID');
            try {
              // Ensure taskDueDate is not null before proceeding
              if (taskDueDate != null && taskDescription.isNotEmpty) {
                // Add task using the provided details
                await addTask(
                  description: taskDescription,
                  dueDate: taskDueDate!, // Use the selected due date
                  assignedBy: widget.userId, // Send the user ID as AssignedBy
                );
                Navigator.of(context).pop(true); // Return true when the task is successfully added
              } else {
                // Show a message if required fields are not filled
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a description and select a due date.')),
                );
              }
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
  }
}



Future<bool> handleEditTask(BuildContext context, Task task) async {
  final descriptionController = TextEditingController(text: task.description);
  DateTime dueDate = task.dueDate; // Initialize with the current due date if it exists

  // Initialize the current character count
  int currentLength = task.description.length;

  final result = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: const Color(0xFFEEC07B), // Light brown background
        title: const Text(
          'Update Task Info',
          style: TextStyle(
            color: Color(0xFF6D3200),
            fontSize: 25,
            fontWeight: FontWeight.bold, // Bold text
            decoration: TextDecoration.underline, // Underline text
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Task Description (Editable)
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                    color: Color(0xFF6D3200),
                    fontSize: 20,
                  ),
                  children: [
                    TextSpan(
                      text: 'Task Description:\n',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8), // Reduced space for better spacing

              // TextField with max height and multiline support
              Container(
                constraints: BoxConstraints(maxHeight: 120), // Limit height
                child: TextField(
                  controller: descriptionController,
                  maxLines: null, // Allow multiple lines
                  maxLength: 100, // Limit input to 100 characters
                  style: const TextStyle(color: Color(0xFF6D3200), fontSize: 20),
                  decoration: InputDecoration(
                    labelStyle: const TextStyle(color: Color(0xFF6D3200), fontSize: 20), // Dark brown label text
                    border: const OutlineInputBorder(), // Optional: add border for clarity
                    counterText: '$currentLength/100', // Dynamic character counter
                  ),
                  onChanged: (text) {
                    // Update current length on text change
                    currentLength = text.length;
                    // Force a rebuild to update the displayed character count
                    (context as Element).markNeedsBuild();
                  },
                ),
              ),
              const SizedBox(height: 20), // Keep space below for date section

              // Due Date (Display + Change Date Button)
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                    color: Color(0xFF6D3200),
                    fontSize: 20,
                  ),
                  children: [
                    TextSpan(
                      text: 'Due Date:\n',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4), // Smaller space between date heading and button

              // Text widget to display the due date
              TextButton(
                onPressed: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: dueDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2101),
                  );

                  if (pickedDate != null) {
                    // Strip time information and set it to midnight
                    dueDate = DateTime(pickedDate.year, pickedDate.month, pickedDate.day, 12); // Set noon to avoid any time zone shifts
                    
                    // Force a rebuild to update the displayed date
                    (context as Element).markNeedsBuild();
                  }
                },
                child: Text(
                  dueDate != null
                      ? 'Due: ${dueDate.toLocal().toIso8601String().split('T')[0]}'
                      : 'Select Due Date',
                  style: const TextStyle(
                    color: Color(0xFF6D3200), // Dark brown text
                    fontSize: 20, // Same font size as the description
                    decoration: TextDecoration.underline, // Underline text
                  ),
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
                  taskId: task.taskId!,
                  description: descriptionController.text,
                  // Convert the selected due date to UTC before sending it to the server
                  dueDate: DateTime(dueDate.year, dueDate.month, dueDate.day).toUtc(),
                  assignedBy: task.assignedBy,
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
          style: TextStyle(
            color: Color(0xFF6D3200), // Dark brown text
            fontWeight: FontWeight.bold, // Bold text
            fontSize: 25,
            decoration: TextDecoration.underline, // Underline text
          )
        ),
        content: const Text(
          'Are you sure you want to delete this task?',
          style: TextStyle(color: Color(0xFF6D3200), fontSize: 17), // Dark brown text
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

