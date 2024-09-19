import 'dart:async';
import 'package:flutter/material.dart';
import 'inventoryItemClass.dart';
import 'inventoryAPI.dart';
import 'inventoryFunctions.dart';
import 'package:intl/intl.dart';
import 'vendors.dart';

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
                padding: const EdgeInsets.only(bottom: 80),
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
          onPressed: () => showAddIngredientDialog(context, () {
            // Refresh the inventory list after adding new item
            setState(() {
              init();
            });
          }), // Open form for new ingredient
          label: const Text('Add Ingredient'),
          icon: const Icon(Icons.add),
          backgroundColor: const Color(0xFF6D3200),
          foregroundColor: const Color.fromARGB(255, 243, 217, 162),
        ),
        floatingActionButtonLocation:
            FloatingActionButtonLocation.centerFloat, // Center at the bottom
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
      appBar: AppBar(
        title: Text(_item.ingredientName),
        backgroundColor: const Color(0xFFF0d1a0),
        foregroundColor: const Color(0xFF6D3200),
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
                    final updatedItem = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ItemUpdatePage(
                          item: _item,
                          onItemUpdated: _updateItem,
                        ),
                      ),
                    );

                    // If an updated product was returned, update the state
                    if (updatedItem != null) {
                      _updateItem(updatedItem);
                      Navigator.pop(
                          context, true); // Pass true to indicate an update
                    }
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
                const SizedBox(width: 4), // Spacer between Update and Vendor
                // Vendor button
                ElevatedButton(
                  onPressed: () {
                    // Navigate to the Vendor page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VendorsPage(), // TODO: send user to corresponding vendor
                      ),
                    );
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
          ],
        ),
      ),
    );
  }
}

class ItemUpdatePage extends StatefulWidget {
  final Item item;
  final ValueChanged<Item> onItemUpdated;

  const ItemUpdatePage(
      {super.key, required this.item, required this.onItemUpdated});

  @override
  _ItemUpdatePageState createState() => _ItemUpdatePageState();
}

