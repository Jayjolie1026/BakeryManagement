import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
      home: const SignInPage(),  //BakeryHomePage()
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
  final String _apiUrl = 'https://bakerymanagement-efgmhebnd5aggagn.eastus-01.azurewebsites.net/login'; // Replace with your API URL

  Future<void> _signIn() async {
    final response = await http.post(
      Uri.parse(_apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; usercharset=UTF-8',
      },
      body: jsonEncode(<String, String>{
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
        backgroundColor: const Color(0xFFD8C4AA),
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
          'assets/logo1.png',
          height:40,
      ),
      centerTitle:true, 
      backgroundColor: const Color(0xFFD8C4AA), 
      ),
      backgroundColor: const Color(0xFF422308),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to Inventory Page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const InventoryPage()),
                );
              },
              child: const Text('Manage Inventory'),
            ),
            ElevatedButton(
              onPressed: () {
                // Navigate to Employee Management Page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EmployeesPage()),
                );
              },
              child: const Text('Manage Recipes'),
            ),
            ElevatedButton(
              onPressed: () {
                // Navigate to Orders Page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const OrdersPage()),
                );
              },
              child: const Text('Manage Vendors'),
            ),
             const SizedBox(height: 20), // Space between buttons and image
            Image.asset(
              'assets/bread2.png', // Path to your new image
              height: 150,              // Adjust height as needed
              fit: BoxFit.cover,        // Adjust fit based on your layout needs
            ),
          ],
        ),
      ),
    );
  }
}

class InventoryPage extends StatelessWidget {
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Management'),
      ),
      body: const Center(
        child: Text(
          'Inventory Management Page',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

class EmployeesPage extends StatelessWidget {
  const EmployeesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Management'),
      ),
      body: const Center(
        child: Text(
          'Employee Management Page',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

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
