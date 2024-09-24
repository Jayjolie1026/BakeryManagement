import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> showAddIngredientDialog(BuildContext context, VoidCallback onItemAdded) async {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final categoryController = TextEditingController();
  final measurementController = TextEditingController();
  final maxAmountController = TextEditingController();
  final reorderAmountController = TextEditingController();
  final minAmountController = TextEditingController();
  final vendorIDController = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      backgroundColor: const Color(0xFFF0d1a0), // Background color of the dialog
      titleTextStyle: const TextStyle(color: Color(0xFF6D3200)),
      title: const Text('Add New Ingredient'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: TextField(
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
            ),
            Flexible(
              child: TextField(
                controller: descriptionController,
                style: const TextStyle(color: Color(0xFF6D3200)),
                decoration: const InputDecoration(labelText: 'Description',
                  labelStyle: TextStyle(color: Color(0xFF6D3200)),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF6D3200)), // Focused border color
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF6D3200)), // Enabled border color
                  ),
                ),
              ),
            ),
            Flexible(
              child: TextField(
                controller: categoryController,
                style: const TextStyle(color: Color(0xFF6D3200)),
                decoration: const InputDecoration(labelText: 'Category',
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
            ),
            Flexible(
              child: TextField(
                controller: measurementController,
                style: const TextStyle(color: Color(0xFF6D3200)),
                decoration: const InputDecoration(labelText: 'Measurement',
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
            ),
            Flexible(
              child: TextField(
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
            ),
            Flexible(
              child: TextField(
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
            ),
            Flexible(
              child: TextField(
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
            ),
            Flexible(
              child: TextField(
                controller: vendorIDController,
                style: const TextStyle(color: Color(0xFF6D3200)),
                decoration: const InputDecoration(labelText: 'Vendor ID',
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
            ),
          ],
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
            // Create new ingredient instance
              final response = await http.post(
                Uri.parse('https://bakerymanagement-efgmhebnd5aggagn.eastus-01.azurewebsites.net/ingredients'),
                body: jsonEncode({
                  'name': nameController.text,
                  'description': descriptionController.text,
                  'category': categoryController.text,
                  'measurement': measurementController.text,
                  'maxAmount': double.tryParse(maxAmountController.text) ?? 0,
                  'reorderAmount': double.tryParse(reorderAmountController.text) ?? 0,
                  'minAmount': double.tryParse(minAmountController.text) ?? 0,
                  'vendorID': int.tryParse(vendorIDController.text) ?? 19,
                }),
                headers: {"Content-Type": "application/json"},
              );
              print('Request body: ${response.body}');


              // TODO: receive ingredient ID and pass it to showAddInventoryItemDialog
              if (response.statusCode == 201) {
                // Parse the response body to extract the ingredient_id
                final Map<String, dynamic> responseData = jsonDecode(response.body);
                print('Response data: $responseData'); // Debugging step
                final int ingredientID = responseData['ingredientID']; // Assume the server returns the ID

                Navigator.of(context).pop(); // Close the ingredient dialog
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ingredient item added')));

                // Now show the inventory item dialog
                await showAddInventoryItemDialog(context, ingredientID);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to add ingredient item')));
                throw Exception('Failed to add ingredient: ${response.body}');
              }
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

// TODO: make sure this works after getting ing ID
Future<void> showAddInventoryItemDialog(BuildContext context, int ingredientID) async {
  final quantityController = TextEditingController();
  final costController = TextEditingController();
  final notesController = TextEditingController();

  DateTime createDateTime = DateTime.now();
  DateTime expireDateTime = DateTime.now();

  void selectDate(BuildContext context, bool isCreateDate) async {
    DateTime initialDate = isCreateDate ? createDateTime : expireDateTime;

    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null) {
      // Set time to midnight (00:00:00) since you don't need a time selection
      DateTime selectedDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        0, // hour
        0, // minute
        0, // second
      );

      if (isCreateDate) {
        createDateTime = selectedDateTime;
      } else {
        expireDateTime = selectedDateTime;
      }
    }
  }


  showDialog(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      backgroundColor: const Color(0xFFF0d1a0), // Background color of the dialog
      titleTextStyle: const TextStyle(color: Color(0xFF6D3200)),
      title: const Text('Add Inventory Item'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: TextField(
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
              ),
            ),
            Flexible(
              child: TextField(
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
              ),
            ),
            Flexible(
              child: TextField(
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
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF6D3200),
                      side: const BorderSide(
                        color: Color(0xFF6D3200), // Border color
                        width: 1.5, // Border width
                      ),
                    ),
                    onPressed: () => selectDate(context, true),
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
                    onPressed: () => selectDate(context, false),
                    child: const Text('Expires'),
                  ),
                ),
              ],
            ),
          ],
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
            // Create new ingredient instance
            final response = await http.post(
              Uri.parse('https://bakerymanagement-efgmhebnd5aggagn.eastus-01.azurewebsites.net/inventory'),
              body: jsonEncode({
                'ingredient_id': ingredientID,
                'quantity': int.tryParse(quantityController.text) ?? 0,
                'cost': double.tryParse(costController.text) ?? 0,
                'notes': notesController.text ?? '',
                createDateTime: createDateTime.toIso8601String(),
                expireDateTime: expireDateTime.toIso8601String(),
              }),
              headers: {"Content-Type": "application/json"},
            );

            if (response.statusCode == 201) {
              Navigator.of(context).pop(); // Close the inventory dialog
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Inventory item added')));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to add inventory item')));
              throw Exception('Failed to add ingredient: ${response.body}');
            }

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