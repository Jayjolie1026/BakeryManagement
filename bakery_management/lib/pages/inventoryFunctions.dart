import 'package:flutter/material.dart';
import 'inventoryItemClass.dart';
import 'inventoryAPI.dart';

// Function to show a dialog for adding a new ingredient
void showAddIngredientDialog(BuildContext context, VoidCallback onItemAdded) {
  final nameController = TextEditingController();
  final notesController = TextEditingController();
  final quantityController = TextEditingController();
  final maxAmountController = TextEditingController();
  final reorderAmountController = TextEditingController();
  final minAmountController = TextEditingController();
  final costController = TextEditingController();
  // final createDateTimeController = TextEditingController();
  // final expireDateTimeController = TextEditingController();

  // Future<void> _selectDate(BuildContext context) async {
  //   final DateTime? picked = await showDatePicker(
  //     context: context,
  //     initialDate: DateTime.now(),
  //     firstDate: DateTime(2000),
  //     lastDate: DateTime(2100),
  //   );
  //
  //   if (picked != null) {
  //     createDateTimeController.text = picked.toIso8601String();
  //   }
  // }

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
              // TextField(
              //   controller: createDateTimeController,
              //   style: const TextStyle(color: Color(0xFF6D3200)),
              //   decoration: const InputDecoration(labelText: 'Create Date',
              //     labelStyle: TextStyle(color: Color(0xFF6D3200)),
              //     focusedBorder: UnderlineInputBorder(
              //       borderSide: BorderSide(color: Color(0xFF6D3200)), // Focused border color
              //     ),
              //     enabledBorder: UnderlineInputBorder(
              //       borderSide: BorderSide(color: Color(0xFF6D3200)), // Enabled border color
              //     ),
              //   ),
              //   readOnly: true,
              //   onTap: () => _selectDate(context),
              // ),
              // TextField(
              //   controller: expireDateTimeController,
              //   style: const TextStyle(color: Color(0xFF6D3200)),
              //   decoration: const InputDecoration(labelText: 'Expiration Data',
              //     labelStyle: TextStyle(color: Color(0xFF6D3200)),
              //     focusedBorder: UnderlineInputBorder(
              //       borderSide: BorderSide(color: Color(0xFF6D3200)), // Focused border color
              //     ),
              //     enabledBorder: UnderlineInputBorder(
              //       borderSide: BorderSide(color: Color(0xFF6D3200)), // Enabled border color
              //     ),
              //   ),
              //   readOnly: true,
              //   onTap: () => _selectDate(context),
              // ),
            ],
          ),
        )
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
              // createDateTime: DateTime.tryParse(createDateTimeController.text) ?? DateTime.now(),
              // expireDateTime: DateTime.tryParse(expireDateTimeController.text) ?? DateTime.now(),
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