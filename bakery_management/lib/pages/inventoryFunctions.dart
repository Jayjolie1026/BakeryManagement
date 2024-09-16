import 'package:flutter/material.dart';
import 'inventoryItemClass.dart';
import 'inventoryAPI.dart';

// Function to check quantity vs reorder amount
void checkInventoryLevels(List<Item> items) {
  for (var item in items) {
    if (item.quantity < item.reorderAmount) {
      // Display a warning or alert
      print('Warning: ${item.ingredientName} is below the reorder amount!');
    }
  }
}

// Function to show a dialog for adding a new ingredient
void showAddIngredientDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      String ingredientName = '';
      String description = '';
      String category = '';
      String measurement = '';
      double maxAmount = 0.0;
      double reorderAmount = 0.0;
      double minAmount = 0.0;
      int vendorID = 0;

      return AlertDialog(
        title: const Text('Add Ingredient'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Ingredient Name'),
              onChanged: (value) {
                ingredientName = value;
              },
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Description'),
              onChanged: (value) {
                description = value;
              },
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Category'),
              onChanged: (value) {
                category = value;
              },
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Measurement'),
              onChanged: (value) {
                measurement = value;
              },
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Max Amount'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                maxAmount = double.tryParse(value) ?? 0.0;
              },
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Reorder Amount'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                reorderAmount = double.tryParse(value) ?? 0.0;
              },
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Min Amount'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                minAmount = double.tryParse(value) ?? 0.0;
              },
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Vendor ID'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                vendorID = int.tryParse(value) ?? 0;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          ElevatedButton(
            child: const Text('Add'),
            onPressed: () async {
              try {
                await addIngredient(
                  ingredientName,
                  description,
                  category,
                  measurement,
                  maxAmount,
                  reorderAmount,
                  minAmount,
                  vendorID,
                );
                Navigator.of(context).pop();
                // Optionally, refresh the inventory list
              } catch (e) {
                print('Error adding ingredient: $e');
              }
            },
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

// Function to show a dialog with item details
void showItemDetails(BuildContext context, Item item) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Center(
          child: Text(
            'Ingredients',
            style: TextStyle(color: Color.fromARGB(255, 97, 91, 77)),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Placeholder image at the top
            Image.network(
              'https://via.placeholder.com/150', // Placeholder image URL
              height: 150,
              width: 150,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 16),
            // Item details
            Text('Entry ID: ${item.entryID}'),
            Text('PO Number: ${item.entryID}'), // Assuming PO Number is same as Entry ID for now
            Text('Entry Date: ${formatDate(item.createDateTime)}'),
            Text('Expiration Date: ${formatDate(item.expireDateTime)}'),
            Text('Quantity: ${item.quantity}'),
            Text('Cost: \$${item.cost.toStringAsFixed(2)}'),
            Text('Notes: ${item.notes}'),
          ],
        ),
        actions: [
          // Container to add space between the buttons and the dialog edges
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Update button
                TextButton.icon(
                  icon: const Icon(Icons.update, color: Color.fromARGB(255, 97, 91, 77)), // Change icon color
                  label: const Text('Update', style: TextStyle(color: Color.fromARGB(255, 97, 91, 77))),
                  onPressed: () {
                    // Action for Update button
                  },
                ),
                // Vendor button
                TextButton.icon(
                  icon: const Icon(Icons.store, color: Color.fromARGB(255, 97, 91, 77)),
                  label: const Text('Vendor', style: TextStyle(color: Color.fromARGB(255, 97, 91, 77))),
                  onPressed: () {
                    // Action for Vendor button
                  },
                ),
              ],
            ),
          ),
        ],
      );
    },
  );
}

