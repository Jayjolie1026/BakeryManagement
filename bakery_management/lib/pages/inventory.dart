import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// user model for inventory items
class Item {
  final int item_id;
  final String item_name;
  final int quantity;
  final double price;
  final int calories;
  final DateTime created_at;
  final DateTime expiration_date;

  // Constructor
  Item({
    required this.item_id,
    required this.item_name,
    required this.quantity,
    required this.price,
    required this.calories,
    required this.created_at,
    required this.expiration_date,
  });

  // A factory constructor to create an Item from a JSON object
  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      item_id: json['item_id'],
      item_name: json['item_name'],
      quantity: json['quantity'],
      price: json['price'].toDouble(), // Convert to double if needed
      calories: json['calories'],
      created_at: DateTime.parse(json['created_at']),
      expiration_date: DateTime.parse(json['expiration_date']),
    );
  }

  Map<String, dynamic> toJson() => {
    'item_id': item_id,
    'item_name': item_name,
    'quantity': quantity,
    'price': price,
    'calories': calories,
    'created_at': created_at,
    'expiration_date': expiration_date,
  };
}

// api call to get all and queried items
class InventoryApi {
  static Future<List<Item>> getItems(String query) async {
    final _apiUrl = Uri.parse('https://bakerymanagement-efgmhebnd5aggagn.eastus-01.azurewebsites.net/inventory');
    final response = await http.get(_apiUrl);

    if (response.statusCode == 200) {
      final List items = json.decode(response.body);

      return items.map((json) => Item.fromJson(json)).where((item) {
        final nameLower = item.item_name.toLowerCase();
        final searchLower = query.toLowerCase();

        return nameLower.contains(searchLower);
      }).toList();
    } else {
      throw Exception();
    }
  }
}

// display page
class InventoryPage extends StatefulWidget {
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

  // timer for refreshing search bar
  void debounce(
      VoidCallback callback, {
        Duration duration = const Duration(microseconds: 1000),
  }) {
    if (debouncer != null) {
      debouncer!.cancel();
    }
    debouncer = Timer(duration, callback);
  }

  // default state, all items
  Future init() async {
    final items = await InventoryApi.getItems(query);
    setState(() => this.items = items);
  }

  // actual inventory page
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar (
      title: Image.asset(
        'assets/inventory_logo.png',
        height: 60,
      ),
      centerTitle: true,
    ),
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
  );

  // search bar widget
  Widget buildSearch() => SearchWidget(
      text: query,
      hintText: 'Item Name',
      onChanged: searchItem,
    );

  Future searchItem(String query) async => debounce(() async {
    final items = await InventoryApi.getItems(query);

    if (!mounted) return;

    setState(() {
      this.query = query;
      this.items = items;
    });
  });

  // tiles for items being searched
  Widget buildItem(Item item) => ListTile(
    title: Text(item.item_name),
  );
}

// search widget
class SearchWidget extends StatefulWidget {
  final String text;
  final ValueChanged<String> onChanged;
  final String hintText;

  const SearchWidget({
    Key? key,
    required this.text,
    required this.onChanged,
    required this.hintText,
  }) : super(key: key);

  @override
  _SearchWidgetState createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final styleActive = TextStyle(color: Colors.black);
    final styleHint = TextStyle(color: Colors.black54);
    final style = widget.text.isEmpty ? styleHint : styleActive;

    return Container(
      height: 42,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        border: Border.all(color: Colors.black26),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
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