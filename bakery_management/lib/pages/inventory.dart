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
    appBar: AppBar(
      toolbarHeight: 125,
      title: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/inventory_logo.png',
            height: 150,
          ),
          const SizedBox(height: 10),
        ],
      ),
      centerTitle: true,
      backgroundColor: const Color(0xFFF0D1A0),
      iconTheme: const IconThemeData(
        color: Color(0xFF6D3200), // Set your desired back button color (dark brown)
  ),
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
    return Scaffold(
      backgroundColor: const Color(0xFFF0d1a0),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Item name as a header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _item.ingredientName,
                  style: const TextStyle(
                    fontSize: 30,
                    color: Color(0xFF6D3200),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Centered Image
              Container(
                height: 150,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/bread2.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Display Product Information
                      Text('Name: ${_item.ingredientName}',
                          style: const TextStyle(fontSize: 18, color: Color(0xFF6D3200))),
                      Text('Notes: ${_item.notes}',
                          style: const TextStyle(fontSize: 18, color: Color(0xFF6D3200))),
                      Text('Quantity: ${_item.quantity}',
                          style: const TextStyle(fontSize: 18, color: Color(0xFF6D3200))),
                      Text('Max Amount: ${_item.maxAmount}',
                          style: const TextStyle(fontSize: 18, color: Color(0xFF6D3200))),
                      Text('Reorder Amount: ${_item.reorderAmount}',
                          style: const TextStyle(fontSize: 18, color: Color(0xFF6D3200))),
                      Text('Min Amount: ${_item.minAmount}',
                          style: const TextStyle(fontSize: 18, color: Color(0xFF6D3200))),
                      Text('Cost: ${_item.cost}',
                          style: const TextStyle(fontSize: 18, color: Color(0xFF6D3200))),
                      Text('Created: ${formatDate(_item.createDateTime)}',
                          style: const TextStyle(fontSize: 18, color: Color(0xFF6D3200))),
                      Text('Expires: ${formatDate(_item.expireDateTime)}',
                          style: const TextStyle(fontSize: 18, color: Color(0xFF6D3200))),
                    ],
                  ),
                ),
              ),
              _buildQuantityWarning(_item),
              const SizedBox(height: 20),
              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Update button
                  ElevatedButton(
                    onPressed: () async {
                      // Navigate to the update page and wait for result
                      showInventoryAndIngredientUpdateDialog(
                        context,
                        _item, // Pass the product you want to update
                            (updatedItem) {
                          _updateItem(updatedItem);
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6D3200),
                      foregroundColor: const Color(0xFFF0d1a0),
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
                  // Vendor button
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        // Assuming _item.vendorID holds the vendor ID
                        final Vendor vendor =
                            await VendorsApi().fetchVendorDetails(_item.vendorID);

                        // After successfully fetching the vendor, navigate to the VendorDetailsPage
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                VendorDetailsPage(vendor: vendor),
                          ),
                        );
                      } catch (e) {
                        // Handle the error if the vendor details couldn't be fetched
                        print('Failed to load vendor details: $e');
                        // You might want to show an error dialog or message to the user
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Error'),
                            content: const Text('Failed to load vendor details.'),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('OK'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6D3200),
                      foregroundColor: const Color(0xFFF0d1a0),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.store),
                        SizedBox(width: 8), // Spacing between icon and text
                        Text('Vendor'),
                      ],
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, true); // Close the page
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(const Color(0xFF6D3200)), // Dark brown background
                      foregroundColor: WidgetStateProperty.all(const Color(0xFFEEC07B)), // Light brown text
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
              )
            ],
          ),
        ),
      ),
    );
  }
}