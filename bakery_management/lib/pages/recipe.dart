import 'dart:async';
import 'package:flutter/material.dart';
import 'recipeItemClass.dart';
import 'recipeAPI.dart';
import 'recipeFunctions.dart';
import 'package:bakery_management/pages/sessions.dart';
import 'package:bakery_management/main.dart';
import 'package:shared_preferences/shared_preferences.dart';


// Recipe Page
class RecipePage extends StatefulWidget {
  final int? productID;
  const RecipePage({super.key,this.productID});

  @override
  _RecipePageState createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {
  List<Item> items = [];
  List<Item> allItems = [];
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
     setState(() {
      this.items = items;
      this.allItems = items; // Store all items for future reference
    });
  }
  

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF0D1A0),
    body: Column(
      children: <Widget>[
        SizedBox(height: 25.0),
        buildSearchWithFilter(),
        Expanded(
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return GestureDetector(
                onTap: () async {
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  int? sessionId = prefs.getInt('sessionId'); // Get the sessionId as an int

                  if (sessionId != null) {
                  // Create an instance of SessionService
                  SessionService sessionService = SessionService(context);

                  // Check the session status
                  await sessionService.checkSession(sessionId); // Check if the session is active

                  // If the session is active, update it
                  await sessionService.updateSession(sessionId); // Update the session to keep it alive

                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const SignInPage()),
                  );
                }
                  // Navigate to the detailed recipe page
                  final updatedRecipe = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailedRecipePage(
                        recipeName: item.name,
                        recipeID: item.recipeID,
                      ),
                    ),
                  );

                  // If an updatedRecipe is returned, refresh the item in the list
                  if (updatedRecipe != null) {
                    setState(() {
                      // Find the index of the item and update it in the list
                      int index = items.indexWhere((i) => i.recipeID == updatedRecipe.recipeID);
                      if (index != -1) {
                        items[index] = updatedRecipe; // Update the specific item
                      }
                    });

                    // Re-apply the current query/filter after returning
                    if (query.isNotEmpty) {
                      searchItem(query);  // Re-apply the search/filter query
                    } else {
                      setState(() {
                        items = allItems;  // Reset to full list if no filter is applied
                      });
                    }
                  }
                },
                child: buildItem(item), // Your custom widget to display the item
              );
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
  Widget buildSearchWithFilter() => Row(
    children: [
      Expanded(
        // The search widget takes up the remaining space
        child: SearchWidget(
          text: query,
          hintText: 'Search by Name',
          onChanged: searchItem,
        ),
      ),
      Container(
        padding: EdgeInsets.fromLTRB(0, 0, 25, 15), // Add some padding if needed
        alignment: Alignment.center, // Center the icon vertically
        child: IconButton(
          icon: Icon(Icons.filter_list),
          color: Colors.brown,  // Adjust color to match your theme
          onPressed: () async{
            SharedPreferences prefs = await SharedPreferences.getInstance();
            int? sessionId = prefs.getInt('sessionId'); // Get the sessionId as an int

            if (sessionId != null) {
            // Create an instance of SessionService
            SessionService sessionService = SessionService(context);

            // Check the session status
            await sessionService.checkSession(sessionId); // Check if the session is active

            // If the session is active, update it
            await sessionService.updateSession(sessionId); // Update the session to keep it alive

          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SignInPage()),
            );
          }
            _showFilterOptions();
          },
        ),
      ),
    ],
  );

    void _showFilterOptions() {
  final categories = _getCategories(); // Get unique categories from items
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: const Color.fromARGB(255, 243, 217, 162), // Set the background color of the AlertDialog
        title: Text(
          'Filter by Category',
          style: TextStyle(
            color: const Color(0xFF6D3200), // Set the title text color
          ),
        ),
        content: SingleChildScrollView( // Make content scrollable
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: categories.map((category) {
              return ListTile(
                title: Text(
                  category,
                  style: TextStyle(
                    color: const Color(0xFF6D3200), // Set the ListTile text color
                  ),
                ),
                onTap: () {
                  Navigator.pop(context); // Close the dialog
                  applyCategoryFilter(category); // Apply the category filter
                },
              );
            }).toList(),
          ),
        ),
        actions: [
         IconButton(
          icon: Icon(Icons.close, color: const Color(0xFF422308)), // Set the close button icon color
          onPressed: () {
            Navigator.pop(context); // Close the dialog
            setState(() {
              items = allItems; // Reset to show all items
              query = ''; // Clear the query as well
            });
          },
        ),

        ],
      );
    },
  );
}

