import 'package:http/http.dart' as http;
import 'dart:convert';
import 'recipeItemClass.dart';

// API class for recipe items
class RecipeApi {
  static Future<List<Item>> getItems(String query) async {
    final apiUrl = Uri.parse('https://bakerymanagement-efgmhebnd5aggagn.eastus-01.azurewebsites.net/recipes');
    final response = await http.get(apiUrl);

    if (response.statusCode == 200) {
      final List<dynamic> recipes = json.decode(response.body);

      // Mapping the API response to the Item class
      return recipes.map((json) => Item.fromJson(json)).where((recipe) {
        final recipeNameLower = recipe.name.toLowerCase();
        final stepsLower = recipe.steps.toLowerCase();
        final searchLower = query.toLowerCase();

        return recipeNameLower.contains(searchLower) || stepsLower.contains(searchLower);
      }).toList();
    } else {
      throw Exception('Failed to load recipes');
    }
  }

  // API for updating a recipe
 Future<void> updateRecipe(int recipeID, String? newName, String? steps, List<Map<String, dynamic>> ingredients, int productID) async {
  final url = Uri.parse('https://bakerymanagement-efgmhebnd5aggagn.eastus-01.azurewebsites.net/recipes/$recipeID');

  final response = await http.put(
    url,
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      'name': newName,
      'steps': steps,
      'product_id': productID,  // Include product ID here
      'ingredients': ingredients,
    }),
  );

  if (response.statusCode == 200) {
    print('Recipe updated successfully');
  } else {
    throw Exception('Failed to update recipe: ${response.body}');
  }
}


  // API for adding a recipe
 
}

 Future<void> addRecipe(String name, String steps, int productID, List<Map<String, dynamic>> ingredients) async {
    final url = Uri.parse('https://bakerymanagement-efgmhebnd5aggagn.eastus-01.azurewebsites.net/recipes');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': name,
        'steps': steps,
        'product_id': productID,
        'ingredients': ingredients,
      }),
    );

    if (response.statusCode == 201) {
      print('Recipe created successfully');
    } else {
      throw Exception('Failed to add recipe: ${response.body}');
    }
  }