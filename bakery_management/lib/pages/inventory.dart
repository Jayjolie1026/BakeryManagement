import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Item model for inventory items
class Item {
  final int entryID;
  final int quantity;
  final double cost;
  final String notes;
  final DateTime createDateTime;
  final DateTime expireDateTime;
  final int employeeID; // Optional if included in API response
  final int recipeID;   // Optional if included in API response
  final String ingredientName;
  final int ingredientQuantity;
  final int minAmount;
  final int maxAmount;
  final int reorderAmount;


  // Constructor
  Item({
    required this.entryID,
    required this.quantity,
    required this.cost,
    required this.notes,
    required this.createDateTime,
    required this.expireDateTime,
    this.employeeID = 0, // Default to 0 if not included in API response
    this.recipeID = 0,   // Default to 0 if not included in API response
    required this.ingredientName, // Initialize IngredientName
    required this.ingredientQuantity,
    required this.minAmount,
    required this.maxAmount,
    required this.reorderAmount,
  });

  // Factory constructor to create an Item from a JSON object
  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      entryID: json['EntryID'],
      quantity: json['Quantity'].toInt(),
      cost: json['Cost'].toDouble(),
      notes: json['Notes'] ?? '', // Default to empty string if null
      createDateTime: DateTime.parse(json['CreateDateTime']),
      expireDateTime: DateTime.parse(json['ExpireDateTime']),
      employeeID: json['EmployeeID'] ?? 0, // Use default if null
      recipeID: json['RecipeID'] ?? 0,     // Use default if null
      ingredientName: json['IngredientName'] ?? '', // Extract IngredientName
      ingredientQuantity: json['IngredientQuantity'].toInt(), // Extract IngredientQuantity
      minAmount: json['MinAmount'].toInt(),  // Extract MinAmount
      maxAmount: json['MaxAmount'].toInt(),  // Extract MaxAmount
      reorderAmount: json['ReorderAmount'].toInt(),  // Extract ReorderAmount
    );
  }

  // Convert Item object to JSON format
  Map<String, dynamic> toJson() => {
        'EntryID': entryID,
        'Quantity': quantity,
        'Cost': cost,
        'Notes': notes,
        'CreateDateTime': createDateTime.toIso8601String(),
        'ExpireDateTime': expireDateTime.toIso8601String(),
        'EmployeeID': employeeID,
        'RecipeID': recipeID,
        'IngredientName': ingredientName, // Add IngredientName to JSON
        'IngredientQuantity': ingredientQuantity,
        'MinAmount': minAmount,
        'MaxAmount': maxAmount,
        'ReorderAmount': reorderAmount,
      };
}

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

// Inventory Page
class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  _InventoryPageState createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  List<Item> items = [];
  String query = '';
  Timer? debouncer;

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void dispose() {
    debouncer?.cancel();
    super.dispose();
  }

  // Debounce for search bar
  void debounce(VoidCallback callback, {Duration duration = const Duration(milliseconds: 1000)}) {
    if (debouncer != null) {
      debouncer!.cancel();
    }
    debouncer = Timer(duration, callback);
  }

  // Initialize inventory items
  Future init() async {
    final items = await InventoryApi.getItems(query);
    setState(() => this.items = items);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Image.asset(
            'assets/inventory_logo.png',
            height: 60,
          ),
          centerTitle: true,
        ),
        body: Column(
          children: <Widget>[
            buildSearch(),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return buildItem(item);
                },
              ),
            ),
          ],
        ),
      );

  // Search bar widget
  Widget buildSearch() => SearchWidget(
        text: query,
        hintText: 'Search by Notes',
        onChanged: searchItem,
      );

  // Search for an item by query
  Future searchItem(String query) async => debounce(() async {
        final items = await InventoryApi.getItems(query);

        if (!mounted) return;

        setState(() {
          this.query = query;
          this.items = items;
        });
      });

  // Build list tile for each inventory item
  Widget buildItem(Item item) => ListTile(
        title: Text(item.notes), // Display notes or relevant details
        subtitle: Text('Ingredient: ${item.ingredientName}'), // Display the IngredientName
        trailing: Text('Quantity: ${item.quantity}'),

      );
}

// Search widget component
class SearchWidget extends StatefulWidget {
  final String text;
  final ValueChanged<String> onChanged;
  final String hintText;

  const SearchWidget({
    super.key,
    required this.text,
    required this.onChanged,
    required this.hintText,
  });

  @override
  _SearchWidgetState createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final styleActive = const TextStyle(color: Colors.black);
    final styleHint = const TextStyle(color: Colors.black54);
    final style = widget.text.isEmpty ? styleHint : styleActive;

    return Container(
      height: 42,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        border: Border.all(color: Colors.black26),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          icon: Icon(Icons.search, color: style.color),
          suffixIcon: widget.text.isNotEmpty
              ? GestureDetector(
                  child: Icon(Icons.close, color: style.color),
                  onTap: () {
                    controller.clear();
                    widget.onChanged('');
                    FocusScope.of(context).requestFocus(FocusNode());
                  },
                )
              : null,
          hintText: widget.hintText,
          hintStyle: style,
          border: InputBorder.none,
        ),
        style: style,
        onChanged: widget.onChanged,
      ),
    );
  }
}

// Function to check quantity vs reorder amount
void checkInventoryLevels(List<Item> items) {
  for (var item in items) {
    if (item.quantity < item.reorderAmount) {
      // Display a warning or alert
      print('Warning: ${item.ingredientName} is below the reorder amount!');
    }
  }
}