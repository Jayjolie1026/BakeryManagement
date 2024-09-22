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
   static Future<List<Item>> getRecipesByProductId(int? productID) async {

    final apiUrl = Uri.parse('https://bakerymanagement-efgmhebnd5aggagn.eastus-01.azurewebsites.net/recipes?productID=$productID');
    final response = await http.get(apiUrl);

    if (response.statusCode == 200) {
      final List<dynamic> recipes = json.decode(response.body);
      print('Recipes: $recipes');
      // Mapping the API response to the Item class
      return recipes.map((json) => Item.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load recipes');
    }
  }
}



// API for adding an ingredient
Future<void> addRecipe(int recipeID, String name, String steps, int productID, List<Ingredient> ingredients) async {
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
