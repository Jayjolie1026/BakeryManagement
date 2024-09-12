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
      toolbarHeight: 100,
      title: Image.asset(
        'assets/inventory_logo.png',
        height: 100,
      ),
      centerTitle: true,
      backgroundColor: const Color(0xFFF0D1A0),
    ),
    backgroundColor: const Color(0xFFF0D1A0),
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
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () => showAddIngredientDialog(context), // Open form for new ingredient
      label: const Text('Add Ingredient'),
      icon: const Icon(Icons.add),
      backgroundColor: const Color.fromARGB(255, 243, 217, 162),
    ),
    floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat, // Center at the bottom
  );

  // Search bar widget
  Widget buildSearch() => SearchWidget(
    text: query,
    hintText: 'Search by Notes',
    onChanged: searchItem
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
  Widget buildItem(Item item) => Card(
    color: Color(0xFFEEC07B),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(50),
    ),
    margin: const EdgeInsets.fromLTRB(30, 0, 30, 10),
    elevation: 4,
    child: GestureDetector(
      onTap: () {
        // Navigate to the detailed recipe page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const showItemDetails(context, item),
          ),
        );
      },
      child: Container(
        height: 50,
        padding: EdgeInsets.symmetric(horizontal: 0, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              item.notes, //should be name
              style: TextStyle(
                color: Color(0xFF6D3200),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        )
      ),
    ),
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
      height: 50,
      margin: const EdgeInsets.fromLTRB(30, 0, 30, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: Color(0xFFD8C4AA),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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

// Function to show a dialog for adding a new ingredient
void showAddIngredientDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      String ingredientName = '';
      String description = '';
      String category = '';
      String measurement = '';
      double maxAmount = 0.0;
      double reorderAmount = 0.0;
      double minAmount = 0.0;
      int vendorID = 0;

      return AlertDialog(
        title: const Text('Add Ingredient'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Ingredient Name'),
              onChanged: (value) {
                ingredientName = value;
              },
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Description'),
              onChanged: (value) {
                description = value;
              },
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Category'),
              onChanged: (value) {
                category = value;
              },
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Measurement'),
              onChanged: (value) {
                measurement = value;
              },
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Max Amount'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                maxAmount = double.tryParse(value) ?? 0.0;
              },
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Reorder Amount'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                reorderAmount = double.tryParse(value) ?? 0.0;
              },
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Min Amount'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                minAmount = double.tryParse(value) ?? 0.0;
              },
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Vendor ID'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                vendorID = int.tryParse(value) ?? 0;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          ElevatedButton(
            child: const Text('Add'),
            onPressed: () async {
              try {
                await addIngredient(
                  ingredientName,
                  description,
                  category,
                  measurement,
                  maxAmount,
                  reorderAmount,
                  minAmount,
                  vendorID,
                );
                Navigator.of(context).pop();
                // Optionally, refresh the inventory list
              } catch (e) {
                print('Error adding ingredient: $e');
              }
            },
          ),
        ],
      );
    },
  );
}

// Function to format dates
String formatDate(DateTime dateTime) {
  final day = dateTime.day.toString().padLeft(2, '0');
  final month = dateTime.month.toString().padLeft(2, '0');
  final year = dateTime.year.toString();

  return '$year-$month-$day'; // Format as YYYY-MM-DD
}

// Function to show a dialog with item details
void showItemDetails(BuildContext context, Item item) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Center(
          child: Text(
            'Ingredients',
            style: TextStyle(color: Color.fromARGB(255, 97, 91, 77)),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Placeholder image at the top
            Image.network(
              'https://via.placeholder.com/150', // Placeholder image URL
              height: 150,
              width: 150,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 16),
            // Item details
            Text('Entry ID: ${item.entryID}'),
            Text('PO Number: ${item.entryID}'), // Assuming PO Number is same as Entry ID for now
            Text('Entry Date: ${formatDate(item.createDateTime)}'),
            Text('Expiration Date: ${formatDate(item.expireDateTime)}'),
            Text('Quantity: ${item.quantity}'),
            Text('Cost: \$${item.cost.toStringAsFixed(2)}'),
            Text('Notes: ${item.notes}'),
          ],
        ),
        actions: [
          // Container to add space between the buttons and the dialog edges
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Update button
                TextButton.icon(
                  icon: const Icon(Icons.update, color: Color.fromARGB(255, 97, 91, 77)), // Change icon color
                  label: const Text('Update', style: TextStyle(color: Color.fromARGB(255, 97, 91, 77))),
                  onPressed: () {
                    // Action for Update button
                  },
                ),
                // Vendor button
                TextButton.icon(
                  icon: const Icon(Icons.store, color: Color.fromARGB(255, 97, 91, 77)),
                  label: const Text('Vendor', style: TextStyle(color: Color.fromARGB(255, 97, 91, 77))),
                  onPressed: () {
                    // Action for Vendor button
                  },
                ),
              ],
            ),
          ),
        ],
      );
    },
  );
}
