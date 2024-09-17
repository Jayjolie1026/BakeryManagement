import 'dart:math';

import 'package:flutter/material.dart';
import 'inventoryItemClass.dart';
import 'inventoryAPI.dart';
import 'package:intl/intl.dart';

// Function to show a dialog for adding a new ingredient
void showAddIngredientDialog(BuildContext context, VoidCallback onItemAdded) {
  final nameController = TextEditingController();
  final notesController = TextEditingController();
  final quantityController = TextEditingController();
  final maxAmountController = TextEditingController();
  final reorderAmountController = TextEditingController();
  final minAmountController = TextEditingController();
  final costController = TextEditingController();

  // ensure its initialized
  DateTime createDateTime = DateTime.now();
  DateTime expireDateTime = DateTime.now().add(const Duration(days: 7));

  void _selectDate(BuildContext context, bool isCreateDate) async {
    DateTime now = DateTime.now();
    DateTime initialDate = isCreateDate ? (createDateTime ?? now) : (expireDateTime ?? now);
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null) {
      TimeOfDay initialTime = isCreateDate ? (createDateTime != null ? TimeOfDay.fromDateTime(createDateTime!) : TimeOfDay.now()) : (expireDateTime != null ? TimeOfDay.fromDateTime(expireDateTime!) : TimeOfDay.now());
      TimeOfDay? selectedTime = await showTimePicker(
        context: context,
        initialTime: initialTime,
      );

      if (selectedTime != null) {
        DateTime selectedDateTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );

        if (isCreateDate) {
          createDateTime = selectedDateTime;
        } else {
          expireDateTime = selectedDateTime;
        }
      }
    }
  }

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: const Color(0xFFF0d1a0), // Background color of the dialog
      titleTextStyle: const TextStyle(color: Color(0xFF6D3200)),
      title: const Text('Add New Item'),
      content: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(color: Color(0xFF6D3200)),
                decoration: const InputDecoration(labelText: 'Ingredient Name',
                  labelStyle: TextStyle(color: Color(0xFF6D3200)),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF6D3200)), // Focused border color
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF6D3200)), // Enabled border color
                  ),
                ),
              ),
              TextField(
                controller: notesController,
                style: const TextStyle(color: Color(0xFF6D3200)),
                decoration: const InputDecoration(labelText: 'Notes',
                  labelStyle: TextStyle(color: Color(0xFF6D3200)),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF6D3200)), // Focused border color
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF6D3200)), // Enabled border color
                  ),
                ),
              ),
              TextField(
                controller: quantityController,
                style: const TextStyle(color: Color(0xFF6D3200)),
                decoration: const InputDecoration(labelText: 'Quantity',
                  labelStyle: TextStyle(color: Color(0xFF6D3200)),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF6D3200)), // Focused border color
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF6D3200)), // Enabled border color
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: maxAmountController,
                style: const TextStyle(color: Color(0xFF6D3200)),
                decoration: const InputDecoration(labelText: 'Max Amount',
                  labelStyle: TextStyle(color: Color(0xFF6D3200)),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF6D3200)), // Focused border color
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF6D3200)), // Enabled border color
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: reorderAmountController,
                style: const TextStyle(color: Color(0xFF6D3200)),
                decoration: const InputDecoration(labelText: 'Reorder Amount',
                  labelStyle: TextStyle(color: Color(0xFF6D3200)),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF6D3200)), // Focused border color
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF6D3200)), // Enabled border color
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: minAmountController,
                style: const TextStyle(color: Color(0xFF6D3200)),
                decoration: const InputDecoration(labelText: 'Min Amount',
                  labelStyle: TextStyle(color: Color(0xFF6D3200)),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF6D3200)), // Focused border color
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF6D3200)), // Enabled border color
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: costController,
                style: const TextStyle(color: Color(0xFF6D3200)),
                decoration: const InputDecoration(labelText: 'Cost',
                  labelStyle: TextStyle(color: Color(0xFF6D3200)),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF6D3200)), // Focused border color
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF6D3200)), // Enabled border color
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              Container(
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Color(0xFF6D3200),
                          side: const BorderSide(
                            color: Color(0xFF6D3200), // Border color
                            width: 1.5, // Border width
                          ),
                        ),
                        onPressed: () => _selectDate(context, true),
                        child: const Text('Created'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF6D3200),
                          side: const BorderSide(
                            color: Color(0xFF6D3200), // Border color
                            width: 1.5, // Border width
                          ),
                        ),
                        onPressed: () => _selectDate(context, false),
                        child: const Text('Expires'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            backgroundColor: const Color(0xFF6D3200), // Text color of the button
            foregroundColor: const Color(0xFFF0d1a0),
          ),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            // Create a new Item instance
            final item = Item(
              entryID: 0, // You can adjust this depending on your API requirements
              ingredientName: nameController.text,
              notes: notesController.text,
              quantity: int.tryParse(quantityController.text) ?? 0,
              maxAmount: double.tryParse(maxAmountController.text) ?? 0,
              reorderAmount: double.tryParse(reorderAmountController.text) ?? 0,
              minAmount: double.tryParse(minAmountController.text) ?? 0,
              cost: double.tryParse(costController.text) ?? 0.0,
              createDateTime: createDateTime,
              expireDateTime: expireDateTime,
            );

            // Add the new product using the API
            await InventoryApi.addItem(item);
            onItemAdded(); // Refresh the product list

            // Close the dialog
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6D3200), // Background color of the button
            foregroundColor: const Color(0xFFF0d1a0), // Text color of the button
          ),
          child: const Text('Add'),
        ),
      ],
    ),
  );
}

// Function to format dates
String formatDate(DateTime dateTime) {
  final day = dateTime.day.toString().padLeft(2, '0');
  final month = dateTime.month.toString().padLeft(2, '0');
  final year = dateTime.year.toString();

  return '$year-$month-$day'; // Format as YYYY-MM-DD
}