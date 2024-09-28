import 'dart:async';
import 'vendorsItemClass.dart';
import 'bakedgoods.dart';
import 'package:flutter/material.dart';
import 'inventoryItemClass.dart';
import 'inventoryAPI.dart';
import 'inventoryFunctions.dart';
import 'package:intl/intl.dart';
import 'vendors.dart';
import 'vendorsAPI.dart';


class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  _InventoryPageState createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  List<Item> items = [];
  List<Item> allItems = [];  // This holds all items
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
  void debounce(VoidCallback callback,
      {Duration duration = const Duration(milliseconds: 1000)}) {
    if (debouncer != null) {
      debouncer!.cancel();
    }
    debouncer = Timer(duration, callback);
  }

  // Initialize inventory items
  Future init() async {
    final items = await InventoryApi.getItems(query);
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
      // Search bar with filter
      buildSearchWithFilter(),
      Expanded(
        child: ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return GestureDetector(
              onTap: () async {
                init();
               final updatedItem = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ItemDetailPage(
                      item: item,
                    ),
                  ),
                );
                 if (updatedItem != null) {
                  setState(() {
                    int index = items.indexWhere((i) => i.ingredientID == updatedItem.ingredientID);
                    if (index != -1) {
                      items[index] = updatedItem; // Update the specific item
                    }
                  });
                }

                // Re-apply the current query/filter after returning
                if (query.isNotEmpty) {
                  searchItem(query);  // Re-apply the search/filter query
                } else {
                  setState(() {
                    items = allItems;  // Reset to full list if no filter is applied
                  });
                }
              },
              child: buildItem(item), // Your custom widget to display the item
            );
          },
        ),
      ),
      const SizedBox(height: 50),  // Add some space at the bottom
    ],
  ),
  floatingActionButton: FloatingActionButton.extended(
    onPressed: () => showAddIngredientAndInventoryDialog(context, () {
      // Refresh the inventory list after adding a new item
      init(); // Re-fetch the full list after a new item is added
    }),
    label: const Text(
      'Add Ingredient',
      style: TextStyle(
        color: Color(0xFFEEC07B),
        fontSize: 17,
      ),
    ),
    icon: const Icon(Icons.add),
    backgroundColor: const Color(0xFF422308),  // Dark brown background
    foregroundColor: const Color.fromARGB(255, 243, 217, 162),
  ),
  floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,


 // Center at the bottom

    // --------------------temporary code to delete items------------------------------
    //   floatingActionButton: Row(
    //     mainAxisAlignment: MainAxisAlignment.center,
    //     children: [
    //       FloatingActionButton.extended(
    //         heroTag: 'uniqueTag2',
    //         onPressed: () => showAddIngredientAndInventoryDialog(context, () {
    //           // Refresh the inventory list after adding new item
    //           setState(() {
    //             init();
    //           });
    //         }), // Open form for new ingredient
    //         label: const Text('Add Ingredient'),
    //         icon: const Icon(Icons.add),
    //         backgroundColor: const Color(0xFF422308),  // Dark brown background
    //         foregroundColor: const Color.fromARGB(255, 243, 217, 162),
    //       ),
    //       const SizedBox(width: 16),
    //       FloatingActionButton.extended(
    //         heroTag: 'uniqueTag1',
    //         onPressed: () {
    //           showDeleteIngredientDialog(context, () {
    //             setState(() {
    //               init();
    //             });
    //           });
    //         },
    //         label: const Text('Delete Ingredient'),
    //         icon: const Icon(Icons.delete),
    //         backgroundColor: const Color(0xFF422308),  // Dark brown background
    //         foregroundColor: const Color.fromARGB(255, 243, 217, 162),
    //       ),
    //     ],
    //   ),
    //   floatingActionButtonLocation:
    //       FloatingActionButtonLocation.centerFloat, // Center at the bottom
  );

  
