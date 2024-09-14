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

  void _updateProduct(Product updatedProduct) {
  setState(() {
    final index = products.indexWhere((p) => p.productID == updatedProduct.productID);
    if (index != -1) {
      products[index] = updatedProduct;
    }
  });
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
      iconTheme: const IconThemeData(color: Color(0xFF6D3200)),
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
      backgroundColor: const Color(0xFF6D3200),
      foregroundColor: const Color.fromARGB(255, 243, 217, 162),
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
  color: const Color(0xFF6D3200),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(50), // Circular shape
  ),
  margin: const EdgeInsets.fromLTRB(30, 0, 30, 10),
  elevation: 4,
  child: GestureDetector(
    onTap: () async {
      // Navigate to product detail page on tap and wait for result
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductDetailPage(
            product: product,
          ),
        ),
      );

      // If the result is true, refresh the product list
      if (result == true) {
        init(); // Refresh the product list
      }
    },
    child: Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
      child: Center(
        child: Text(
          product.name,
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
    const styleActive = TextStyle(color:Color(0xFFEEC07B));
    const styleHint = TextStyle(color:Color(0xFFEEC07B));
    final style = widget.text.isEmpty ? styleHint : styleActive;

    return Container(
      height: 50,
      margin: const EdgeInsets.fromLTRB(30, 0, 30, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: const Color(0xFF6D3200),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: TextField(
        controller: controller,
        cursorColor: const Color(0xFFEEC07B),
        decoration: InputDecoration(
          iconColor: const Color(0xFFEEC07B),
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
  late Product _product;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
  }

  void _updateProduct(Product updatedProduct) {
    setState(() {
      _product = updatedProduct;
    });
  }
  // Warning function
Widget _buildQuantityWarning(Product product) {
  if (product.quantity < product.minAmount) {
    return const Text(
      'QUANTITY IS VERY LOW! REMAKE NOW!',
      style: TextStyle(fontSize: 18, color: Color(0xFF6D3200)),
    );
  } else if (product.quantity < product.remakeAmount) {
    return const Text(
      'Quantity is getting low. Please remake!',
      style: TextStyle(fontSize: 18, color: Color(0xFF6D3200)),
    );
  }
  return const SizedBox(); // Return an empty widget if no warnings
}


  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text(_product.name),
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
          Text('Name: ${_product.name}', style: const TextStyle(fontSize: 18, color: Color(0xFF6D3200))),
          Text('Description: ${_product.description}', style: const TextStyle(fontSize: 18, color: Color(0xFF6D3200))),
          Text('Max Amount: ${_product.maxAmount}', style: const TextStyle(fontSize: 18, color: Color(0xFF6D3200))),
          Text('Remake Amount: ${_product.remakeAmount}', style: const TextStyle(fontSize: 18, color: Color(0xFF6D3200))),
          Text('Min Amount: ${_product.minAmount}', style: const TextStyle(fontSize: 18, color: Color(0xFF6D3200))),
          Text('Quantity: ${_product.quantity}', style: const TextStyle(fontSize: 18, color: Color(0xFF6D3200))),
          Text('Price: ${_product.price}', style: const TextStyle(fontSize: 18, color: Color(0xFF6D3200))),
          _buildQuantityWarning(_product),

          
          const SizedBox(height: 20),
          // Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  // Navigate to the update page and wait for result
                  final updatedProduct = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductUpdatePage(
                        product: _product,
                        onProductUpdated: _updateProduct,
                      ),
                    ),
                  );

                  // If an updated product was returned, update the state
                  if (updatedProduct != null) {
                    _updateProduct(updatedProduct);
                    Navigator.pop(context, true); // Pass true to indicate an update
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6D3200),
                  foregroundColor: const Color(0xFFF0d1a0),
                ),
                child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add),
                  const SizedBox(width: 8), // Spacing between image and text
                  const Text('Update'),
                ],
              ),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: () {
                  // Navigate to recipe page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RecipePage(product: _product),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6D3200),
                  foregroundColor: const Color(0xFFF0d1a0),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/recipe.png', // Replace with your icon asset
                      height: 20, // Adjust height as needed
                      width: 20,  // Adjust width as needed
                    ),
                    const SizedBox(width: 8), // Spacing between image and text
                    const Text('Recipe'),
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



class ProductUpdatePage extends StatefulWidget {
  final Product product;
  final ValueChanged<Product> onProductUpdated;

  const ProductUpdatePage({super.key, required this.product, required this.onProductUpdated});

  @override
  _ProductUpdatePageState createState() => _ProductUpdatePageState();
}

