import 'package:http/http.dart' as http;
import 'dart:convert';
import 'inventoryItemClass.dart';

// API class for inventory items
class InventoryApi {
  static Future<List<InventoryItem>> getItems(String query) async {
    final apiUrl = Uri.parse(
        'https://bakerymanagement-efgmhebnd5aggagn.eastus-01.azurewebsites.net/inventory');
    final response = await http.get(apiUrl);

    if (response.statusCode == 200) {
      final List items = json.decode(response.body);

      return items.map((json) => InventoryItem.fromJson(json)).where((item) {
        final ingredientNameLower = item.ingredientName
            .toLowerCase(); // Add ingredient name for filtering
        final searchLower = query.toLowerCase();

        return ingredientNameLower.contains(searchLower);
      }).toList();
    } else {
      throw Exception('Failed to load inventory items');
    }
  }

  static const String baseUrl =
      'https://bakerymanagement-efgmhebnd5aggagn.eastus-01.azurewebsites.net/inventory';

  static Future<InventoryItem> fetchItemById(int itemId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$itemId'));

      if (response.statusCode == 200) {
        final item = InventoryItem.fromJson(json.decode(response.body));
        return item;
      } else {
        throw Exception('Failed to load item: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching item: $e');
    }
  }

static Future<List<InventoryItem>> fetchItemByName(String itemName) async {
  try {
    final response = await http.get(Uri.parse('$baseUrl/name/${Uri.encodeComponent(itemName)}'));

    if (response.statusCode == 200) {
      // Expecting a list in the response body
      List<dynamic> jsonResponse = json.decode(response.body);
      // Convert the list of JSON maps into a list of InventoryItem objects
      List<InventoryItem> items = jsonResponse.map((item) => InventoryItem.fromJson(item)).toList();
      return items;
    } else {
      throw Exception('Failed to load item: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error: $e');
  }
}

// Fetch an inventory item by IngredientID
  static Future<InventoryItem> fetchItemByIngredientId(int ingredientId) async {
    final response = await http.get(Uri.parse('$baseUrl/ingredient/$ingredientId'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      if (data.isNotEmpty) {
        return InventoryItem.fromJson(data[0]); // Get the first item in the list
      } else {
        throw Exception('No inventory item found for IngredientID: $ingredientId');
      }
    } else {
      throw Exception('Failed to load inventory item: ${response.body}');
    }
  }

}
