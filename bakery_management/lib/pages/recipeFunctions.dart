import 'package:flutter/material.dart';
import 'recipeItemClass.dart';
import 'recipeAPI.dart';

// Function to show a dialog for adding a new item
void showAddRecipeDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      int recipeID = 0;
      String name = '';
      String steps = '';
      int productID = 0;
      int ingredientID = 0;
      String ingredientName = '';
      int ingredientQuantity = 0;

      return AlertDialog(
        title: const Text('Add Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Recipe ID'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                recipeID = int.tryParse(value) ?? 0;
              },
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Item Name'),
              onChanged: (value) {
                name = value;
              },
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Steps'),
              onChanged: (value) {
                steps = value;
              },
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Product ID'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                productID = int.tryParse(value) ?? 0;
              },
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Ingredient ID'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                ingredientID = int.tryParse(value) ?? 0;
              },
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Ingredient Name'),
              onChanged: (value) {
                ingredientName = value;
              },
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Ingredient Quantity'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                ingredientQuantity = int.tryParse(value) ?? 0;
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
                await addRecipe(
                  recipeID,
                  name,
                  steps,
                  productID,
                  ingredientID,
                  ingredientName,
                  ingredientQuantity,
                );
                Navigator.of(context).pop();
                // Optionally, refresh the item list
              } catch (e) {
                print('Error adding item: $e');
              }
            },
          ),
        ],
      );
    },
  );
}
