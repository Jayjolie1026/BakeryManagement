import 'package:http/http.dart' as http;
import 'dart:convert';
import 'recipeItemClass.dart';
import 'bakedgoods.dart';
import 'inventoryItemClass.dart';
import 'inventoryAPI.dart';

// API class for recipe items
class RecipeApi {
  static Future<List<Item>> getItems(String query) async {
    final apiUrl = Uri.parse(
        'https://bakerymanagement-efgmhebnd5aggagn.eastus-01.azurewebsites.net/recipes');
    final response = await http.get(apiUrl);

    if (response.statusCode == 200) {
      final List<dynamic> recipes = json.decode(response.body);

      // Mapping the API response to the Item class
      return recipes.map((json) => Item.fromJson(json)).where((recipe) {
        final recipeNameLower = recipe.name.toLowerCase();
        final stepsLower = recipe.steps.toLowerCase();
        final searchLower = query.toLowerCase();

        return recipeNameLower.contains(searchLower) ||
            stepsLower.contains(searchLower);
      }).toList();
    } else {
      throw Exception('Failed to load recipes');
    }
  }

  // API for updating a recipe
  Future<void> updateRecipe(
      int recipeID,
      String? newName,
      String? steps,
      List<Map<String, dynamic>> ingredients,
      int productID,
      String? category,
      int yield2) async {
    final url = Uri.parse(
        'https://bakerymanagement-efgmhebnd5aggagn.eastus-01.azurewebsites.net/recipes/$recipeID');

    // Create a map for the body with only non-null values
    final Map<String, dynamic> body = {
      'name': newName,
      'steps': steps,
      'product_id': productID,
      'ingredients': ingredients,
      'category': category,
      'yield': yield2,
    };

    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      // success
    } else {
      throw Exception('Failed to update recipe: ${response.body}');
    }
  }

  static Future<Item> fetchRecipeById(int recipeID) async {
    final response = await http.get(Uri.parse(
        'https://bakerymanagement-efgmhebnd5aggagn.eastus-01.azurewebsites.net/recipes/$recipeID'));

    if (response.statusCode == 200) {
      final item = Item.fromJson(json.decode(response.body));
      return item;
    } else {
      throw Exception('Failed to load item');
    }
  }
}

Future<void> addRecipe(String name, String steps, int productID,
    String category, int yield2, List<Map<String, dynamic>> ingredients) async {
  final url = Uri.parse(
      'https://bakerymanagement-efgmhebnd5aggagn.eastus-01.azurewebsites.net/recipes');

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': name,
        'steps': steps,
        'product_id': productID,
        'category': category, // Add category to JSON body
        'yield': yield2, // Add yield to JSON body
        'ingredients': ingredients,
      }),
    );

    if (response.statusCode == 201) {
      // success
    } else {
      throw Exception('Failed to add recipe: ${response.body}');
    }
  } catch (error) {
    throw Exception('Failed to add recipe due to an error: $error');
  }
}

Future<void> bake(Item _recipe, int currentYield) async {
  try {
    // Fetch the product by productID from the recipe
    Product product = await ProductApi.fetchProductById(_recipe.productID);

    // Update the product quantity by adding the currentYield
    int updatedQuantity = product.quantity + currentYield;

    // Validate the updated quantity
    if (updatedQuantity > product.maxAmount) {
      throw Exception('Updated quantity exceeds maximum allowed');
    }

    // Create a list to hold the inventory update futures
    List<Future> updateCalls = [];

    // Iterate through the ingredients in the recipe
    for (var ingredient in _recipe.ingredients) {
      // Calculate the total amount of the ingredient needed based on currentYield
      int totalAmountNeeded = ingredient.quantity * currentYield;

      // Fetch the current inventory item for the ingredient
      InventoryItem inventoryItem = await InventoryApi.fetchItemById(ingredient.ingredientID);

      // Calculate the updated quantity by subtracting the amount needed
      int updatedInventoryQuantity = inventoryItem.quantity - totalAmountNeeded;

      // Check if inventory has enough for the recipe
      if (updatedInventoryQuantity < 0) {
        throw Exception('Insufficient inventory for ingredient: ${ingredient.name}');
      }

      // Add the inventory update API call to the list
      updateCalls.add(http.put(
        Uri.parse('https://your-api-url/inventory/${inventoryItem.ingredientID}'),
        body: jsonEncode({
          'ingredient_id': inventoryItem.ingredientID,
          'quantity': updatedInventoryQuantity,
          'notes': inventoryItem.notes,
          'cost': inventoryItem.cost,
          'create_datetime': inventoryItem.createDateTime.toIso8601String(),
          'expire_datetime': inventoryItem.expireDateTime.toIso8601String(),
          'measurement': inventoryItem.invMeasurement,
        }),
        headers: {"Content-Type": "application/json"},
      ));
    }

    // Add the product update API call to the list
    updateCalls.add(http.put(
      Uri.parse('https://your-api-url/product/${product.productID}'),
      body: jsonEncode({
        'productID': product.productID,
        'name': product.name,
        'description': product.description,
        'maxAmount': product.maxAmount,
        'remakeAmount': product.remakeAmount,
        'minAmount': product.minAmount,
        'quantity': updatedQuantity,
        'price': product.price,
        'category': product.category,
      }),
      headers: {"Content-Type": "application/json"},
    ));

    // Make all API calls in parallel
    final responses = await Future.wait(updateCalls);

    // Check the responses for success or failure
    for (var response in responses) {
      if (response.statusCode != 200) {
        throw Exception('Failed to update data: ${response.body}');
      }
    }

    // Success message
    print('Product and inventory updated successfully!');
  } catch (e) {
    // Handle failure
    print('Failed to update product or inventory: $e');
  }
}
