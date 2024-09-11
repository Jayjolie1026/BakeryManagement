import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:bakery_management/pages/inventory.dart';

void main() {
  runApp(const BakeryManagementApp());
}

class BakeryManagementApp extends StatelessWidget {
  const BakeryManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bakery Management',
      theme: ThemeData(
        primarySwatch: Colors.brown,
      ),

      home: const SignInPage(),

    );
  }
}

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _apiUrl = Uri.parse('https://bakerymanagement-efgmhebnd5aggagn.eastus-01.azurewebsites.net/login'); // Replace with your API URL

  Future<void> _signIn() async {
    final response = await http.post(
      _apiUrl,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': _usernameController.text,
        'password': _passwordController.text,
      }),
    );

    if (response.statusCode == 200) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const BakeryHomePage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid credentials or user not found')),
      );
    }
  }
 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
        backgroundColor: const Color(0xFFEEC07B),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _signIn,
              child: const Text('Sign In'),
            ),
          ],
        ),
      ),
    );
  }
}

class BakeryHomePage extends StatelessWidget {
  const BakeryHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/chatlogo.png',
          height: 75,
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFEEC07B),
      ),
      backgroundColor: const Color(0xFF422308),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: GridView.count(
                crossAxisCount: 2, // Two columns
                crossAxisSpacing: 16, // Space between columns
                mainAxisSpacing: 16, // Space between rows
                children: [
                  _buildGridButton(
                    context,
                    'assets/vendor.png',
                    'Manage Vendors',
                    const VendorsPage(),
                  ),
                  _buildGridButton(
                    context,
                    'assets/recipe.png',
                    'Manage Recipes',
                    const RecipePage(),
                  ),
                  _buildGridButton(
                    context,
                    'assets/inventory.png',
                    'Manage Inventory',
                    const InventoryPage(),
                  ),
                  _buildGridButton(
                    context,
                    'assets/bakedgoods.png',
                    'Manage Baked Goods',
                    const BakedGoodsPage(), // Replace with the appropriate page for baked goods
                  ),
                ],
              ),
            ),
               Expanded(
              flex: 1, // Gives 1 part of the available space to the image
              child: Image.asset(
                'assets/bread2.png', // Path to your bread image
                fit: BoxFit.cover,   // Make the image cover the available space
                width: double.infinity, // Make the image stretch across the screen width
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildGridButton(BuildContext context, String imagePath, String label, Widget page) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
      child: Column(
        children: [
          Expanded(
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 8), // Space between image and text
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,           // Adjust text size as needed
              color: Colors.white,    // Adjust text color as needed
            ),
          ),
        ],
      ),
    );
  }
}



class RecipePage extends StatelessWidget {
  const RecipePage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add), // Plus icon
            onPressed: () {
              // Navigate to AddRecipePage when the button is pressed
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddRecipePage(),
                ),
              );
            },
          ),
        ],

      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Add some padding around the body
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Align content to the left
          children: [
            const Text(
              'Tap on the image to see the recipe',
              style: TextStyle(fontSize: 18),

            ),
            const SizedBox(height: 10), // Space between the text and image
            GestureDetector(
              onTap: () {
                // Navigate to the detailed recipe page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DetailedRecipePage(),
                  ),
                );
              },
              child: Image.asset(
                'assets/bagel3.jpg', // Replace with your image path
                width: 100, // Set image width
                height: 100, // Set image height
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DetailedRecipePage extends StatelessWidget {
  const DetailedRecipePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bagels Recipe and Directions'),
      ),
      body: SingleChildScrollView( // Use SingleChildScrollView to handle scrolling if content is long
        padding: const EdgeInsets.all(16.0), // Add padding to the body
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Align content to the left
          children: [
            // Image section
            Image.asset(
              'assets/bagel3.jpg', // Replace with your image path
              width: double.infinity, // Make the image take up full width
              height: 200, // Set a fixed height for the image
              fit: BoxFit.cover, // Make the image cover the available space
            ),
            const SizedBox(height: 20), // Space between the image and the headers

            // Ingredients header
            const Text(
              'Ingredients',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10), // Space between the header and content

            // Placeholder for ingredients (You can populate this later with API data)
            const Text(
              'Loading ingredients...', // Placeholder text
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20), // Space between ingredients and directions

            // Directions header
            const Text(
              'Directions',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10), // Space between the header and content

            // Placeholder for directions (You can populate this later with API data)
            const Text(
              'Loading directions...', // Placeholder text
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}


// New page to add a recipe
class AddRecipePage extends StatelessWidget {
  const AddRecipePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Recipe'),
      ),
      body: const Center(
        child: Text(
          'Add recipe here',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

class VendorsPage extends StatelessWidget {
  const VendorsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Management'),
      ),
      body: const Center(
        child: Text(
          'Order Management Page',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

class BakedGoodsPage extends StatelessWidget {
  const BakedGoodsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Management'),
      ),
      body: const Center(
        child: Text(
          'Order Management Page',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
