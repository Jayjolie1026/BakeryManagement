import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'inventoryItemClass.dart';

// Adds ingredient to database, then opens dialog to add the item to inventory
Future<void> showAddIngredientAndInventoryDialog(BuildContext context, VoidCallback onItemAdded) async {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final notesController = TextEditingController();
  final costController = TextEditingController();
  final quantityController = TextEditingController();
  final categoryController = TextEditingController();
  final ingMeasurementController = TextEditingController();
  final invMeasurementController = TextEditingController();
  final maxAmountController = TextEditingController();
  final reorderAmountController = TextEditingController();
  final minAmountController = TextEditingController();
  final vendorIDController = TextEditingController();
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
      title: const Text('Add New Item'),
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
                decoration: const InputDecoration(labelText: 'Ingredient Description',
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
                decoration: const InputDecoration(labelText: 'Inventory Notes',
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
              ),
            ),
            Flexible(
              child: TextField(
                controller: ingMeasurementController,
                style: const TextStyle(color: Color(0xFF6D3200)),
                decoration: const InputDecoration(labelText: 'Ingredient Measurement',
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
                controller: invMeasurementController,
                style: const TextStyle(color: Color(0xFF6D3200)),
                decoration: const InputDecoration(labelText: 'Inventory Measurement',
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
            try {
              // Create new ingredient instance
              // Prepare ingredient JSON body
              final ingredientBody = jsonEncode({
                'name': nameController.text,
                'description': descriptionController.text,
                'category': categoryController.text,
                'measurement': ingMeasurementController.text,
                'maxAmount': double.tryParse(maxAmountController.text),
                'reorderAmount': double.tryParse(reorderAmountController.text),
                'minAmount': double.tryParse(minAmountController.text),
                'vendorID': int.tryParse(vendorIDController.text),
              });

              // Print ingredient body before sending request
              print('Sending ingredient request with body: $ingredientBody');

              // Send ingredient POST request
              final ingredientResponse = await http.post(
                Uri.parse('https://bakerymanagement-efgmhebnd5aggagn.eastus-01.azurewebsites.net/ingredients'),
                body: ingredientBody,
                headers: {"Content-Type": "application/json"},
              );

              if (ingredientResponse.statusCode == 201) {
                // Parse the response body to extract the ingredient_id
                final Map<String, dynamic> ingredientData = jsonDecode(ingredientResponse.body);
                final int ingredientID = ingredientData['ingredientID'];

                // Now create the inventory instance using the ingredientID
                // Prepare inventory JSON body
                final inventoryBody = jsonEncode({
                  'ingredient_id': ingredientID,
                  'quantity': int.tryParse(quantityController.text),
                  'cost': double.tryParse(costController.text),
                  'notes': notesController.text,
                  'measurement': invMeasurementController.text,
                  'create_datetime': createDateTime.toIso8601String(),
                  'expire_datetime': expireDateTime.toIso8601String(),
                });

                // Print inventory body before sending request
                print('Sending inventory request with body: $inventoryBody');

                // Send inventory POST request
                final inventoryResponse = await http.post(
                  Uri.parse('https://bakerymanagement-efgmhebnd5aggagn.eastus-01.azurewebsites.net/inventory'),
                  body: inventoryBody,
                  headers: {"Content-Type": "application/json"},
                );

                if (inventoryResponse.statusCode == 201) {
                  Navigator.of(context).pop(); // Close the dialogs
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Item added')),
                  );
                } else {
                  print('Failed to add inventory item: ${inventoryResponse.body}');
                }
              } else {
                print('Failed to add ingredient: ${ingredientResponse.body}');
              }
            } catch (e) {
              print('Error: $e');
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

void showInventoryAndIngredientUpdateDialog(BuildContext context, Item item, ValueChanged<Item> onItemUpdated) {
  final nameController = TextEditingController(text: item.ingredientName);
  final descriptionController = TextEditingController(text: item.description);
  final notesController = TextEditingController(text: item.notes);
  final costController = TextEditingController(text: item.cost.toString());
  final quantityController = TextEditingController(text: item.quantity.toString());
  final categoryController = TextEditingController(text: item.category);
  final invMeasurementController = TextEditingController(text: item.invMeasurement);
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
                  decoration: const InputDecoration(labelText: 'Ingredient Description',
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
                  decoration: const InputDecoration(labelText: 'Inventory Notes',
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
                  controller: invMeasurementController,
                  style: const TextStyle(color: Color(0xFF6D3200)),
                  decoration: const InputDecoration(labelText: 'Stock Measurement',
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
                print(item.entryID);
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
                      'measurement': invMeasurementController.text,
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

                final updatedItem = Item(
                  ingredientID: item.ingredientID,
                  ingredientName: nameController.text,
                  description: descriptionController.text,
                  category: categoryController.text,
                  maxAmount: double.tryParse(maxAmountController.text) ?? 0.0,
                  reorderAmount: double.tryParse(reorderAmountController.text) ?? 0.0,
                  minAmount: double.tryParse(minAmountController.text) ?? 0.0,
                  vendorID: int.tryParse(vendorIDController.text) ?? 0,
                  quantity: int.tryParse(quantityController.text) ?? 0,
                  cost: double.tryParse(costController.text) ?? 0,
                  notes: notesController.text,
                  createDateTime: createDateTime,
                  invMeasurement: invMeasurementController.text,
                  expireDateTime: expireDateTime,
                  // Add any other necessary fields from the response
                );
                
                // Call the callback to update the item
                onItemUpdated(updatedItem);

                // Success messages for both
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Item updated successfully')));

                // Close dialog after success
                Navigator.pop(context,updatedItem );
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
