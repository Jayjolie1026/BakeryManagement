import 'package:flutter/material.dart';
import 'recipeItemClass.dart';
import 'recipeAPI.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter/material.dart';

const Map<int, String> productImages = {
  12: 'assets/sourdough.jpg',
  13: 'assets/choclatechip.jpg',
  14: 'assets/buttercroissant.jpg',
  15: 'assets/blueberrymuffins.jpg',
  16: 'assets/cinnaon.jpg',
  17: 'assets/frecnh.jpg',
  18: 'assets/lemon.jpg',
  19: 'assets/eclair.jpg',
  20: 'assets/pie.jpg',
  21: 'assets/vanilla.jpg',
  22: 'assets/pie.jpg',
  23: 'assets/almond.jpg',
  24: 'assets/raspberry.jpg',
  25: 'assets/brownies.jpg',
  26: 'assets/macarons.jpg',
};

class AddRecipePage extends StatefulWidget {
  const AddRecipePage({super.key});

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


class DetailedRecipePage extends StatefulWidget {
  final String recipeName;
  final int recipeID;

  const DetailedRecipePage({required this.recipeName, required this.recipeID, super.key});

  @override
  _DetailedRecipePageState createState() => _DetailedRecipePageState();
}

class _DetailedRecipePageState extends State<DetailedRecipePage> {
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0D1A0), // Same background as ProductPage
      body: Column(
        children: [
          // Recipe title in big letters (like in baked goods)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              widget.recipeName, // Recipe name as a header
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6D3200), // Same dark brown color
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // Image below the title, above instructions
          const SizedBox(height: 10),
          Expanded(
            child: FutureBuilder<List<Item>>(
              future: RecipeApi.getItems(searchQuery),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  final items = snapshot.data!;
                  final recipe = items.where((item) => item.recipeID == widget.recipeID).toList();
                  if (recipe.isEmpty) {
                    return const Center(child: Text('Recipe not found'));
                  }

                  final item = recipe.first; // The selected recipe

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(
                          productImages[item.productID] ?? 'assets/bagel3.jpg', // Dynamic image based on recipeID, default is bagel
                          width: double.infinity,
                          height: 250, // Image height
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Ingredients',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6D3200),
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (item.ingredients.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: item.ingredients.map<Widget>((ingredient) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Text(
                                  '- ${ingredient.quantity} of ${ingredient.name}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Color(0xFF6D3200),
                                  ),
                                ),
                              );
                            }).toList(),
                          )
                        else
                          const Text(
                            'No ingredients available',
                            style: TextStyle(
                              fontSize: 18,
                              color: Color(0xFF6D3200),
                            ),
                          ),
                        const SizedBox(height: 20),
                        const Text(
                          'Directions',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6D3200),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          item.steps.replaceAll('\\n', '\n'),
                          style: const TextStyle(
                            fontSize: 18,
                            color: Color(0xFF6D3200),
                          ),
                        ),
                        const SizedBox(height: 80), // Extra space before the bottom buttons
                      ],
                    ),
                  );
                } else {
                  return const Center(child: Text('No data found'));
                }
              },
            ),
          ),
          // Fixed Update and Back buttons at the bottom
          FutureBuilder<List<Item>>(
            future: RecipeApi.getItems(searchQuery),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                final item = snapshot.data!.firstWhere((item) => item.recipeID == widget.recipeID);

                return Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF0D1A0), // Same background as ProductPage
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26, // Slight shadow to separate from content
                        blurRadius: 5.0,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context); // Go back to the previous page
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6D3200), // Same button color
                          foregroundColor: const Color(0xFFF0D1A0), // Same text color
                        ),
                        child: const Text('Back'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          // Open the recipe update dialog
                          await showRecipeUpdateDialog(
                            context,
                            item, // Pass the current recipe item
                            (updatedRecipe) {
                              setState(() {
                                // Handle updated recipe
                              });
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6D3200), // Same button color
                          foregroundColor: const Color(0xFFF0D1A0), // Same text color
                        ),
                        child: const Text('Update Recipe'),
                      ),
                    ],
                  ),
                );
              } else {
                return const SizedBox.shrink(); // Avoid rendering buttons until data is ready
              }
            },
          ),
        ],
      ),
    );
  }
}





