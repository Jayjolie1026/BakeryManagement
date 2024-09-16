import 'dart:async';
import 'package:flutter/material.dart';
import 'inventoryItemClass.dart';
import 'inventoryAPI.dart';
import 'inventoryFunctions.dart';
import 'inventorySearchWidget.dart';

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
    hintText: 'Search by Name',
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
    color: const Color(0xFF6D3200),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(50),
    ),
    margin: const EdgeInsets.fromLTRB(30, 0, 30, 10),
    elevation: 4,
    child: GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ItemDetailPage(
              item: item,
            ),
          ),
        );
      if (result == true) {
        init();
      }
    },
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              item.ingredientName,
              style: const TextStyle(
                color: Color.fromARGB(255, 243, 217, 162),
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
      appBar: AppBar(
        title: Text(_item.ingredientName),
        backgroundColor: const Color(0xFFF0d1a0),
        foregroundColor:  const Color(0xFF6D3200),
        iconTheme: const IconThemeData(color: Color(0xFF6D3200)),
      ),
      backgroundColor: const Color(0xFFF0d1a0),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Centered Image
            Container(
              height: 150,
              width: 150,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AssetImage('assets/bread2.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Display Product Information
            Text('Name: ${_item.ingredientName}', style: const TextStyle(fontSize: 18, color: Color(0xFF6D3200))),
            Text('Notes: ${_item.notes}', style: const TextStyle(fontSize: 18, color: Color(0xFF6D3200))),
            Text('Quantity: ${_item.quantity}', style: const TextStyle(fontSize: 18, color: Color(0xFF6D3200))),
            Text('Max Amount: ${_item.maxAmount}', style: const TextStyle(fontSize: 18, color: Color(0xFF6D3200))),
            Text('Reorder Amount: ${_item.reorderAmount}', style: const TextStyle(fontSize: 18, color: Color(0xFF6D3200))),
            Text('Min Amount: ${_item.minAmount}', style: const TextStyle(fontSize: 18, color: Color(0xFF6D3200))),
            Text('Cost: ${_item.cost}', style: const TextStyle(fontSize: 18, color: Color(0xFF6D3200))),
            Text('Entry Date: ${formatDate(_item.createDateTime)}'),
            Text('Expiration Date: ${formatDate(_item.expireDateTime)}'),
            _buildQuantityWarning(_item),


            const SizedBox(height: 20),
            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    // // Navigate to the update page and wait for result
                    // final updatedProduct = await Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => ProductUpdatePage(
                    //       product: _item,
                    //       onProductUpdated: _updateProduct,
                    //     ),
                    //   ),
                    // );
                    //
                    // // If an updated product was returned, update the state
                    // if (updatedProduct != null) {
                    //   _updateProduct(updatedProduct);
                    //   Navigator.pop(context, true); // Pass true to indicate an update
                    // }
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}

