import 'package:http/http.dart' as http;
import 'dart:convert';
import 'inventoryItemClass.dart';

// API class for inventory items
class InventoryApi {
  static Future<List<InventoryItem>> getItems(String query) async {
    final apiUrl = Uri.parse('https://bakerymanagement-efgmhebnd5aggagn.eastus-01.azurewebsites.net/inventory');
    final response = await http.get(apiUrl);

    if (response.statusCode == 200) {
      final List items = json.decode(response.body);

      return items.map((json) => InventoryItem.fromJson(json)).where((item) {
        final ingredientNameLower = item.ingredientName.toLowerCase(); // Add ingredient name for filtering
        final searchLower = query.toLowerCase();

        return ingredientNameLower.contains(searchLower);
      }).toList();
    } else {
      throw Exception('Failed to load inventory items');
    }
  }

  static const String baseUrl = 'https://bakerymanagement-efgmhebnd5aggagn.eastus-01.azurewebsites.net/inventory';

  static Future<InventoryItem> fetchItemById(int itemId) async {
    final response = await http.get(Uri.parse('$baseUrl/$itemId'));

    if (response.statusCode == 200) {
      final item = InventoryItem.fromJson(json.decode(response.body));
      return item;
    } else {
      throw Exception('Failed to load item');
    }
  }

}
