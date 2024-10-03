import 'dart:async';
import 'package:bakery_management/pages/recipeFunctions.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:bakery_management/pages/sessions.dart';
import 'package:bakery_management/main.dart';
import 'package:shared_preferences/shared_preferences.dart';


const Map<int, String> productImages = {
  12: 'assets/sourdough.jpg',
  13: 'assets/choclatechip.jpg',
  14: 'assets/buttercroissant.jpg',
  15: 'assets/blueberrymuffins.jpg',
  16: 'assets/cinnaon.jpg',
  17: 'assets/frecnh.jpg',
  18: 'assets/lemon.jpg',
  19: 'assets/eclair.jpg',
  20: 'assets/pie.jpg',
  21: 'assets/cupcakes.jpg',
  22: 'assets/pie.jpg',
  23: 'assets/almond.jpg',
  24: 'assets/raspberry.jpg',
  25: 'assets/brownies.jpg',
  26: 'assets/macarons.jpg',
};


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
  final String category;

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
    required this.category,
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
      category: json['Category'] ?? '',
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
        'Category' : category,
      };
}



// API class for final products
class ProductApi {
  static const String baseUrl = 'https://bakerymanagement-efgmhebnd5aggagn.eastus-01.azurewebsites.net/finalproducts';

  static Future<Product> fetchProductById(int productId) async {
    final response = await http.get(Uri.parse('$baseUrl/$productId'));

    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, parse the JSON
      return Product.fromJson(json.decode(response.body));
    } else {
      // If the server did not return a 200 OK response, throw an exception
      throw Exception('Failed to load product');
    }
  }
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
    "price": product.price,
    "category": product.category,
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