// Search bar and filter button
Widget buildSearchWithFilter() => Row(
    
      children: [
        SizedBox(height: 5.0),
        Expanded(
          // The search widget takes up the remaining space
          child: SearchWidget(
            text: query,
            hintText: 'Search by Name',
            onChanged: searchItem,
          ),
        ),
        IconButton(
          icon: Icon(Icons.filter_list),
          color: Colors.brown,  // Adjust color to match your theme
          onPressed: () {
            // Open filter dialog or perform any filter action here
            _showFilterOptions();
          },
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
        item.ingredientName.toLowerCase().contains(query.toLowerCase())).toList();
  }

  setState(() {
    items = filteredItems;
    this.query = query; // Update query in state
  });
}

  // Build list tile for each inventory item
  Widget buildItem(Item item) => GestureDetector(
    onTap: () async {
      
  final updatedItem = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItemDetailPage(
          item: item,
          onItemUpdated: (updatedItem) {
            int index = items.indexWhere((i) => i.ingredientID == updatedItem.ingredientID);
            if (index != -1) {
              setState(() {
                items[index] = updatedItem; // Update the item list
              });
            }
          },
        ),
      ),
  );
  if (updatedItem != null) {
      setState(() {
        // Find the index of the item to update
        int index = items.indexWhere((i) => i.ingredientID == updatedItem.ingredientID);
        if (index != -1) {
          items[index] = updatedItem; // Update the existing item
          allItems[index] = updatedItem; // Ensure allItems is also updated
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
        child: Center(
          // Use Center to ensure the text is aligned properly within the card
          child: Text(
            item.ingredientName,
            style: const TextStyle(
              color: Color.fromARGB(255, 243, 217, 162),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    ),
  );
}

// Item Detail Page
class ItemDetailPage extends StatefulWidget {
  final Item item;
  final Function(Item)? onItemUpdated;
  const ItemDetailPage({super.key, required this.item,this.onItemUpdated});

  @override
  _ItemDetailPageState createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends State<ItemDetailPage> {
  late Item _item;

  @override
  void initState() {
    super.initState();
    _item = widget.item;
  }

  void _updateItem(Item updatedItem) async {
    
    setState(() {
      _item = updatedItem;
    });
    
  // Optionally re-fetch the product from the database
  final fetchedItem= await InventoryApi.fetchItemById(_item.entryID!);
  setState(() {
    _item = fetchedItem; // Update state with the freshly fetched product
  });
  if (widget.onItemUpdated != null) {
    widget.onItemUpdated!(fetchedItem); // Notify the parent about the updated product
  }
    
  }

  String formatDate(DateTime dateTime) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    return formatter.format(dateTime);
  }

  Widget _buildQuantityWarning(Item item) {
    if (item.quantity < item.minAmount) {
      return const Text(
        'QUANTITY IS VERY LOW! REORDER NOW!',
        style: TextStyle(fontSize: 18, color: Color(0xFF6D3200)),
      );
    } else if (item.quantity < item.reorderAmount) {
      return const Text(
        'Quantity is getting low. Please reorder!',
        style: TextStyle(fontSize: 18, color: Color(0xFF6D3200)),
      );
    }
    return const SizedBox(); // Return an empty widget if no warnings
  }

  @override
  Widget build(BuildContext context) {
  // Method to return the corresponding ingredient image for ingredient
    String getIngredientImage(int ingredientID) {
    // Mapping ingredientID to image file names
      Map<int, String> ingredientImages = {
        16: 'assets/flour.jpg',
        17: 'assets/flour.jpg',
        18: 'assets/sugar.jpg',
        19: 'assets/brown_sugar.jpg',
        20: 'assets/butter.jpg',
        21: 'assets/milk.jpg',
        22: 'assets/eggs.jpg',
        23: 'assets/baking_powder.jpg',
        24: 'assets/baking_soda.jpg',
        25: 'assets/yeast.jpg',
        26: 'assets/chocolate_chips.jpg',
        27: 'assets/vanilla.jpg',
        28: 'assets/cinnamon_sticks.jpg',
        29: 'assets/salt.jpg',
        30: 'assets/starter.jpg',
        31: 'assets/almond_flour.jpg',
        32: 'assets/raspberry_jam.jpg',
        33: 'assets/lemon_juice.jpg',
        34: 'assets/cocoa_powder.jpg',
        35: 'assets/honey.jpg',
        36: 'assets/water.jpg',
        37: 'assets/milk_chocolate.jpg',
        38: 'assets/dark_chocolate.jpg',
        39: 'assets/apples.jpg',
        75: 'assets/almonds.jpg', 
        77: 'assets/chocolate.jpg', 
        78: 'assets/confectionerssuagr.jpg',
        80: 'assets/eggwhite.jpg',
        79: 'assets/granulatedsuagr.jpg',
        74: 'assets/piecrust.jpg', 
        73: 'assets/pumpkinpuree.jpg', 
        76: 'assets/raspberryfilling.jpg', 

      };
    return ingredientImages[ingredientID] ?? 'assets/bread2.png';
  }

  return Scaffold(
    backgroundColor: const Color(0xFFF0D1A0),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _item.ingredientName,
            style: const TextStyle(
              fontSize: 30,
              color: Color(0xFF6D3200),
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.left,
          ),
          SizedBox(
            width: double.infinity,
            height: 250, // Set the height of the image
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(getIngredientImage(_item.ingredientID)),
                  fit: BoxFit.cover, // Cover the area while maintaining aspect ratio
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildDetailRow('Notes', _item.notes),
              buildDetailRow('Quantity', '${_item.quantity} ${_item.invMeasurement}'),
              buildDetailRow('Max Amount', _item.maxAmount.toString()),
              buildDetailRow('Reorder Amount', _item.reorderAmount.toString()),
              buildDetailRow('Min Amount', _item.minAmount.toString()),
              buildDetailRow('Cost', _item.cost.toString()),
              buildDetailRow('Created', formatDate(_item.createDateTime)),
              buildDetailRow('Expires', formatDate(_item.expireDateTime)),
            ],
          ),
          const SizedBox(height: 20),
          // Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  // Update action
                  showInventoryAndIngredientUpdateDialog(
                    context,
                    _item,
                    (updatedItem) {
                      _updateItem(updatedItem);
                      
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6D3200),
                  foregroundColor: const Color(0xFFF0D1A0),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add),
                    SizedBox(width: 8), // Spacing between image and text
                    Text('Update'),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: () async {
                  try {
                    final Vendor vendor =
                        await VendorsApi().fetchVendorDetails(_item.vendorID);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            VendorDetailsPage(vendor: vendor),
                      ),
                    );
                  } catch (e) {
                    print('Failed to load vendor details: $e');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6D3200),
                  foregroundColor: const Color(0xFFF0D1A0),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.business),
                    SizedBox(width: 8), // Spacing between image and text
                    Text('Vendor'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(0.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, true); // Close the page
                },
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(const Color(0xFF6D3200)),
                  foregroundColor:
                      MaterialStateProperty.all(const Color(0xFFEEC07B)),
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50.0),
                  )),
                ),
                child: const Text(
                  'Close',
                  style: TextStyle(
                    fontSize: 17, // Font size
                    color: Color(0xFFEEC07B), // Light brown text
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget buildDetailRow(String label, String value) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: Color(0xFF6D3200),
        ),
      ),
      Text(
        value,
        style: const TextStyle(
          fontSize: 18,
          color: Color(0xFF6D3200),
        ),
      ),
      const SizedBox(height: 4), // Adjust the space between label and value
    ],
  );
}
}