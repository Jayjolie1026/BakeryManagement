import 'package:bakery_management/pages/tasksAPI.dart';
import 'package:flutter/material.dart';
import 'tasksFunctions.dart';
import 'tasksItemClass.dart';

class TaskDetailsPage extends StatelessWidget {
  final Task task;

  const TaskDetailsPage({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0D1A0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF0D1A0),
        elevation: 0,
        toolbarHeight: 100,
        title: const Text('Task Details', style: TextStyle(color: Color(0xFF6D3200))),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF6D3200)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Task Description
              _buildSectionTitle('Description:'),
              _buildSectionContent(task.description),

              // Create Date
              _buildSectionTitle('Created On:'),
              _buildSectionContent(task.createDate.toLocal().toString().split(' ')[0]),

              // Due Date
              _buildSectionTitle('Due Date:'),
              _buildSectionContent(
                task.dueDate != null ? task.dueDate.toLocal().toString().split(' ')[0] : 'No due date',
              ),

              // Assigned By
              _buildSectionTitle('Assigned By:'),
              _buildSectionContent(task.assignedBy),

              const SizedBox(height: 25),

              // Update/Delete Buttons
              _buildActionButtons(context),
              const SizedBox(height: 80), // Added space for the close button
            ],
          ),
        ),
      ),

      // Close Button at the Bottom
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFFF0D1A0),
        child: Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(const Color(0xFF6D3200)),
              foregroundColor: MaterialStateProperty.all(const Color(0xFFEEC07B)),
            ),
            child: const Text('Close', style: TextStyle(fontSize: 17)),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF6D3200),
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSectionContent(String content) {
    return Column(
      children: [
        Text(
          content,
          style: const TextStyle(
            color: Color(0xFF6D3200),
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        ElevatedButton(
          onPressed: () async {
            try {
              final updatedTask = await handleEditTask(context, task);
              if (updatedTask) {
                Navigator.of(context).pop(true);
              }
            } catch (e) {
              // Handle the error (e.g., show a SnackBar)
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error updating task: $e')),
              );
            }
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(const Color(0xFF6D3200)),
            foregroundColor: MaterialStateProperty.all(const Color(0xFFEEC07B)),
          ),
          child: const Row(
            children: [
              Icon(Icons.edit, color: Color(0xFFEEC07B)),
              SizedBox(width: 8),
              Text('Update', style: TextStyle(fontSize: 17)),
            ],
          ),
        ),
        const SizedBox(width: 20),
        ElevatedButton(
          onPressed: () async {
            final confirmed = await _showDeleteConfirmationDialog(context);
            if (confirmed) {
              try {
                final deleted = await handleRemoveTask(context, task.taskID);
                if (deleted) {
                  Navigator.of(context).pop(true);
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error deleting task: $e')),
                );
              }
            }
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(const Color(0xFF6D3200)),
            foregroundColor: MaterialStateProperty.all(const Color(0xFFEEC07B)),
          ),
          child: const Row(
            children: [
              Icon(Icons.delete, color: Color(0xFFEEC07B)),
              SizedBox(width: 8),
              Text('Delete', style: TextStyle(fontSize: 17)),
            ],
          ),
        ),
      ],
    );
  }

  Future<bool> _showDeleteConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this task?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    ) ?? false;
  }
}
