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
    print('Fetching product with ID: ${_recipe.productID}');

    // Update the product quantity by adding the currentYield
    int updatedQuantity = product.quantity + currentYield;

    // Validate the updated quantity
    if (updatedQuantity > product.maxAmount) {
      throw Exception(
          'Updated quantity exceeds maximum allowed for product ${product.name}');
    }

    // Create a list to hold the inventory update futures
    List<Future> updateCalls = [];

    // Iterate through the ingredients in the recipe
    for (var ingredient in _recipe.ingredients) {
      // Calculate the total amount of the ingredient needed based on currentYield
      int totalAmountNeeded =
          (ingredient.quantity * (currentYield / _recipe.yield2).round());
      print('current yield: $currentYield');
      print('recipe yield: ${_recipe.yield2}');
      print('ingredient quantity: ${ingredient.quantity}');
      print('total amount needed: $totalAmountNeeded');
      // Fetch the current inventory item for the ingredient by IngredientID
      print(
          'Fetching inventory item with IngredientID: ${ingredient.ingredientID}');
      InventoryItem inventoryItem =
          await InventoryApi.fetchItemByIngredientId(ingredient.ingredientID);

      // Check if inventory has enough for the recipe by comparing numeric values
      if (totalAmountNeeded > inventoryItem.quantity) {
        throw Exception(
            'Insufficient inventory for ingredient: ${ingredient.name}. Required: $totalAmountNeeded, Available: ${inventoryItem.quantity}');
      }

      // If there is enough, proceed with updating the inventory
      print(
          'Sufficient inventory for ingredient: ${ingredient.name}. Required: $totalAmountNeeded, Available: ${inventoryItem.quantity}');

      int updatedInventoryQuantity = inventoryItem.quantity - totalAmountNeeded;

// Add the inventory update API call to the list
      final url = Uri.parse(
          'https://bakerymanagement-efgmhebnd5aggagn.eastus-01.azurewebsites.net/inventory/ingredient/${inventoryItem.ingredientID}');
      final requestBody = {
        'IngredientID': inventoryItem.ingredientID,
        'quantity': updatedInventoryQuantity,
      };

// Log the URL and the request body before making the API call
      print('PUT Request URL: $url');
      print('PUT Request Body: ${jsonEncode(requestBody)}');

// Add the HTTP PUT call to the list of update calls
      updateCalls.add(http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      ));
    }

    // Add the product update API call to the list
    updateCalls.add(http.put(
      Uri.parse(
          'https://bakerymanagement-efgmhebnd5aggagn.eastus-01.azurewebsites.net/finalproducts/${product.productID}'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'ProductID': product.productID,
        'Name': product.name,
        'Quantity': updatedQuantity,
        'Category': product.category,
      }),
    ));

    // Make all API calls in parallel
    final responses = await Future.wait(updateCalls);

    // Check the responses for success or failure
    for (var response in responses) {
      if (response.statusCode != 200) {
        throw Exception('Failed to update data: ${response.body}}');
      }
    }

    // Success message
    print('Product and inventory updated successfully!');
  } catch (e) {
    // Handle failure
    print('Failed to update product or inventory: $e');
  }
}