class _ProductUpdatePageState extends State<ProductUpdatePage> {
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
        title: const Text('Update Product'),
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
            // Editable Fields
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Color(0xFF6D3200)),
              decoration: const InputDecoration(labelText: 'Name', 
              labelStyle: TextStyle(color: Color(0xFF6D3200)),
              focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF6D3200)), // Focused border color
              ),
              enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF6D3200)), // Enabled border color
              ),
              ),
            ),
            TextField(
              controller: _descriptionController,
              style: const TextStyle(color: Color(0xFF6D3200)),
              decoration: const InputDecoration(labelText: 'Description', 
              labelStyle: TextStyle(color: Color(0xFF6D3200)),
              focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF6D3200)), // Focused border color
              ),
              enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF6D3200)), // Enabled border color
              ),
              ),
            ),
            TextField(
              controller: _maxAmountController,
              style: const TextStyle(color: Color(0xFF6D3200)),
              decoration: const InputDecoration(labelText: 'Max Amount', 
              labelStyle: TextStyle(color: Color(0xFF6D3200)),
              focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF6D3200)), // Focused border color
              ),
              enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF6D3200)), // Enabled border color
              ),
              ),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _remakeAmountController,
              style: const TextStyle(color: Color(0xFF6D3200)),
              decoration: const InputDecoration(labelText: 'Remake Amount', 
              labelStyle: TextStyle(color: Color(0xFF6D3200)),
              focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF6D3200)), // Focused border color
              ),
              enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF6D3200)), // Enabled border color
              ),
              ),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _minAmountController,
              style: const TextStyle(color: Color(0xFF6D3200)),
              decoration: const InputDecoration(labelText: 'Min Amount', 
              labelStyle: TextStyle(color: Color(0xFF6D3200)),
              focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF6D3200)), // Focused border color
              ),
              enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF6D3200)), // Enabled border color
              ),
              ),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _priceController,
              style: const TextStyle(color: Color(0xFF6D3200)),
              decoration: const InputDecoration(labelText: 'Price', 
              labelStyle: TextStyle(color: Color(0xFF6D3200)),
              focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF6D3200)), // Focused border color
              ),
              enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF6D3200)), // Enabled border color
              ),
              ),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _quantityController,
              style: const TextStyle(color: Color(0xFF6D3200)),
              decoration: const InputDecoration(labelText: 'Quantity', 
              labelStyle: TextStyle(color: Color(0xFF6D3200)),
              focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF6D3200)), // Focused border color
              ),
              enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF6D3200)), // Enabled border color
              ),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            // Buttons
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

                // Notify parent widget of the update
                widget.onProductUpdated(updatedProduct);

                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Product updated successfully!')),
                );

                // Navigate back to the previous page with the updated product
                Navigator.of(context).pop(updatedProduct);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6D3200),
                foregroundColor: const Color(0xFFF0d1a0),
              ),
              child:  Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                   const Icon(Icons.add),
                  const SizedBox(width: 8), // Spacing between image and text
                  const Text('Update'),
                ],
              ),
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
      backgroundColor: const Color(0xFFF0d1a0), // Background color of the dialog
      titleTextStyle: const TextStyle(color: Color(0xFF6D3200)), 
      title: const Text('Add New Product'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: Color(0xFF6D3200)),
              decoration: const InputDecoration(labelText: 'Name',  
              labelStyle: TextStyle(color: Color(0xFF6D3200)),
              focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF6D3200)), // Focused border color
              ),
              enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF6D3200)), // Enabled border color
              ),
               ),
            ),
             TextField(
              controller: descriptionController,
              style: const TextStyle(color: Color(0xFF6D3200)),
              decoration: const InputDecoration(labelText: 'Description', 
               labelStyle: TextStyle(color: Color(0xFF6D3200)), 
               focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF6D3200)), // Focused border color
              ),
              enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF6D3200)), // Enabled border color
              ),
               ),
            ),
            TextField(
              controller: maxAmountController,
              style: const TextStyle(color: Color(0xFF6D3200)),
              decoration: const InputDecoration(labelText: 'Max Amount',  
              labelStyle: TextStyle(color: Color(0xFF6D3200)),
              focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF6D3200)), // Focused border color
              ),
              enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF6D3200)), // Enabled border color
              ),
               ),
              keyboardType: TextInputType.number,
            ),
             TextField(
              controller: remakeAmountController,
              style: const TextStyle(color: Color(0xFF6D3200)),
              decoration: const InputDecoration(labelText: 'Remake Amount', 
               labelStyle: TextStyle(color: Color(0xFF6D3200)), 
               focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF6D3200)), // Focused border color
              ),
              enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF6D3200)), // Enabled border color
              ),
               ),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: minAmountController,
              style: const TextStyle(color: Color(0xFF6D3200)),
              decoration: const InputDecoration(labelText: 'Min Amount', 
               labelStyle: TextStyle(color: Color(0xFF6D3200)),
               focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF6D3200)), // Focused border color
              ),
              enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF6D3200)), // Enabled border color
              ),
                ),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: quantityController,
              style: const TextStyle(color: Color(0xFF6D3200)),
              decoration: const InputDecoration(labelText: 'Quantity',  
              labelStyle: TextStyle(color: Color(0xFF6D3200)), 
              focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF6D3200)), // Focused border color
              ),
              enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF6D3200)), // Enabled border color
              ),
              ),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: priceController,
              style: const TextStyle(color: Color(0xFF6D3200)),
              decoration: const InputDecoration(labelText: 'Price',  
              labelStyle: TextStyle(color: Color(0xFF6D3200)), 
              focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF6D3200)), // Focused border color
              ),
              enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF6D3200)), // Enabled border color
              ),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
           style: TextButton.styleFrom(
            backgroundColor: const Color(0xFF6D3200), // Text color of the button
            foregroundColor: const Color(0xFFF0d1a0),
          ),
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
           style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6D3200), // Background color of the button
            foregroundColor: const Color(0xFFF0d1a0), // Text color of the button
          ),
          child: const Text('Add'),
        ),
      ],
    ),
  );
}
