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
          onPressed: () => showAddIngredientAndInventoryDialog(context, () {
            // Refresh the inventory list after adding new item
            setState(() {
              init();
            });
          }), // Open form for new ingredient
          label: const Text('Add Ingredient',
          style: const TextStyle(
            color: Color(0xFFEEC07B),
            fontSize: 17,
          ),
          ),
          icon: const Icon(Icons.add),
          backgroundColor: const Color(0xFF422308), // Dark brown background
          foregroundColor: const Color.fromARGB(255, 243, 217, 162),
        ),
        floatingActionButtonLocation:
            FloatingActionButtonLocation.centerFloat, // Center at the bottom

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

  // Search bar widget
  Widget buildSearch() => SearchWidget(
      text: query, hintText: 'Search by Name', onChanged: searchItem);

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
  Widget buildItem(Item item) => GestureDetector(
    onTap: () async {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ItemDetailPage(item: item),
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

  const ItemDetailPage({super.key, required this.item});

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

  void _updateItem(Item updatedItem) {
    setState(() {
      _item = updatedItem;
    });
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
      // Add more mappings for other ingredients
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