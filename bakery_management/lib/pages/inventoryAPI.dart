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
        final notesLower = item.notes.toLowerCase();
        final ingredientNameLower = item.ingredientName.toLowerCase(); // Add ingredient name for filtering
        final searchLower = query.toLowerCase();

        return notesLower.contains(searchLower) || ingredientNameLower.contains(searchLower);
      }).toList();
    } else {
      throw Exception('Failed to load inventory items');
    }
  }
}

// API for adding an ingredient
Future<void> addIngredient(String name, String description, String category, String measurement, double maxAmount, double reorderAmount, double minAmount, int vendorID) async {
  final url = Uri.parse('https://yourapiurl.com/ingredients');

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      'name': name,
      'description': description,
      'category': category,
      'measurement': measurement,
      'maxAmount': maxAmount,
      'reorderAmount': reorderAmount,
      'minAmount': minAmount,
      'vendorID': vendorID,
    }),
  );

  if (response.statusCode == 201) {
    print('Ingredient added successfully');
  } else {
    throw Exception('Failed to add ingredient: ${response.body}');
  }
}