static Future<List<Map<String, dynamic>>?> fetchRecipeByProductID(int productID) async {
  final response = await http.get(Uri.parse('https://bakerymanagement-efgmhebnd5aggagn.eastus-01.azurewebsites.net/recipes/product/${productID}'));
  print('Product ID: $productID');

  if (response.statusCode == 200) {
    // Log the response body to understand its structure
    print('Response body: ${response.body}');

    // Decode the response body as a List
    final List<dynamic> data = json.decode(response.body);

    // Check if the response contains data
    if (data.isNotEmpty) {
      // Map the data to a list of maps containing RecipeID and Name
      return data.map((recipe) {
        return {
          'recipeID': recipe['RecipeID'], // Use correct key casing from API
          'name': recipe['Name'] // Use correct key casing from API
        };
      }).toList();
    } else {
      return null; // No recipes found
    }
  } else {
    throw Exception('Failed to load recipes: ${response.statusCode}');
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
   List<Product> allItems = [];
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
  Future init() async {
    try {
      final products = await ProductApi.getProducts(query);
      // Check if the widget is still mounted
        setState(() {
      this.products = products;
      this.allItems = products; // Store all items for future reference
    });
      
    } catch (e) {
      // Handle the error if needed
      print('Failed to load products: $e');
    }
  }

 @override
Widget build(BuildContext context) => Scaffold(
  backgroundColor: const Color(0xFFF0D1A0),
  body: Column(
    children: <Widget>[
      SizedBox(height: 25.0),
      buildSearchWithFilter(),
      Expanded(
        child: ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
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
                init();
                // Navigate to the item details page
               final updatedProduct = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductDetailPage(product: product),
                  ),
                );

                if (updatedProduct != null) {
                  setState(() {
                    int index = products.indexWhere((p) => p.productID == updatedProduct.productID);
                    if (index != -1) {
                      products[index] = updatedProduct; // Update the specific product
                    }
                  });
                }

                // Re-apply the current query/filter after returning
                if (query.isNotEmpty) {
                  searchItem(query);  // Re-apply the search/filter query
                } else {
                  setState(() {
                    products = allItems;  // Reset to full list if no filter is applied
                  });
                }
              },
              child: buildProduct(product), // Your custom widget to display the item
            );
          },
        ),
      ),
      const SizedBox(height: 80)
    ],
  ),
  floatingActionButton: FloatingActionButton.extended(
    onPressed: () => showAddProductDialog(context, () {
      // Refresh the product list after adding a new product
      init(); // Call init to reload products
    }),
    label: const Text(
      'Add Product',
      style: TextStyle(
        color: Color(0xFFEEC07B),  // Light brown text color
        fontSize: 17,
      ),
    ),
    icon: const Icon(
      Icons.add,
      color: Color(0xFFEEC07B),  // Light brown icon color
    ),
    backgroundColor: const Color(0xFF422308),  // Dark brown background
  ),
  floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
);


  // Search bar widget
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
        padding: EdgeInsets.fromLTRB(0, 0, 25, 15), // Add some padding if needed
        alignment: Alignment.center, // Center the icon vertically
        child: IconButton(
          icon: Icon(Icons.filter_list),
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
        title: Text(
          'Filter by Category',
          style: TextStyle(
            color: const Color(0xFF6D3200), // Set the title text color
          ),
        ),
        content: SingleChildScrollView( // Make content scrollable
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: categories.map((category) {
              return ListTile(
                title: Text(
                  category,
                  style: TextStyle(
                    color: const Color(0xFF6D3200), // Set the ListTile text color
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
            icon: Icon(Icons.close, color: const Color(0xFF422308)), // Set the close button icon color
            onPressed: () {
              Navigator.pop(context); // Close the dialog
              setState(() {
                products = allItems; // Reset to show all items
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
  final allCategories = products.map((product) => product.category).toSet();
  //print(_getCategories());
  
   // Extract unique categories
  return allCategories.toList(); // Convert Set back to List for easier manipulation
}

// Apply the selected category filter
void applyCategoryFilter(String category) {
  setState(() {
    // Filter items based on the selected category from the full item list
    products = allItems.where((product) => product.category == category).toList();
    query = category; // Update the query to reflect the selected category
  });
}

  void searchItem(String query) {
  List<Product> filteredItems;

  if (query.isEmpty) {
    // Reset items to the full list when search is cleared
    filteredItems = allItems;
  } else if (_isCategory(query)) {
    // If query is a category, filter items by that category
    filteredItems = allItems.where((item) => item.category == query).toList();
  } else {
    // Otherwise, filter items by name or other search criteria
    filteredItems = allItems.where((item) =>
        item.name.toLowerCase().contains(query.toLowerCase())).toList();
  }

  setState(() {
    products = filteredItems;
    this.query = query; // Update query in state
  });
}

  // Build list tile for each product
  Widget buildProduct(Product product) => GestureDetector(
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
      // Navigate to product detail page on tap and wait for result
       final updatedProduct = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailPage(
          product: product,
      onProductUpdated: (updatedProduct) {
        int index = products.indexWhere((p) => p.productID == updatedProduct.productID);
        if (index != -1) {
          setState(() {
            products[index] = updatedProduct; // Update the product list
          });
        }
      },
    ),
  ),
    );
    if (updatedProduct != null) {
      setState(() {
        // Find the index of the product to update
        int index = products.indexWhere((p) => p.productID == updatedProduct.productID);
        if (index != -1) {
            products[index] = updatedProduct; // Update the existing product
            allItems[index] = updatedProduct;
        }
      });
    }
      setState(() {
    // Check if the query is still valid and reapply filtering
    if (query.isNotEmpty) {
      searchItem(query);  // Re-apply the search/filter query
    } else {
      products = allItems;  // Reset to full list if no filter is applied
    }
  });

      // If the result is true, refresh the product list
      
    },
    child: Card(
      color: const Color(0xFF6D3200),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50), // Circular shape
      ),
      margin: const EdgeInsets.fromLTRB(30, 0, 30, 10),
      elevation: 4,
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
        child: Center(
          child: Text(
            product.name,
            style: const TextStyle(
              color: Color(0xFFEEC07B),  // Light brown text color
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
    const styleActive = TextStyle(color: Color(0xFF6D3200));
    const styleHint = TextStyle(color: Color(0xFF6D3200));
    final style = widget.text.isEmpty ? styleHint : styleActive;

    return Container(
      height: 50,
      margin: const EdgeInsets.fromLTRB(30, 0, 0, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: const Color(0xFFD8C4AA),
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


class ProductDetailPage extends StatefulWidget {
  final Product product;
    final Function(Product)? onProductUpdated; // Add this line
  const ProductDetailPage({super.key, required this.product,this.onProductUpdated});

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late Product _product;

  String _getProductImage() {
  // Get the image path from the mapping based on the product ID
  // If no image path is found, return a default image path
  return productImages[_product.productID] ?? 'assets/bagel3.png';
}


  @override
  void initState() {
    super.initState();
    _product = widget.product;
  }


  void _updateProduct(Product updatedProduct) async {
  setState(() {
    _product = updatedProduct;
  });

  // Optionally re-fetch the product from the database
  final fetchedProduct = await ProductApi.fetchProductById(_product.productID!);
  setState(() {
    _product = fetchedProduct; // Update state with the freshly fetched product
  });
  if (widget.onProductUpdated != null) {
    widget.onProductUpdated!(fetchedProduct); // Notify the parent about the updated product
  }
}

  Widget _buildQuantityWarning(Product product) {
    if (product.quantity < product.minAmount) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'QUANTITY IS VERY LOW! REMAKE NOW!',
          style: TextStyle(
            fontSize: 20,
            color: Color(0xFF6D3200),
          ),
          textAlign: TextAlign.left,
        ),
      );
    } else if (product.quantity < product.remakeAmount) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'Quantity is getting low. Please remake!',
          style: TextStyle(
            fontSize: 20,
            color: Color(0xFF6D3200),
          ),
          textAlign: TextAlign.left,
        ),
      );
    }
    return const SizedBox(); // Empty widget
  }


 @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0D1A0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product name as a header
              Text(
                _product.name,
                style: const TextStyle(
                  fontSize: 30,
                  color: Color(0xFF6D3200),
                  fontWeight: FontWeight.bold,
                  height: 1.2
                ),
                textAlign: TextAlign.left,

            ),
            // Product image
            SizedBox(
              width: double.infinity,
              height: 250, // Set the height of the image
              child: Image.asset(
                _getProductImage(),
                fit: BoxFit.cover, // Cover the area while maintaining aspect ratio
              ),
            ),
              const SizedBox(height: 10),

                Text.rich(
                  TextSpan(
                    children: <TextSpan>[
                      TextSpan(
                        text: '${_product.description}',
                        style: const TextStyle(
                          color: Color(0xFF6D3200), // Dark brown
                          fontSize: 20,
                          height: 1.5
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.left,
                ),
                Text.rich(
                  TextSpan(
                    children: <TextSpan>[
                      TextSpan(
                        text: 'Category:\n',
                        style: TextStyle(
                          color: Color(0xFF6D3200), // Dark brown
                          fontSize: 20,
                          fontWeight: FontWeight.bold, // Bold heading
                          height: 1.2
                        ),
                      ),
                      TextSpan(
                        text: '${_product.category}',
                        style: const TextStyle(
                          color: Color(0xFF6D3200), // Dark brown
                          fontSize: 20,
                          height: 1.2
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.left,
                ),
               
               Text.rich(
                  TextSpan(
                    children: <TextSpan>[
                      TextSpan(
                        text: 'Max Amount:\n',
                        style: TextStyle(
                          color: Color(0xFF6D3200), // Dark brown
                          fontSize: 20,
                          fontWeight: FontWeight.bold, // Bold heading
                          height: 1.2
                        ),
                      ),
                      TextSpan(
                        text: '${_product.maxAmount}',
                        style: const TextStyle(
                          color: Color(0xFF6D3200), // Dark brown
                          fontSize: 20,
                          height: 1.2
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.left,
                ),
           
              const SizedBox(height: 10),
                 Text.rich(
                  TextSpan(
                    children: <TextSpan>[
                      TextSpan(
                        text: 'Remake Amount:\n',
                        style: TextStyle(
                          color: Color(0xFF6D3200), // Dark brown
                          fontSize: 20,
                          fontWeight: FontWeight.bold, // Bold heading
                        ),
                      ),
                      TextSpan(
                        text: '${_product.remakeAmount}',
                        style: const TextStyle(
                          color: Color(0xFF6D3200), // Dark brown
                          fontSize: 20,
                          height: 1.2
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.left,
                ),

              const SizedBox(height: 10),
               Text.rich(
                  TextSpan(
                    children: <TextSpan>[
                      TextSpan(
                        text: 'Min Amount:\n',
                        style: TextStyle(
                          color: Color(0xFF6D3200), // Dark brown
                          fontSize: 20,
                          fontWeight: FontWeight.bold, // Bold heading
                          height: 1.2
                        ),
                      ),
                      TextSpan(
                        text: '${_product.minAmount}',
                        style: const TextStyle(
                          color: Color(0xFF6D3200), // Dark brown
                          fontSize: 20,
                          height: 1.2
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.left,
                ),
              
              const SizedBox(height: 10),
               Text.rich(
                  TextSpan(
                    children: <TextSpan>[
                      TextSpan(
                        text: 'Quantity:\n',
                        style: TextStyle(
                          color: Color(0xFF6D3200), // Dark brown
                          fontSize: 20,
                          fontWeight: FontWeight.bold, // Bold heading
                          height: 1.2
                        ),
                      ),
                      TextSpan(
                        text: '${_product.quantity}',
                        style: const TextStyle(
                          color: Color(0xFF6D3200), // Dark brown
                          fontSize: 20,
                          height: 1.2
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.left,
                ),
              
              const SizedBox(height: 10),
               Text.rich(
                  TextSpan(
                    children: <TextSpan>[
                      TextSpan(
                        text: 'Price:\n',
                        style: TextStyle(
                          color: Color(0xFF6D3200), // Dark brown
                          fontSize: 20,
                          fontWeight: FontWeight.bold, // Bold heading
                          height: 1.2
                        ),
                      ),
                      TextSpan(
                        text: '${_product.price}',
                        style: const TextStyle(
                          color: Color(0xFF6D3200), // Dark brown
                          fontSize: 20,
                          height: 1.2
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.left,
                ),
              

              const SizedBox(height: 10),
              _buildQuantityWarning(_product),
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
                        showProductUpdateDialog(
                          context,
                          _product, // Pass the product you want to update
                          (updatedProduct) {
                            _updateProduct(updatedProduct);
                            // Optionally, re-fetch the product from the database if necessary
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
                        SizedBox(width: 8), // Spacing between icon and text
                        Text('Update'),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () async {
                      
                        List<Map<String, dynamic>>? recipeData = await ProductApi.fetchRecipeByProductID(_product.productID!);
                      
                      if (recipeData != null && recipeData.isNotEmpty) {
                        for (var recipe in recipeData) {
                          int recipeID = recipe['recipeID'];
                          String recipeName = recipe['name'];
                          // Navigate to the DetailedRecipePage with the fetched recipeID
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailedRecipePage(
                                recipeName: recipeName,  // Assuming _product.name is non-null
                                recipeID: recipeID,          // Use the fetched recipeID
                              ),
                            ),
                          );
                        }
                        } else {
                          // Handle the case when the recipeID is null
                          // For example, show a snackbar or dialog
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Recipe not found for this product.')),
                          );
                        }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6D3200),
                      foregroundColor: const Color(0xFFF0D1A0),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/recipe.png', // Replace with your icon asset
                          height: 20, // Adjust height as needed
                          width: 20,  // Adjust width as needed
                        ),
                        const SizedBox(width: 8), // Spacing between icon and text
                        const Text('Recipe'),
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
                        borderRadius: BorderRadius.circular(16.0),
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

    );
  }
}




void showProductUpdateDialog(BuildContext context, Product product, ValueChanged<Product> onProductUpdated) {
  final nameController = TextEditingController(text: product.name);
  final descriptionController = TextEditingController(text: product.description);
  final maxAmountController = TextEditingController(text: product.maxAmount.toString());
  final remakeAmountController = TextEditingController(text: product.remakeAmount.toString());
  final minAmountController = TextEditingController(text: product.minAmount.toString());
  final priceController = TextEditingController(text: product.price.toString());
  final quantityController = TextEditingController(text: product.quantity.toString());
  final categoryController = TextEditingController(text: product.name);

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: const Color(0xFFEEC07B), // Example color
        titleTextStyle: const TextStyle(color: Color(0xFF6D3200),
        fontFamily: 'MyFont',
        fontSize: 24.0), 
        title: const Text('Update Product'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(color: Color(0xFF6D3200)),
                decoration: const InputDecoration(
                  labelText: 'Name',
                  labelStyle: TextStyle(color: Color(0xFF6D3200)),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF6D3200)),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF6D3200)),
                  ),
                ),
              ),
              TextField(
                controller: descriptionController,
                style: const TextStyle(color: Color(0xFF6D3200)),
                decoration: const InputDecoration(
                  labelText: 'Description',
                  labelStyle: TextStyle(color: Color(0xFF6D3200)),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF6D3200)),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF6D3200)),
                  ),
                ),
              ),
              TextField(
                controller: categoryController,
                style: const TextStyle(color: Color(0xFF6D3200)),
                decoration: const InputDecoration(
                  labelText: 'Category',
                  labelStyle: TextStyle(color: Color(0xFF6D3200)),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF6D3200)),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF6D3200)),
                  ),
                ),
              ),
              TextField(
                controller: maxAmountController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Color(0xFF6D3200)),
                decoration: const InputDecoration(
                  labelText: 'Max Amount',
                  labelStyle: TextStyle(color: Color(0xFF6D3200)),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF6D3200)),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF6D3200)),
                  ),
                ),
              ),
              TextField(
                controller: remakeAmountController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Color(0xFF6D3200)),
                decoration: const InputDecoration(
                  labelText: 'Remake Amount',
                  labelStyle: TextStyle(color: Color(0xFF6D3200)),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF6D3200)),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF6D3200)),
                  ),
                ),
              ),
              TextField(
                controller: minAmountController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Color(0xFF6D3200)),
                decoration: const InputDecoration(
                  labelText: 'Min Amount',
                  labelStyle: TextStyle(color: Color(0xFF6D3200)),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF6D3200)),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF6D3200)),
                  ),
                ),
              ),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Color(0xFF6D3200)),
                decoration: const InputDecoration(
                  labelText: 'Price',
                  labelStyle: TextStyle(color: Color(0xFF6D3200)),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF6D3200)),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF6D3200)),
                  ),
                ),
              ),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Color(0xFF6D3200)),
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  labelStyle: TextStyle(color: Color(0xFF6D3200)),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF6D3200)),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF6D3200)),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
              
              foregroundColor: const Color(0xFF6D3200), // Text color
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final updatedProduct = Product(
                productID: product.productID,
                name: nameController.text,
                description: descriptionController.text,
                maxAmount: double.parse(maxAmountController.text),
                remakeAmount: double.parse(remakeAmountController.text),
                minAmount: double.parse(minAmountController.text),
                quantity: int.parse(quantityController.text),
                price: double.parse(priceController.text),
                category: categoryController.text,
              );


              await ProductApi.updateProduct(updatedProduct);
              onProductUpdated(updatedProduct);
              

              Navigator.pop(context, updatedProduct);
              
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6D3200),
              foregroundColor: const Color(0xFFF0d1a0),
            ),
            child: const Text('Save Changes'),
          ),
        ],
      );
    },
  );
}


void showAddProductDialog(BuildContext context,VoidCallback onProductAdded) {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final maxAmountController = TextEditingController();
  final remakeAmountController = TextEditingController();
  final minAmountController = TextEditingController();
  final quantityController = TextEditingController();
  final priceController = TextEditingController();
  final categoryController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: const Color(0xFFF0d1a0), // Background color of the dialog
      titleTextStyle: const TextStyle(color: Color(0xFF6D3200),
        fontFamily: 'MyFont',), 
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
              controller: categoryController,
              style: const TextStyle(color: Color(0xFF6D3200)),
              decoration: const InputDecoration(labelText: 'Category', 
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
             // Text color of the button
            foregroundColor: const Color(0xFF6D3200),
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
              category: categoryController.text,
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
