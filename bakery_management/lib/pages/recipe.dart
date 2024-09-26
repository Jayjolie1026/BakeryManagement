import 'dart:async';
import 'package:flutter/material.dart';
import 'recipeItemClass.dart';
import 'recipeAPI.dart';
import 'recipeFunctions.dart';
import 'inventorySearchWidget.dart';



// Recipe Page
class RecipePage extends StatefulWidget {
  final int? productID;
  const RecipePage({super.key,this.productID});

  @override
  _RecipePageState createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {
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
    final items = await RecipeApi.getItems(query);
    setState(() => this.items = items);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
   
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
        const SizedBox(height: 80)
      ],
    ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () => showAddRecipeDialog(context, () {
        // Refresh the product list after adding a new product
        setState(() {
          init(); // Call init to reload products
        });
      }),
      label: const Text(
        'Add Recipe',
        style: TextStyle(
          color: Color(0xFFEEC07B),  // Light brown text color
          fontSize: 17,
        ),
      ),
      icon: const Icon(
        Icons.add,
        color: Color(0xFFEEC07B),  // Light brown icon color
      ),
      backgroundColor: const Color(0xFF422308),  // Dark brown background
    ),
    floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat, // Center at the bottom
  );

  // Search bar widget
  Widget buildSearch() => SearchWidget(
    text: query,
    hintText: 'Search by Name',
    onChanged: searchItem, backgroundColor: null,
  );

  // Search for an item by query
  Future searchItem(String query) async => debounce(() async {
    final items = await RecipeApi.getItems(query);

    if (!mounted) return;

    setState(() {
      this.query = query;
      this.items = items;
    });
  });
  
  // Build list tile for each inventory item
  Widget buildItem(Item item) => GestureDetector(
    onTap: () async {
      final result = await Navigator.push(
      // Navigate to the DetailedRecipePage
        context,
        MaterialPageRoute(
          builder: (context) => DetailedRecipePage(recipeName: item.name, recipeID: item.recipeID),
          //builder: (context) => DetailedRecipePage(recipeName: item.name, recipeID: item.recipeID), // Pass the item if needed
        ),
      );
      if (result == true) {
        init();
      }
    },
    child: Card(
      color: const Color(0xFF6D3200),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50),
      ),
      margin: const EdgeInsets.fromLTRB(30, 0, 30, 10),
      elevation: 4,
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              item.name, //should be name
              style: const TextStyle(
                color: Color(0xFFEEC07B),
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