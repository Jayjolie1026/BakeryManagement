import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Product model for final products
class Product {
  final int productID;
  final String name;
  final int maxAmount;
  final int minAmount;
  final int quantity;
  final double price;

  // Constructor
  Product({
    required this.productID,
    required this.name,
    required this.maxAmount,
    required this.minAmount,
    required this.quantity,
    required this.price,
  });

  // Factory constructor to create a Product from a JSON object
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productID: json['ProductID'],
      name: json['Name'] ?? '', // Default to empty string if null
      maxAmount: json['MaxAmount'].toInt(),  // Extract MaxAmount
      minAmount: json['MinAmount'].toInt(),  // Extract MinAmount
      quantity: json['Quantity'].toInt(),    // Extract Quantity
      price: json['Price'].toDouble(),        // Extract Price
    );
  }

  // Convert Product object to JSON format
  Map<String, dynamic> toJson() => {
        'ProductID': productID,
        'Name': name, // Add Name to JSON
        'MaxAmount': maxAmount,
        'MinAmount': minAmount,
        'Quantity': quantity,
        'Price': price,
      };
}

// API class for final products
class ProductApi {
  static Future<List<Product>> getProducts(String query) async {
    final apiUrl = Uri.parse('https://bakerymanagement-efgmhebnd5aggagn.eastus-01.azurewebsites.net/finalproducts');
    final response = await http.get(apiUrl);

    if (response.statusCode == 200) {
      final List products = json.decode(response.body);

      return products.map((json) => Product.fromJson(json)).where((product) {
        final nameLower = product.name.toLowerCase();
        final searchLower = query.toLowerCase();

        return nameLower.contains(searchLower);
      }).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }
}

// Products Page
class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  List<Product> products = [];
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

  // Initialize products
  Future init() async {
    final products = await ProductApi.getProducts(query);
    setState(() => this.products = products);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Image.asset(
            'assets/bakedgoods.png',
            height: 60,
          ),
          centerTitle: true,
        ),
        body: Column(
          children: <Widget>[
            buildSearch(),
            Expanded(
              child: ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return buildProduct(product);
                },
              ),
            ),
          ],
        ),
      );

  // Search bar widget
  Widget buildSearch() => SearchWidget(
        text: query,
        hintText: 'Search by Name',
        onChanged: searchProduct,
      );

  // Search for a product by query
  Future searchProduct(String query) async => debounce(() async {
        final products = await ProductApi.getProducts(query);

        if (!mounted) return;

        setState(() {
          this.query = query;
          this.products = products;
        });
      });

  // Build list tile for each product
  Widget buildProduct(Product product) => ListTile(
        title: Text(product.name), // Display name
        subtitle: Text('Price: \$${product.price}'), // Display price
        trailing: Text('Quantity: ${product.quantity}'),
       onTap: () {
        // Handle the tap event, e.g., navigate to a detail page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(product: product),
          ),
        );
      },
    );
}

// Search widget component
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
  Widget build(BuildContext context) {
    final styleActive = const TextStyle(color: Colors.black);
    final styleHint = const TextStyle(color: Colors.black54);
    final style = widget.text.isEmpty ? styleHint : styleActive;

    return Container(
      height: 42,
      margin: const EdgeInsets.all(16),
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

// Product Detail Page
class ProductDetailPage extends StatelessWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${product.name}', style: TextStyle(fontSize: 20)),
            Text('Price: \$${product.price}', style: TextStyle(fontSize: 20)),
            Text('Quantity: ${product.quantity}', style: TextStyle(fontSize: 20)),
            Text('Max Amount: ${product.maxAmount}', style: TextStyle(fontSize: 20)),
            Text('Min Amount: ${product.minAmount}', style: TextStyle(fontSize: 20)),
          ],
        ),
      ),
    );
  }
}
