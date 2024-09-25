import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'inventoryItemClass.dart';

// Adds ingredient to database, then opens dialog to add the item to inventory
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

            if (response.statusCode == 201) {
              // Parse the response body to extract the ingredient_id
              final Map<String, dynamic> responseData = jsonDecode(response.body);
              print('Response data: $responseData'); // Debugging step
              final int ingredientID = responseData['ingredientID']; // Assume the server returns the ID

              Navigator.of(context).pop(); // Close the ingredient dialog
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ingredient item added')));

              // Now show the inventory item dialog
              await showAddInventoryItemDialog(context, ingredientID);

            } else {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add ingredient item')));
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
                'notes': notesController.text,
                'create_datetime': createDateTime.toIso8601String(),
                'expire_datetime': expireDateTime.toIso8601String(),
              }),
              headers: {"Content-Type": "application/json"},
            );
            print('Response: ${response.body}');

            if (response.statusCode == 201) {
              Navigator.of(context).pop(); // Close the inventory dialog
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Inventory item added')));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add inventory item')));
              throw Exception('Failed to add inventory item: ${response.body}');
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
/*
inventory: ingID, quantity, notes, cost, create, expire, measurement by entryID
ingredient: name, description, category, measurement, maxAmt, reorderAmt, minAmt, vendorID
*/
void showInventoryAndIngredientUpdateDialog(BuildContext context, Item item, ValueChanged<Item> onItemUpdated) {
  final nameController = TextEditingController(text: item.ingredientName);
  final descriptionController = TextEditingController();
  final notesController = TextEditingController(text: item.notes);
  final costController = TextEditingController(text: item.cost.toString());
  final quantityController = TextEditingController(text: item.quantity.toString());
  final categoryController = TextEditingController();
  final measurementController = TextEditingController(text: item.measurement);
  final maxAmountController = TextEditingController(text: item.maxAmount.toString());
  final reorderAmountController = TextEditingController(text: item.reorderAmount.toString());
  final minAmountController = TextEditingController(text: item.minAmount.toString());
  final vendorIDController = TextEditingController(text: item.vendorID.toString());
  DateTime createDateTime = item.createDateTime;
  DateTime expireDateTime = item.expireDateTime;

  // DatePicker function
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
    builder: (context) {
      return AlertDialog(
        backgroundColor: const Color(0xFFEEC07B), // Example color
        titleTextStyle: const TextStyle(color: Color(0xFF6D3200),
            fontFamily: 'MyFont',
            fontSize: 24.0),
        title: const Text('Update Item'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: TextField(
                  controller: nameController,
                  style: const TextStyle(color: Color(0xFF6D3200)),
                  decoration: const InputDecoration(labelText: 'Name',
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
                  keyboardType: TextInputType.number,
                ),
              ),
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
                  keyboardType: TextInputType.number,
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
                  decoration: const InputDecoration(labelText: 'Vendor',
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
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF6D3200), // Text color
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                // Make both API calls in parallel
                final responses = await Future.wait([
                  // Inventory update API call
                  http.put(
                    Uri.parse('https://bakerymanagement-efgmhebnd5aggagn.eastus-01.azurewebsites.net/inventory/${item.entryID}'),
                    body: jsonEncode({
                      'ingredient_id': item.ingredientID,
                      'quantity': int.tryParse(quantityController.text),
                      'notes': notesController.text,
                      'cost': double.tryParse(costController.text),
                      'create_datetime': createDateTime.toIso8601String(),
                      'expire_datetime': expireDateTime.toIso8601String(),
                      'measurements': measurementController.text,
                    }),
                    headers: {"Content-Type": "application/json"},
                  ),

                  // Ingredient update API call
                  http.put(
                    Uri.parse('https://bakerymanagement-efgmhebnd5aggagn.eastus-01.azurewebsites.net/ingredients/${item.ingredientID}'),
                    body: jsonEncode({
                      'ingredientID': item.ingredientID,
                      'name': nameController.text,
                      'description': descriptionController.text,
                      'category': categoryController.text,
                      'measurement': measurementController.text,
                      'maxAmount': double.tryParse(maxAmountController.text),
                      'reorderAmount': double.tryParse(reorderAmountController.text),
                      'minAmount': double.tryParse(minAmountController.text),
                      'vendorID': int.tryParse(vendorIDController.text),
                    }),
                    headers: {"Content-Type": "application/json"},
                  ),
                ]);

                final inventoryResponse = responses[0];
                final ingredientResponse = responses[1];

                // Handle inventory response
                if (inventoryResponse.statusCode != 200) {
                  throw Exception('Failed to update inventory: ${inventoryResponse.body}');
                }

                // Handle ingredient response
                if (ingredientResponse.statusCode != 200) {
                  throw Exception('Failed to update ingredient: ${ingredientResponse.body}');
                }

                // Success messages for both
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Inventory and ingredient updated successfully')));

                // Close dialog after success
                Navigator.of(context).pop();
              } catch (e) {
                // Show error message
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6D3200), // Background color of the button
              foregroundColor: const Color(0xFFF0d1a0), // Text color of the button
            ),
            child: const Text('Save Changes'),
          ),
        ],
      );
    },
  );
}

// Function to format dates
String formatDate(DateTime dateTime) {
  final day = dateTime.day.toString().padLeft(2, '0');
  final month = dateTime.month.toString().padLeft(2, '0');
  final year = dateTime.year.toString();

  return '$year-$month-$day'; // Format as YYYY-MM-DD
}

// temporary code to delete item
// Future<void> showDeleteIngredientDialog(BuildContext context, Function onDelete) {
//   final TextEditingController ingredientController = TextEditingController();
//
//   return showDialog<void>(
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         title: const Text('Delete Ingredient'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: <Widget>[
//             const Text('Enter the name of the ingredient you want to delete:'),
//             const SizedBox(height: 10),
//             TextField(
//               controller: ingredientController,
//               decoration: const InputDecoration(
//                 border: OutlineInputBorder(),
//                 labelText: 'Ingredient Name',
//               ),
//             ),
//           ],
//         ),
//         actions: <Widget>[
//           TextButton(
//             child: const Text('Cancel'),
//             onPressed: () {
//               Navigator.of(context).pop(); // Close the dialog
//             },
//           ),
//           TextButton(
//             child: const Text('Delete'),
//             onPressed: () async {
//               final String ingredientName = Uri.encodeComponent(ingredientController.text.trim());
//
//               if (ingredientName.isNotEmpty) {
//                 final invResponse = await http.delete(
//                   Uri.parse('https://bakerymanagement-efgmhebnd5aggagn.eastus-01.azurewebsites.net/inventory/name/$ingredientName'),
//                 );
//
//                 if (invResponse.statusCode != 200) {
//                   print('Failed to delete inventory item');
//                 } else {
//                   print('Inventory item deleted successfully');
//                 }
//
//                 final ingResponse = await http.delete(
//                   Uri.parse('https://bakerymanagement-efgmhebnd5aggagn.eastus-01.azurewebsites.net/ingredients/$ingredientName'),
//                 );
//
//                 if (ingResponse.statusCode != 200) {
//                   print('Failed to delete ingredient');
//                 } else {
//                   print('Ingredient deleted successfully');
//                 }
//
//                 Navigator.of(context).pop(); // Close the dialog after deleting
//               } else {
//                 // Optionally show an error message if the input is empty
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text('Please enter an ingredient name')),
//                 );
//               }
//             },
//           )
//         ],
//       );
//     },
//   );
// }
