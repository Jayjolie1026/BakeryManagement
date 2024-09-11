import 'package:flutter/material.dart';
import 'package:bakery_management/pages/inventory.dart';
//import 'package:bakery_management/pages/vendors.dart';
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

      debugShowCheckedModeBanner: false,

      home: const SignInPage(),
      //main
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
        height: 40,
      ),
      centerTitle: true,
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
                MaterialPageRoute(builder: (context) => const RecipePage()),
              );
            },
            child: const Text('Manage Recipes'),
          ),
          GestureDetector(
            onTap: () {
              // Navigate to Vendors Page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const OrdersPage()),
              );
            },
            child: Column(
              children: [
                Image.asset(
                  'assets/vendor.png', // Replace with the vendor image path
                  height: 100,               // Adjust height as needed
                  fit: BoxFit.cover,         // Adjust fit based on your layout needs
                ),
                const SizedBox(height: 8),  // Space between image and text
                const Text(
                  'Manage Vendors',
                  style: TextStyle(
                    fontSize: 16,           // Adjust text size as needed
                    color: Colors.white,    // Adjust text color as needed
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20), // Space between vendor button and the bread image
          Image.asset(
            'assets/bread2.png',        // Path to your bread image
            height: 150,                // Adjust height as needed
            fit: BoxFit.cover,          // Adjust fit based on your layout needs
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

///
///
///
/// VENDORS
/// 
/// 
/// 

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Order Management',
          style: TextStyle(
          color: const Color(0xFFD8C4AA), // Set the text color to white (or any color you prefer)
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF422308),
        
        actions: [
          IconButton(
            icon: const Icon(Icons.remove), // Minus icon
            color: const Color(0xFFD8C4AA),
            onPressed: () {
              // Navigate to RemoveVendorPage when the button is pressed
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RemoveVendorPage(),
                ),
              );
            },
          ),

          IconButton(
            icon: const Icon(Icons.add), // Plus icon
            color: const Color(0xFFD8C4AA),
            onPressed: () {
              // Navigate to AddVendorPage when the button is pressed
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddVendorPage(),
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
            const Center(
              child: Text(
                'Tap on the image to see the vendor',
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 10), // Space between the text and image
            GestureDetector(
              onTap: () {
                // Navigate to the detailed vendor page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DetailedVendorPage(),
                  ),
                );
              },
              child: Image.asset(
                'assets/vendor.png', // Replace with your image path
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

// New page to add a vendor
class AddVendorPage extends StatelessWidget {
  const AddVendorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Vendor'),
      ),
      body: const Center(
        child: Text(
          'Add Vendor here',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

// New page to remove a vendor
class RemoveVendorPage extends StatelessWidget {
  const RemoveVendorPage({super.key});

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Remove Vendor'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Add some padding around the body
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Align content to the left
          children: [
            const Center(
              child: Text(
                'Choose which vendor to remove:',
                style: TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(height: 10), // Space between the text and image
            GestureDetector(
              onTap: () {
                // Navigate to the detailed vendor page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DetailedVendorPage(),
                  ),
                );
              },
              child: Image.asset(
                'assets/vendor.png', // Replace with your image path
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

class DetailedVendorPage extends StatelessWidget {
  const DetailedVendorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendor Information'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView( // Use SingleChildScrollView to handle scrolling if content is long
              padding: const EdgeInsets.all(16.0), // Add padding to the body
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // Align content to the left
                children: [
                  // Image section
                  Image.asset(
                    'assets/vendor.png', // Replace with your image path
                    width: double.infinity, // Make the image take up full width
                    height: 200, // Set a fixed height for the image
                    fit: BoxFit.cover, // Make the image cover the available space
                  ),
                  const SizedBox(height: 20), // Space between the image and the headers

                  // Phone Number header
                  const Text(
                    'Phone Number',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10), // Space between the header and content

                  // Placeholder for phone number
                  const Text(
                    'Loading phone...', // Placeholder text
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 20), // Space between phone number and email

                  // Email header
                  const Text(
                    'Email',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10), // Space between the header and content

                  // Placeholder for email
                  const Text(
                    'Loading email...', // Placeholder text
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0), // Padding around the button
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ElevatedButton(
                onPressed: () {
                  // Define the action when the button is pressed
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditVendorPage(),
                    ),
                  );
                },             
                style: ElevatedButton.styleFrom(
                  foregroundColor: const Color(0xFFD8C4AA), // Background color of the button
                  backgroundColor: const Color(0xFF422308), // Text color of the button
                  minimumSize: const Size(double.infinity, 60), // Button width and height
                  padding: const EdgeInsets.symmetric(vertical: 16), // Padding inside the button
                ),
                child: const Text(
                  'Edit Vendor Info',
                  style: TextStyle(
                    fontSize: 22, // Increase font size if needed
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}




// New page to edit a vendor
class EditVendorPage extends StatelessWidget {
  const EditVendorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Vendor'),
      ),
      body: const Center(
        child: Text(
          'Vendor info here',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

