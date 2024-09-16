import 'package:http/http.dart' as http;
import 'dart:convert';
import 'recipeItemClass.dart';

// API class for recipe items
class RecipeApi {
  static Future<List<Item>> getItems(String query) async {
    final apiUrl = Uri.parse('https://bakerymanagement-efgmhebnd5aggagn.eastus-01.azurewebsites.net/recipes');
    final response = await http.get(apiUrl);

    if (response.statusCode == 200) {
      final List recipes = json.decode(response.body);

      return recipes.map((json) => Item.fromJson(json)).where((recipe) {
        final recipeNameLower = recipe.name.toLowerCase();
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

// API for adding an ingredient
Future<void> addRecipe(int recipeID, String name, String steps, int productID, int ingredientID, String ingredientName, int ingredientQuantity) async {
  final url = Uri.parse('https://bakerymanagement-efgmhebnd5aggagn.eastus-01.azurewebsites.net/recipes');

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
        'RecipeID': recipeID,
        'Name': name,
        'Steps': steps,
        'ProductID': productID,
        'ingredientID': ingredientID,
        'ingredientName': ingredientName,
        'ingredientQuantity': ingredientQuantity,
    }),
  );

  if (response.statusCode == 201) {
    print('Recipe added successfully');
  } else {
    throw Exception('Failed to add ingredient: ${response.body}');
  }
}