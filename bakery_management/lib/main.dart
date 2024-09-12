import 'package:flutter/material.dart';
import 'package:bakery_management/pages/inventory.dart';
import 'package:bakery_management/pages/recipe.dart';
import 'package:bakery_management/pages/vendors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:bakery_management/pages/inventory.dart';
import 'package:bakery_management/pages/bakedgoods.dart';


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
      debugShowCheckedModeBanner: false,
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
                    ProductsPage(), // Replace with the appropriate page for baked goods
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




