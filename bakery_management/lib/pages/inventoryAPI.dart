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

  static Future<void> addItem(Item item) async {
    final apiUrl = Uri.parse('https://bakerymanagement-efgmhebnd5aggagn.eastus-01.azurewebsites.net/inventory');

    final body = jsonEncode({
      "ingredientName": item.ingredientName,
      "notes": item.notes,
      "quantity": item.quantity,
      "maxAmount": item.maxAmount,
      "reorderAmount": item.reorderAmount,
      "minAmount": item.minAmount,
      "cost": item.cost,
      "createDateTime": item.createDateTime.toIso8601String(),
      "expireDateTime": item.expireDateTime.toIso8601String(),
      "vendorID": item.vendorID,
    });

    print('Request body: $body');

    try {
      final response = await http.post(
        apiUrl,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 201) {
        print('Ingredient item created successfully');
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        item.entryID = responseData['EntryID'];

        print('Ingredient item created successfully with entryID: ${item.entryID}');
      } else {
        print('Failed to create ingredient: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  static Future<void> updateItem(Item item) async {
    final apiUrl = Uri.parse('https://bakerymanagement-efgmhebnd5aggagn.eastus-01.azurewebsites.net/inventory/${item.entryID}');
    final response = await http.put(
      apiUrl,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(item.toJson()),
    );
    print('Response status: ${response.statusCode}');
    print('Update request body: ${jsonEncode(item.toJson())}');

    if (response.statusCode != 200) {
      throw Exception('Failed to update ingredient item');
    }
  }
}
