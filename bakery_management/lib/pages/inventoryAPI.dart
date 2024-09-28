import 'package:http/http.dart' as http;
import 'dart:convert';
import 'inventoryItemClass.dart';

// API class for inventory items
class InventoryApi {
  static Future<List<Item>> getItems(String query) async {
    final apiUrl = Uri.parse('https://bakerymanagement-efgmhebnd5aggagn.eastus-01.azurewebsites.net/inventory');
    final response = await http.get(apiUrl);

    if (response.statusCode == 200) {
      final List items = json.decode(response.body);

      return items.map((json) => Item.fromJson(json)).where((item) {
        final ingredientNameLower = item.ingredientName.toLowerCase(); // Add ingredient name for filtering
        final searchLower = query.toLowerCase();

        return ingredientNameLower.contains(searchLower);
      }).toList();
    } else {
      throw Exception('Failed to load inventory items');
    }
  }

  static const String baseUrl = 'https://bakerymanagement-efgmhebnd5aggagn.eastus-01.azurewebsites.net/finalproducts';

  static Future<Item> fetchItemById(int ItemId) async {
    final response = await http.get(Uri.parse('$baseUrl/$ItemId'));

    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, parse the JSON
      return Item.fromJson(json.decode(response.body));
    } else {
      // If the server did not return a 200 OK response, throw an exception
      throw Exception('Failed to load product');
    }
  }
}
