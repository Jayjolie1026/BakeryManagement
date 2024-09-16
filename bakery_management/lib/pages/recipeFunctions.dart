import 'package:flutter/material.dart';
import 'recipeItemClass.dart';
import 'recipeAPI.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter/material.dart';

class AddRecipePage extends StatefulWidget {
  @override
  _AddRecipePageState createState() => _AddRecipePageState();
}

class _AddRecipePageState extends State<AddRecipePage> {
  int recipeID = 0;
  String name = '';
  String steps = '';
  int productID = 0;
  List<Ingredient> ingredients = [];

  // Controllers for ingredient input fields
  final TextEditingController ingredientNameController = TextEditingController();
  final TextEditingController ingredientQuantityController = TextEditingController();

  void addIngredient() {
    setState(() {
      final ingredientName = ingredientNameController.text;
      final ingredientQuantity = int.tryParse(ingredientQuantityController.text) ?? 0;

      // Add new ingredient to the list
      ingredients.add(
        Ingredient(
          ingredientID: ingredients.length + 1, // Temporary ID, adjust as needed
          name: ingredientName,
          quantity: ingredientQuantity,
        ),
      );

      // Clear input fields
      ingredientNameController.clear();
      ingredientQuantityController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Recipe Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Recipe ID Input
              TextField(
                decoration: const InputDecoration(labelText: 'Recipe ID'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    recipeID = int.tryParse(value) ?? 0;
                  });
                },
              ),
              const SizedBox(height: 10),
              // Name Input
              TextField(
                decoration: const InputDecoration(labelText: 'Item Name'),
                onChanged: (value) {
                  setState(() {
                    name = value;
                  });
                },
              ),
              const SizedBox(height: 10),
              // Steps Input
              TextField(
                decoration: const InputDecoration(labelText: 'Steps'),
                onChanged: (value) {
                  setState(() {
                    steps = value;
                  });
                },
              ),
              const SizedBox(height: 10),
              // Product ID Input
              TextField(
                decoration: const InputDecoration(labelText: 'Product ID'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    productID = int.tryParse(value) ?? 0;
                  });
                },
              ),
              const SizedBox(height: 20),
              // Section for adding ingredients
              const Text(
                'Add Ingredients',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: ingredientNameController,
                decoration: const InputDecoration(labelText: 'Ingredient Name'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: ingredientQuantityController,
                decoration: const InputDecoration(labelText: 'Ingredient Quantity'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: addIngredient,
                child: const Text('Add Ingredient'),
              ),
              const SizedBox(height: 20),
              // Display added ingredients
              const Text(
                'Ingredients List',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: ingredients.length,
                itemBuilder: (context, index) {
                  final ingredient = ingredients[index];
                  return ListTile(
                    title: Text('${ingredient.name} - ${ingredient.quantity}'),
                  );
                },
              ),
              const SizedBox(height: 20),
              // Buttons: Cancel and Add
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    child: const Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  ElevatedButton(
                    child: const Text('Add Recipe'),
                    onPressed: () async {
                      try {
                        addRecipe(recipeID, name, steps, productID, ingredients); // Call the addRecipe API function
                        await addRecipe(
                          recipeID,
                          name,
                          steps,
                          productID,
                          ingredients, // Pass the ingredients list
                        );
                        Navigator.of(context).pop(); // Go back after adding the recipe
                      } catch (e) {
                        print('Error adding recipe: $e');
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Example function to handle recipe addition
  Future<void> addRecipe(
    int recipeID,
    String name,
    String steps,
    int productID,
    List<Ingredient> ingredients,
  ) async {
    final url = Uri.parse('https://bakerymanagement-efgmhebnd5aggagn.eastus-01.azurewebsites.net/recipes');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'RecipeID': recipeID,
        'Name': name,
        'Steps': steps,
        'ProductID': productID,
        'Ingredients': ingredients.map((ingredient) {
          return {
            'IngredientID': ingredient.ingredientID,
            'Name': ingredient.name,
            'Quantity': ingredient.quantity,
          };
        }).toList(),
      }),
    );

    if (response.statusCode == 201) {
      print('Recipe added successfully');
    } else {
      throw Exception('Failed to add recipe: ${response.body}');
    }
  }
}


class DetailedRecipePage extends StatelessWidget {
  final String recipeName;
  final int recipeID;

  const DetailedRecipePage({required this.recipeName, required this.recipeID, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bagels Recipe and Directions'),
      ),
      body: SingleChildScrollView( // Use SingleChildScrollView to handle scrolling if content is long
        padding: const EdgeInsets.all(16.0), // Add padding to the body
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Align content to the left
          children: [
            // Image section
            Image.asset(
              'assets/bagel3.jpg', // Replace with your image path
              width: double.infinity, // Make the image take up full width
              height: 200, // Set a fixed height for the image
              fit: BoxFit.cover, // Make the image cover the available space
            ),
            const SizedBox(height: 20), // Space between the image and the headers

            // Ingredients header
            const Text(
              'Ingredients',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10), // Space between the header and content

            // Placeholder for ingredients (You can populate this later with API data)
            const Text(
              'Loading ingredients...', // Placeholder text
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20), // Space between ingredients and directions

            // Directions header
            const Text(
              'Directions',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10), // Space between the header and content

            // Placeholder for directions (You can populate this later with API data)
            const Text(
              'Loading directions...', // Placeholder text
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}

// Create a widget to display the data
class RecipeListPage extends StatelessWidget {
  final String searchQuery;

  RecipeListPage({required this.searchQuery});
  /*
  final String recipeName;
  final int recipeID;

  const RecipeListPage({required this.recipeName, required this.recipeID, Key? key}) : super(key: key);
  */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe List'),
      ),
      body: FutureBuilder<List<Item>>(
        future: RecipeApi.getItems(searchQuery),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final items = snapshot.data!;

            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          title: Text(item.name, style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Product ID: ${item.productID}'),
                              Text('Steps: ${item.steps}'),
                            ],
                          ),
                        ),
                        const Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Divider(), // Adds a divider line between sections
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Ingredients:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              ...item.ingredients.map((ingredient) {
                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(ingredient.name),
                                  subtitle: Text('Quantity: ${ingredient.quantity}g'),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('No data found'));
          }
        },
      ),
    );
  }
}