class _ItemUpdatePageState extends State<ItemUpdatePage> {
  late TextEditingController _nameController;
  late TextEditingController _notesController;
  late TextEditingController _quantityController;
  late TextEditingController _maxAmountController;
  late TextEditingController _reorderAmountController;
  late TextEditingController _minAmountController;
  late TextEditingController _costController;
  late TextEditingController _vendorIDController;
  late DateTime _createDateTime;
  late DateTime _expireDateTime;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item.ingredientName);
    _notesController = TextEditingController(text: widget.item.notes);
    _quantityController =
        TextEditingController(text: widget.item.quantity.toString());
    _maxAmountController =
        TextEditingController(text: widget.item.maxAmount.toString());
    _reorderAmountController =
        TextEditingController(text: widget.item.reorderAmount.toString());
    _minAmountController =
        TextEditingController(text: widget.item.minAmount.toString());
    _costController = TextEditingController(text: widget.item.cost.toString());
    _vendorIDController =
        TextEditingController(text: widget.item.vendorID.toString());
    _createDateTime = widget.item.createDateTime;
    _expireDateTime = widget.item.expireDateTime;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    _quantityController.dispose();
    _maxAmountController.dispose();
    _reorderAmountController.dispose();
    _minAmountController.dispose();
    _costController.dispose();
    super.dispose();
  }

  // Format DateTime for display
  String formatDate(DateTime dateTime) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    return formatter.format(dateTime);
  }

  // Show DatePicker to select Date
  Future<void> _selectDate(BuildContext context, DateTime initialDate,
      ValueChanged<DateTime> onDateSelected) async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (selectedDate != null && selectedDate != initialDate) {
      setState(() {
        onDateSelected(selectedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update item'),
        backgroundColor: const Color(0xFFF0d1a0),
        foregroundColor: const Color(0xFF6D3200),
        iconTheme: const IconThemeData(color: Color(0xFF6D3200)),
      ),
      backgroundColor: const Color(0xFFF0d1a0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Editable Fields
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Color(0xFF6D3200)),
              decoration: const InputDecoration(
                labelText: 'Ingredient Name',
                labelStyle: TextStyle(color: Color(0xFF6D3200)),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: Color(0xFF6D3200)), // Focused border color
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: Color(0xFF6D3200)), // Enabled border color
                ),
              ),
            ),
            TextField(
              controller: _notesController,
              style: const TextStyle(color: Color(0xFF6D3200)),
              decoration: const InputDecoration(
                labelText: 'Notes',
                labelStyle: TextStyle(color: Color(0xFF6D3200)),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: Color(0xFF6D3200)), // Focused border color
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: Color(0xFF6D3200)), // Enabled border color
                ),
              ),
            ),
            TextField(
              controller: _quantityController,
              style: const TextStyle(color: Color(0xFF6D3200)),
              decoration: const InputDecoration(
                labelText: 'Quantity',
                labelStyle: TextStyle(color: Color(0xFF6D3200)),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: Color(0xFF6D3200)), // Focused border color
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: Color(0xFF6D3200)), // Enabled border color
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _maxAmountController,
              style: const TextStyle(color: Color(0xFF6D3200)),
              decoration: const InputDecoration(
                labelText: 'Max Amount',
                labelStyle: TextStyle(color: Color(0xFF6D3200)),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: Color(0xFF6D3200)), // Focused border color
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: Color(0xFF6D3200)), // Enabled border color
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _reorderAmountController,
              style: const TextStyle(color: Color(0xFF6D3200)),
              decoration: const InputDecoration(
                labelText: 'Reorder Amount',
                labelStyle: TextStyle(color: Color(0xFF6D3200)),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: Color(0xFF6D3200)), // Focused border color
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: Color(0xFF6D3200)), // Enabled border color
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _minAmountController,
              style: const TextStyle(color: Color(0xFF6D3200)),
              decoration: const InputDecoration(
                labelText: 'Min Amount',
                labelStyle: TextStyle(color: Color(0xFF6D3200)),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: Color(0xFF6D3200)), // Focused border color
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: Color(0xFF6D3200)), // Enabled border color
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _costController,
              style: const TextStyle(color: Color(0xFF6D3200)),
              decoration: const InputDecoration(
                labelText: 'Cost',
                labelStyle: TextStyle(color: Color(0xFF6D3200)),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: Color(0xFF6D3200)), // Focused border color
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: Color(0xFF6D3200)), // Enabled border color
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _vendorIDController,
              style: const TextStyle(color: Color(0xFF6D3200)),
              decoration: const InputDecoration(
                labelText: 'Vendor ID',
                labelStyle: TextStyle(color: Color(0xFF6D3200)),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: Color(0xFF6D3200)), // Focused border color
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: Color(0xFF6D3200)), // Enabled border color
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            Text('Create Date: ${formatDate(_createDateTime)}'),
            TextButton(
                onPressed: () => _selectDate(context, _createDateTime, (date) {
                      _createDateTime = date;
                    }),
                child: const Text('Change Create Date')),
            const SizedBox(height: 16),
            Text('Expire Date: ${formatDate(_expireDateTime)}'),
            TextButton(
                onPressed: () => _selectDate(context, _expireDateTime, (date) {
                      _expireDateTime = date;
                    }),
                child: const Text('Change Expire Date')),
            const SizedBox(height: 20),
            // Buttons
            ElevatedButton(
              onPressed: () async {
                // Update the item with new values
                final updatedItem = Item(
                  entryID: widget.item.entryID, // Keep the same item ID
                  ingredientName: _nameController.text,
                  quantity: int.parse(_quantityController.text),
                  notes: _notesController.text,
                  maxAmount: double.parse(_maxAmountController.text),
                  reorderAmount: double.parse(_reorderAmountController.text),
                  minAmount: double.parse(_minAmountController.text),
                  cost: double.parse(_costController.text),
                  createDateTime: _createDateTime,
                  expireDateTime: _expireDateTime,
                  vendorID: int.parse(_vendorIDController.text),
                );

                // Call update API
                await InventoryApi.updateItem(updatedItem);

                // Notify parent widget of the update
                widget.onItemUpdated(updatedItem);

                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Item updated successfully!')),
                );

                // Navigate back to the previous page with the updated product
                Navigator.of(context).pop(updatedItem);
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
          ],
        ),
      ),
    );
  }
}
