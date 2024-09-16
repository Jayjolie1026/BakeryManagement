import 'dart:async';
import 'package:flutter/material.dart';
import 'recipeItemClass.dart';
import 'recipeAPI.dart';
import 'recipeFunctions.dart';
import 'inventorySearchWidget.dart';



// Recipe Page
class RecipePage extends StatefulWidget {
  const RecipePage({super.key});

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
    appBar: AppBar(
      toolbarHeight: 100,
      title: Image.asset(
        'assets/recipe2.png',
        height: 100,
      ),
      centerTitle: true,
      backgroundColor: const Color(0xFFF0D1A0),
    ),
    backgroundColor: const Color(0xFFF0D1A0),
    body: Column(
      children: <Widget>[
        buildSearch(),
      ],
    ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () => showAddRecipeDialog(context), // Open form for new recipe
      label: const Text('Add Recipe'),
      icon: const Icon(Icons.add),
      backgroundColor: const Color.fromARGB(255, 243, 217, 162),
    ),
    floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat, // Center at the bottom
  );

  // Search bar widget
  Widget buildSearch() => SearchWidget(
    text: query,
    hintText: 'Search by Name',
    onChanged: searchItem
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
}