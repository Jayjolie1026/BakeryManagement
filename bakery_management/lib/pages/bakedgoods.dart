import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:bakery_management/pages/recipe.dart';

// Product model for final products
class Product {
  final int productID;
  final String name;
  final String description;
  final int maxAmount;
  final int minAmount;
  final int quantity;
  final double price;

  // Constructor
  Product({
    required this.productID,
    required this.name,
    required this.description,
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
      description: json['Description'] ?? '',
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
        'Description' : description,
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

  static Future<void> addFinalProduct(Product product) async {
    // Replace with your API endpoint
    final response = await http.post(
      Uri.parse('https://bakerymanagement-efgmhebnd5aggagn.eastus-01.azurewebsites.net/finalproducts'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'Name': product.name,
        'Description' : product.description,
        'MaxAmount': product.maxAmount,
        'MinAmount': product.minAmount,
        'Quantity': product.quantity,
        'Price': product.price,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add final product');
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
  final response = await http.put(
    Uri.parse('https://bakerymanagement-efgmhebnd5aggagn.eastus-01.azurewebsites.net/finalproducts/${product.productID}'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode(product.toJson()),
  );

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
    final styleActive = const TextStyle(color: Colors.black);
    final styleHint = const TextStyle(color: Colors.black54);
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
class ProductDetailPage extends StatelessWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
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
              height: 150, // Adjust height as needed
              width: 150, // Adjust width as needed
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image:  AssetImage('assets/bread2.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 20),
            // Centered Product Details
            Text('ID: ${product.productID}', style: const TextStyle(fontSize: 20)),
            Text('Name: ${product.name}', style: const TextStyle(fontSize: 20)),
            Text('Description: ${product.description}', style: const TextStyle(fontSize: 20)),
            Text('Price: \$${product.price}', style: const TextStyle(fontSize: 20)),
            Text('Quantity: ${product.quantity}', style: const TextStyle(fontSize: 20)),
            SizedBox(height: 20),
            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    // Call update API
                    await ProductApi.updateProduct(product);
                  },
                  child: const Text('Update'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to recipe page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecipePage(product: product),
                      ),
                    );
                  },
                  child: const Text('Recipe'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
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


void showAddProductDialog(BuildContext context,VoidCallback onProductAdded) {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final maxAmountController = TextEditingController();
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
              keyboardType: TextInputType.numberWithOptions(decimal: true),
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
              maxAmount: int.tryParse(maxAmountController.text) ?? 0,
              minAmount: int.tryParse(minAmountController.text) ?? 0,
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