Future<void> showRecipeUpdateDialog(BuildContext context, Item recipe, ValueChanged<Item> onRecipeUpdated) async {
  TextEditingController nameController = TextEditingController(text: recipe.name);
  TextEditingController stepsController = TextEditingController(text: recipe.steps);
  TextEditingController ingredientsController = TextEditingController(text: recipe.ingredients.join(", "));

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Update Recipe'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Editable Fields for Recipe
              TextField(
                controller: nameController,
                style: const TextStyle(color: Color(0xFF6D3200)),
                decoration: const InputDecoration(
                  labelText: 'Name', 
                  labelStyle: TextStyle(color: Color(0xFF6D3200)),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF6D3200)),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF6D3200)),
                  ),
                ),
              ),
              TextField(
                controller: ingredientsController,
                style: const TextStyle(color: Color(0xFF6D3200)),
                decoration: const InputDecoration(
                  labelText: 'Ingredients (comma-separated)', 
                  labelStyle: TextStyle(color: Color(0xFF6D3200)),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF6D3200)),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF6D3200)),
                  ),
                ),
              ),
              TextField(
                controller: stepsController,
                style: const TextStyle(color: Color(0xFF6D3200)),
                decoration: const InputDecoration(
                  labelText: 'Steps', 
                  labelStyle: TextStyle(color: Color(0xFF6D3200)),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF6D3200)),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF6D3200)),
                  ),
                ),
                maxLines: 5, // Allow multiline for recipe steps
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog without changes
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Update the recipe with new values
              final updatedRecipe = Item(
                recipeID: recipe.recipeID, // Keep the same recipe ID
                name: nameController.text,
                steps: stepsController.text,
                productID: recipe.productID,
                ingredients: ingredientsController.text.split(',').map((ingredientString) {
                  // Split each string by ':' to get ingredientID, name, and quantity
                final parts = ingredientString.split(':');

                if (parts.length == 3) {
                  return Ingredient(
                    ingredientID: int.parse(parts[0].trim()), // Convert ingredientID to int
                    name: parts[1].trim(),
                    quantity: int.parse(parts[2].trim()), // Assuming quantity is a double
                  );
                } else {
                  throw Exception('Invalid ingredient format');
                }
                }).toList(),  // Convert back to a list
                            );

              // Call the update callback
              onRecipeUpdated(updatedRecipe);

              // Close the dialog
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6D3200),
              foregroundColor: const Color(0xFFF0d1a0),
            ),
            child: const Text('Update'),
          ),
        ],
      );
    }
  );
}


// // Create a widget to display the data
// class RecipeListPage extends StatelessWidget {
//   final String searchQuery;

//   RecipeListPage({required this.searchQuery});
//   /*
//   final String recipeName;
//   final int recipeID;

//   const RecipeListPage({required this.recipeName, required this.recipeID, Key? key}) : super(key: key);
//   */
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Recipe List'),
//       ),
//       body: FutureBuilder<List<Item>>(
//         future: RecipeApi.getItems(searchQuery),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           } else if (snapshot.hasData) {
//             final items = snapshot.data!;

//             return ListView.builder(
//               itemCount: items.length,
//               itemBuilder: (context, index) {
//                 final item = items[index];

//                 return Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//                   child: Container(
//                     decoration: BoxDecoration(
//                       border: Border.all(color: Colors.grey.shade300),
//                       borderRadius: BorderRadius.circular(8),
//                       color: Colors.white,
//                     ),
//                     child: Column(
//                       children: [
//                         ListTile(
//                           title: Text(item.name, style: TextStyle(fontWeight: FontWeight.bold)),
//                           subtitle: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text('Product ID: ${item.productID}'),
//                               Text('Steps: ${item.steps}'),
//                             ],
//                           ),
//                         ),
//                         const Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 16),
//                           child: Divider(), // Adds a divider line between sections
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.all(16),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               const Text(
//                                 'Ingredients:',
//                                 style: TextStyle(fontWeight: FontWeight.bold),
//                               ),
//                               const SizedBox(height: 8),
//                               ...item.ingredients.map((ingredient) {
//                                 return ListTile(
//                                   contentPadding: EdgeInsets.zero,
//                                   title: Text(ingredient.name),
//                                   subtitle: Text('Quantity: ${ingredient.quantity}g'),
//                                 );
//                               }).toList(),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             );
//           } else {
//             return const Center(child: Text('No data found'));
//           }
//         },
//       ),
//     );
//   }
// }
