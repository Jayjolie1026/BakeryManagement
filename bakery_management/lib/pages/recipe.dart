import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:bakery_management/pages/bakedgoods.dart';


// Item model for recipe items
class Item {
  final int recipeID;
  final int itemID;
  final String recipeName;
  final String steps;

  // Constructor
  Item({
    required this.recipeID,
    required this.itemID,
    required this.recipeName,
    required this.steps,
  });

  // Factory constructor to create an Item from a JSON object
  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      recipeID: json['RecipeID'] ?? 0,    // Default to 0 if null
      itemID: json['ItemID'] ?? 0,
      recipeName: json['RecipeName'] ?? '',
      steps: json['Steps'] ?? '',         // Default to empty string if null
    );
  }

  // Convert Item object to JSON format
  Map<String, dynamic> toJson() => {
        'RecipeID': recipeID,
        'ItemID': itemID,
        'RecipeName': recipeName,
        'Steps': steps,
      };
}

// API class for recipe items
class RecipeApi {
  static Future<List<Item>> getRecipes(String query) async {
    final apiUrl = Uri.parse('https://bakerymanagement-efgmhebnd5aggagn.eastus-01.azurewebsites.net/recipe');
    final response = await http.get(apiUrl);

    if (response.statusCode == 200) {
      final List recipes = json.decode(response.body);

      return recipes.map((json) => Item.fromJson(json)).where((recipe) {
        final recipeNameLower = recipe.recipeName.toLowerCase();
        final stepsLower = recipe.steps.toLowerCase();
        final searchLower = query.toLowerCase();

        // Check if the search query matches either the recipeName or steps
        return recipeNameLower.contains(searchLower) || stepsLower.contains(searchLower);
      }).toList();
    } else {
      throw Exception('Failed to load recipes');
    }
  }
}

/*
class RecipePage extends StatelessWidget {
  const RecipePage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add), // Plus icon
            onPressed: () {
              // Navigate to AddRecipePage when the button is pressed
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddRecipePage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Add some padding around the body
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Align content to the left
          children: [
            const Text(
              'Tap on the image to see the recipe',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10), // Space between the text and image
            GestureDetector(
              onTap: () {
                // Navigate to the detailed recipe page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DetailedRecipePage(),
                  ),
                );
              },
              child: Image.asset(
                'assets/bagel3.jpg', // Replace with your image path
                width: 100, // Set image width
                height: 100, // Set image height
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class DetailedRecipePage extends StatelessWidget {
  const DetailedRecipePage({super.key});

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
*/

class RecipePage extends StatelessWidget {
  final Product? product;
  
  const RecipePage({super.key, this.product});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add), // Plus icon
            onPressed: () {
              // Navigate to AddRecipePage when the button is pressed
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddRecipePage(),
                ),
              );
            },
          ),
        ],
      ),
      backgroundColor: const Color(0xFFEEC07B), // Set the background color

      body: Padding(
        padding: const EdgeInsets.all(16.0), // Add padding to the body
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Align content to the left
          children: [
            // Image section under the title
            Center(
              child: Image.asset(
                'assets/recipe.png', // Replace with your image path
                width: 100, // Set image width
                height: 100, // Set image height
                fit: BoxFit.cover, // Fit the image in the box
              ),
            ),
            const SizedBox(height: 20), // Space between the image and search bar

            // Search bar under the image
            TextField(
              decoration: InputDecoration(
                hintText: 'Search recipes...', // Placeholder text for the search bar
                prefixIcon: const Icon(Icons.search), // Search icon in the search bar
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0), // Rounded border
                ),
              ),
              onChanged: (value) {
                // Add search functionality here if needed
              },
            ),
            const SizedBox(height: 20), // Space between the search bar and text

            // Text section with image tap instruction
            const Text(
              'Tap on the image to see the recipe',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10), // Space between the text and image
            GestureDetector(
              onTap: () {
                // Navigate to the detailed recipe page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DetailedRecipePage(),
                  ),
                );
              },
              child: Image.asset(
                'assets/bagel3.jpg', // Replace with your image path
                width: 100, // Set image width
                height: 100, // Set image height
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DetailedRecipePage extends StatelessWidget {
  const DetailedRecipePage({super.key});

  Future<Map<String, dynamic>> fetchRecipeDetails() async {
    final apiUrl = Uri.parse('https://bakerymanagement-efgmhebnd5aggagn.eastus-01.azurewebsites.net/recipe');
    final response = await http.get(apiUrl);

    if (response.statusCode == 200) {
      final List recipes = json.decode(response.body);
      // Assuming the first recipe is returned, adjust if necessary
      return recipes.isNotEmpty ? recipes[0] : {};
    } else {
      throw Exception('Failed to load recipe details');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchRecipeDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator()); // Show loading spinner while fetching data
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}')); // Show error message if the API call fails
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No recipe data available')); // Show message if no data is available
          }

          final recipeData = snapshot.data!;
          final recipeName = recipeData['recipeName'] ?? 'Unknown Recipe';
          final itemID = recipeData['itemID']?.toString() ?? 'No Item ID';
          final directions = recipeData['steps'] ?? 'No directions found';

          return Scaffold(
            appBar: AppBar(
              title: Text(recipeName), // Dynamically update the title with recipeName
            ),
            body: SingleChildScrollView(
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
                    'Ingredients (Item ID)',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10), // Space between the header and content

                  // Display Item ID for ingredients
                  Text(
                    'Item ID: $itemID', // Use itemID here
                    style: const TextStyle(fontSize: 18),
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

                  // Directions from API
                  Text(
                    directions,
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}


// New page to add a recipe
class AddRecipePage extends StatelessWidget {
  const AddRecipePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Recipe'),
      ),
      body: const Center(
        child: Text(
          'Add recipe here',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}