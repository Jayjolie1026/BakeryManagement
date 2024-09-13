import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:bakery_management/pages/recipe.dart';

// Product model for final products
class Product {
  int? productID;
  final String name;
  final String description;
  final double maxAmount;
  final double remakeAmount;
  final double minAmount;
  final int quantity;
  final double price;

  // Constructor
  Product({
    this.productID,
    required this.name,
    required this.description,
    required this.maxAmount,
    required this.remakeAmount,
    required this.minAmount,
    required this.quantity,
    required this.price,
  });

  // Factory constructor to create a Product from a JSON object
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productID: json['ProductID'],
      name: json['Name'] ?? '', // Default to empty string if null
      description: json['Description'] ?? '',
      maxAmount: json['MaxAmount'].toDouble(),  // Extract MaxAmount
      remakeAmount: json["RemakeAmount"].toDouble(),
      minAmount: json['MinAmount'].toDouble(),  // Extract MinAmount
      quantity: json['Quantity'].toInt(),    // Extract Quantity
      price: json['Price'].toDouble(),        // Extract Price
    );
  }

  // Convert Product object to JSON format
  Map<String, dynamic> toJson() => {
        'ProductID': productID,
        'Name': name, // Add Name to JSON
        'Description' : description,
        'MaxAmount': maxAmount,
        'RemakeAmount': remakeAmount,
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

  static Future<void> addFinalProduct(Product product) async {
    final url = Uri.parse('https://bakerymanagement-efgmhebnd5aggagn.eastus-01.azurewebsites.net/finalproducts');

    final body = jsonEncode({
   "name": product.name,
    "description": product.description,
    "maxAmount": product.maxAmount,
    "remakeAmount": product.remakeAmount,
    "minAmount": product.minAmount,
    "quantity": product.quantity,
    "price": product.price
  });
    print('Request body: $body');


  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 201) {
      print('Final product created successfully');
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      product.productID = responseData['ProductID'];

      print('Final product created successfully with ProductID: ${product.productID}');
    } else {
      print('Failed to create final product: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  } catch (e) {
    print('Error occurred: $e');
  }

  }


  static Future<void> deleteProduct(int productID) async {
  final response = await http.delete(
    Uri.parse('https://bakerymanagement-efgmhebnd5aggagn.eastus-01.azurewebsites.net/finalproducts/$productID'),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to delete product');
  }
}


 static Future<void> updateProduct(Product product) async {
  final url = Uri.parse('https://bakerymanagement-efgmhebnd5aggagn.eastus-01.azurewebsites.net/finalproducts/${product.productID}');
  final response = await http.put(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(product.toJson()),
  );
  print('Response status: ${response.statusCode}');
  print('Update request body: ${jsonEncode(product.toJson())}');

  if (response.statusCode != 200) {
    throw Exception('Failed to update product');
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
    init(); // Call the init method when the widget is initialized
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

  // Initialize and load products
  Future<void> init() async {
    try {
      final products = await ProductApi.getProducts(query);
      if (mounted) { // Check if the widget is still mounted
        setState(() => this.products = products);
      }
    } catch (e) {
      // Handle the error if needed
      print('Failed to load products: $e');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Image.asset(
        'assets/bakedgoods.png',
        height: 60,
      ),
      centerTitle: true,
      backgroundColor: const Color(0xFFF0d1a0),
    ),
    backgroundColor: const Color(0xFFF0d1a0),
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
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () => showAddProductDialog(context, () {
        // Refresh the product list after adding a new product
        setState(() {
          init(); // Call init to reload products
        });
      }),
      label: const Text('Add Product'),
      icon: const Icon(Icons.add),
      backgroundColor: const Color.fromARGB(255, 243, 217, 162),
    ),
    floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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
  Widget buildProduct(Product product) => Card(
    color: const Color(0xFFEEC07B),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(50), // Circular shape
    ),
    margin: const EdgeInsets.fromLTRB(30, 0, 30, 10),
    elevation: 4,
    child: GestureDetector(
      onTap: () {
        // Navigate to product detail page on tap
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(product: product),
          ),
        );
      },
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
        child: Center(
          child: Text(
            product.name,
            style: const TextStyle(
              color: Color(0xFF6D3200),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    ),
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
  void initState() {
    super.initState();
    controller.text = widget.text;
  }

  @override
  Widget build(BuildContext context) {
    const styleActive = TextStyle(color: Colors.black);
    const styleHint = TextStyle(color: Colors.black54);
    final style = widget.text.isEmpty ? styleHint : styleActive;

    return Container(
      height: 50,
      margin: const EdgeInsets.fromLTRB(30, 0, 30, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: const Color(0xFFD8C4AA),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
class ProductDetailPage extends StatefulWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _maxAmountController;
  late TextEditingController _remakeAmountController;
  late TextEditingController _minAmountController;
  late TextEditingController _priceController;
  late TextEditingController _quantityController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _descriptionController = TextEditingController(text: widget.product.description);
    _maxAmountController = TextEditingController(text: widget.product.maxAmount.toString());
    _remakeAmountController = TextEditingController(text: widget.product.remakeAmount.toString());
    _minAmountController = TextEditingController(text: widget.product.minAmount.toString());
    _priceController = TextEditingController(text: widget.product.price.toString());
    _quantityController = TextEditingController(text: widget.product.quantity.toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _maxAmountController.dispose();
    _remakeAmountController.dispose();
    _minAmountController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name),
        backgroundColor: const Color(0xFFF0d1a0),
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
            // Editable Fields
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: _maxAmountController,
              decoration: const InputDecoration(labelText: 'Max Amount'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _remakeAmountController,
              decoration: const InputDecoration(labelText: 'Remake Amount'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _minAmountController,
              decoration: const InputDecoration(labelText: 'Min Amount'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _quantityController,
              decoration: const InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    // Update the product with new values
                    final updatedProduct = Product(
                      productID: widget.product.productID, // Keep the same product ID
                      name: _nameController.text,
                      description: _descriptionController.text,
                      maxAmount: double.parse(_maxAmountController.text),
                      remakeAmount: double.parse(_remakeAmountController.text),
                      minAmount: double.parse(_minAmountController.text),
                      quantity: int.parse(_quantityController.text),
                      price: double.parse(_priceController.text),
                    );

                    // Call update API
                    await ProductApi.updateProduct(updatedProduct);

                    // Show success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Product updated successfully!')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6D3200),
                  ),
                  child: const Text('Update'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to recipe page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecipePage(product: widget.product),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6D3200),
                  ),
                  child: const Text('Recipe'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}



void showAddProductDialog(BuildContext context,VoidCallback onProductAdded) {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final maxAmountController = TextEditingController();
  final remakeAmountController = TextEditingController();
  final minAmountController = TextEditingController();
  final quantityController = TextEditingController();
  final priceController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Add New Product'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
             TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: maxAmountController,
              decoration: const InputDecoration(labelText: 'Max Amount'),
              keyboardType: TextInputType.number,
            ),
             TextField(
              controller: remakeAmountController,
              decoration: const InputDecoration(labelText: 'Remake Amount'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: minAmountController,
              decoration: const InputDecoration(labelText: 'Min Amount'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: quantityController,
              decoration: const InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            // Create a new Product instance
            final product = Product(
              productID: 0, // You can adjust this depending on your API requirements
              name: nameController.text,
              description: descriptionController.text,
              maxAmount: double.tryParse(maxAmountController.text) ?? 0,
              remakeAmount: double.tryParse(remakeAmountController.text) ?? 0,
              minAmount: double.tryParse(minAmountController.text) ?? 0,
              quantity: int.tryParse(quantityController.text) ?? 0,
              price: double.tryParse(priceController.text) ?? 0.0,
            );

            // Add the new product using the API
            await ProductApi.addFinalProduct(product);
            onProductAdded(); // Refresh the product list


            // Close the dialog
            Navigator.of(context).pop();
          },
          child: const Text('Add'),
        ),
      ],
    ),
  );
}
