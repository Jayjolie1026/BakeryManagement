import 'package:bakery_management/pages/tasksAPI.dart';
import 'package:flutter/material.dart';
import 'tasksFunctions.dart';
import 'tasksItemClass.dart';
import 'package:intl/intl.dart'; // Import intl package for date formatting

import 'package:bakery_management/pages/tasksAPI.dart';
import 'package:flutter/material.dart';
import 'tasksFunctions.dart';
import 'tasksItemClass.dart';
import 'package:intl/intl.dart'; // Import intl package for date formatting

Future<void> showTaskDetailsDialog(BuildContext context, Task task) async {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: const Color(0xFFEEC07B), // Light brown background
        title: const Text(
          'Task Details',
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
              RichText(
                text: TextSpan(
                  style: const TextStyle(color: Color(0xFF6D3200), fontSize: 16), // Dark brown text with increased font size
                  children: [
                    const TextSpan(text: 'Description:\n', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)), // Bold heading with increased font size
                    TextSpan(text: '\t\t${task.description}', style: const TextStyle(fontSize: 20)), // Tab before data (increased tabs for better alignment)
                  ],
                ),
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: const TextStyle(color: Color(0xFF6D3200), fontSize: 16),
                  children: [
                    const TextSpan(text: 'Created On:\n', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)), // Bold heading with increased font size
                    TextSpan(text: '\t\t${DateFormat('yMMMd').format(task.createDate)}', style: const TextStyle(fontSize: 20)), // Tab before data
                  ],
                ),
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: const TextStyle(color: Color(0xFF6D3200), fontSize: 16),
                  children: [
                    const TextSpan(text: 'Due Date:\n', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)), // Bold heading with increased font size
                    TextSpan(text: '\t\t${DateFormat('yMMMd').format(task.dueDate)}', style: const TextStyle(fontSize: 20)), // Tab before data
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Close', style: TextStyle(color: Color(0xFF6D3200))),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