// Helper function to check if the query is a category
bool _isCategory(String query) {
  // Assuming you have the categories already fetched from _getCategories
  final categories = _getCategories();
  return categories.contains(query);
}


// Get unique categories from the list of items
List<String> _getCategories() {
  final allCategories = items.map((item) => item.category).toSet();
  //print(_getCategories());
  
   // Extract unique categories
  return allCategories.toList(); // Convert Set back to List for easier manipulation
}

// Apply the selected category filter
void applyCategoryFilter(String category) {
  setState(() {
    // Filter items based on the selected category from the full item list
    items = allItems.where((item) => item.category == category).toList();
    query = category; // Update the query to reflect the selected category
  });
}

  void searchItem(String query) {
  List<Item> filteredItems;

  if (query.isEmpty) {
    // Reset items to the full list when search is cleared
    filteredItems = allItems;
  } else if (_isCategory(query)) {
    // If query is a category, filter items by that category
    filteredItems = allItems.where((item) => item.category == query).toList();
  } else {
    // Otherwise, filter items by name or other search criteria
    filteredItems = allItems.where((item) =>
        item.name.toLowerCase().contains(query.toLowerCase())).toList();
        
  }

  setState(() {
    items = filteredItems;
    this.query = query; // Update query in state
  });
}
  
  // Build list tile for each inventory item
 Widget buildItem(Item item) => GestureDetector(
  onTap: () async {
    // Navigate to the detailed recipe page
    final updatedRecipe = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailedRecipePage(
          recipeName: item.name,
          recipeID: item.recipeID,
          onRecipeUpdated: (updatedRecipe) {
            // Find the index of the recipe to update
            int index = items.indexWhere((i) => i.recipeID == updatedRecipe.recipeID);
            if (index != -1) {
              setState(() {
                items[index] = updatedRecipe; // Update the recipe list
                
              });
            }
          },
        ),
      ),
    );

    // If an updated recipe is returned, refresh the item in the list
    if (updatedRecipe != null) {
      setState(() {
        // Find the index of the item to update
        int index = items.indexWhere((i) => i.recipeID == updatedRecipe.recipeID);
        if (index != -1) {
          items[index] = updatedRecipe; // Update the existing item
          allItems[index] = updatedRecipe; // Ensure allItems is also updated
        }
      });
    }

    // Re-apply the current query/filter after returning
    setState(() {
      // Check if the query is still valid and reapply filtering
      if (query.isNotEmpty) {
        searchItem(query);  // Re-apply the search/filter query
      } else {
        items = allItems;  // Reset to full list if no filter is applied
      }
    });
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
            item.name,
            style: const TextStyle(
              color: Color(0xFFEEC07B),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  ),
);
}

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
  void initState() {
    super.initState();
    controller.text = widget.text;
  }

  @override
  Widget build(BuildContext context) {
    const styleActive = TextStyle(color: Color(0xFF6D3200));
    const styleHint = TextStyle(color: Color(0xFF6D3200));
    final style = widget.text.isEmpty ? styleHint : styleActive;

    return Container(
      height: 50,
      margin: const EdgeInsets.fromLTRB(30, 0, 0, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: const Color(0xFFD8C4AA),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: TextField(
        controller: controller,
        cursorColor: const Color(0xFFEEC07B),
        decoration: InputDecoration(
          iconColor: const Color(0xFFEEC07B),
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