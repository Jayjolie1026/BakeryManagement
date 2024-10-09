import 'dart:async';
import 'package:bakery_management/pages/tasksAPI.dart';

import 'vendorsItemClass.dart';
import 'bakedgoods.dart';
import 'package:flutter/material.dart';
import 'inventoryItemClass.dart';
import 'inventoryAPI.dart';
import 'inventoryFunctions.dart';
import 'package:intl/intl.dart';
import 'vendors.dart';
import 'vendorsAPI.dart';
import 'sessions.dart';
import 'package:bakery_management/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bakery_management/pages/tasksFunctions.dart';
import 'package:bakery_management/pages/tasksItemClass.dart';


class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  _InventoryPageState createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  List<InventoryItem> items = [];
  List<InventoryItem> allItems = [];  // This holds all items
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
  

  Future<void> navigateToDetailPage(InventoryItem item) async {
    // Push to the detail page and wait for the result
    final updatedItem = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItemDetailPage(item: item), // Replace with your actual detail page
      ),
    );

    // If updatedItem is returned (i.e., the item was updated), refresh the item in the list
    if (updatedItem != null) {
      setState(() {
        // Find the index of the item and update it in the list
        int index = items.indexWhere((i) => i.ingredientID == updatedItem.ingredientID);
        if (index != -1) {
          items[index] = updatedItem; // Update the specific item
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
        const SizedBox(height: 25.0),
        // Search bar with filter
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
                  navigateToDetailPage(item); // Call the navigateToDetailPage function
                },
                child: buildItem(item), // Your custom widget to display the item
              );
            },
          ),
        ),
        const SizedBox(height: 80),  // Add some space at the bottom
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
    // Center at the bottom
    floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
  );

  
  // Search bar and filter button
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
        padding: const EdgeInsets.fromLTRB(0, 0, 25, 15), // Add some padding if needed
        alignment: Alignment.center, // Center the icon vertically
        child: IconButton(
          icon: const Icon(Icons.filter_list),
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
            // Open filter dialog or perform any filter action here
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
          title: const Text(
            'Filter by Category',
            style: TextStyle(
              color: Color(0xFF6D3200), // Set the title text color
            ),
          ),
          content: SingleChildScrollView( // Make content scrollable
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: categories.map((category) {
                return ListTile(
                  title: Text(
                    category,
                    style: const TextStyle(
                      color: Color(0xFF6D3200), // Set the ListTile text color
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
              icon: const Icon(Icons.close, color: Color(0xFF422308)), // Set the close button icon color
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
    List<InventoryItem> filteredItems;

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
  Widget buildItem(InventoryItem item) => GestureDetector(
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
              color: Color(0xFFEEC07B),
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
  final InventoryItem item;
  final Function(InventoryItem)? onItemUpdated;
  const ItemDetailPage({super.key, required this.item,this.onItemUpdated});

  @override
  _ItemDetailPageState createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends State<ItemDetailPage> {
  late InventoryItem _item;

  @override
  void initState() {
    super.initState();
    _item = widget.item;
  }

  void _updateItem(InventoryItem updatedItem) async {
    // Preserve the entryID before updating
    final int preservedEntryID = _item.entryID!;

    setState(() {
      _item = updatedItem;
      _item.entryID = preservedEntryID;  // Ensure entryID is not lost
    });

    // Optionally re-fetch the product from the database
    try {
      final fetchedItem = await InventoryApi.fetchItemById(preservedEntryID);
      setState(() {
        _item = fetchedItem;  // Update state with the fetched product
      });
    } catch (error) {
      // error
    }

    if (widget.onItemUpdated != null) {
      widget.onItemUpdated!(_item);  // Notify parent widget with the updated item
    }
  }

  String formatDate(DateTime dateTime) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    return formatter.format(dateTime);
  }
  Future<List<Task>> checkTasks() async {
   List<Task> existingTasks = await getTasks();
   return existingTasks;
       
  }

  Widget _buildQuantityWarning(InventoryItem item) {
    return FutureBuilder<List<Task>>(
      future: checkTasks(), // Fetch the existing tasks
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {
          List<Task> existingTasks = snapshot.data!;

          // Check for quantity below minimum amount
          if (item.quantity < item.minAmount) {
            final dueDate = DateTime.now().add(Duration(days: 1));
            final description = 'Need to reorder ${item.ingredientName}, quantity below min amount';
            const assignedBy = 'f4f5101a-48a1-42b9-b99d-cdc66b7d8761';

            // Log existing tasks for debugging
            for (var task in existingTasks) {
              print('Description: ${task.description}, Due Date: ${task.dueDate}');
            }

            // Check if a task for this item already exists
            bool taskExists = existingTasks.any((task) =>
              task.description == description ||
              task.dueDate.toIso8601String() == dueDate.toIso8601String());

            if (!taskExists) {
              addTask(description: description, dueDate: dueDate, assignedBy: assignedBy);
            } else {
              print('Task already exists for ${item.ingredientName}, skipping task creation.');
            }

            return const Text(
              'QUANTITY IS VERY LOW! REORDER NOW!',
              style: TextStyle(fontSize: 18, color: Color(0xFF6D3200)),
            );
          }

          // Check for quantity below reorder amount
          else if (item.quantity < item.reorderAmount) {
            final dueDate = DateTime.now().add(Duration(days: 5));
            final description = 'Need to reorder ${item.ingredientName}, quantity below reorder amount';
            const assignedBy = 'f4f5101a-48a1-42b9-b99d-cdc66b7d8761';

            // Check if a task for this item already exists
            bool taskExists = existingTasks.any((task) =>
              task.description == description &&
              task.dueDate.toIso8601String() == dueDate.toIso8601String());

            if (!taskExists) {
              addTask(description: description, dueDate: dueDate, assignedBy: assignedBy);
            } else {
              print('Task already exists for ${item.ingredientName}, skipping task creation.');
            }

            return const Text(
              'Quantity is getting low. Please reorder!',
              style: TextStyle(fontSize: 18, color: Color(0xFF6D3200)),
            );
          }
        }

        return const SizedBox(); // Return empty widget if no warnings
      },
    );
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
                buildDetailRow('IngredientID', (_item.ingredientID).toString()),
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
                      // error
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
                        WidgetStateProperty.all(const Color(0xFF6D3200)),
                    foregroundColor:
                        WidgetStateProperty.all(const Color(0xFFEEC07B)),
                    shape: WidgetStateProperty.all(RoundedRectangleBorder(
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