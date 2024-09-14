import 'package:flutter/material.dart';
import 'package:bakery_management/pages/inventory.dart';
import 'package:bakery_management/pages/recipe.dart';
import 'package:bakery_management/pages/vendors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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
        scaffoldBackgroundColor: const Color(0xFFEEC07B),  // Set global background color
        appBarTheme: const AppBarTheme(
          iconTheme: IconThemeData(color: Colors.white), // Icon color in the AppBar
          elevation: 0, // Elevation of the AppBar
        ),
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
    print('Response status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
    final responseBody = jsonDecode(response.body);
    print('Decoded response body: $responseBody');
    final employeeId = responseBody['employee_id'];
    print('Employee ID: $employeeId');

    final sessionResponse = await http.post(
      Uri.parse('https://bakerymanagement-efgmhebnd5aggagn.eastus-01.azurewebsites.net/sessions/start'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'employee_id': employeeId,
      }),
    );
    print('Session response status code: ${sessionResponse.statusCode}');
    print('Session response body: ${sessionResponse.body}');

    if (sessionResponse.statusCode == 201) {
      // Navigate to the home page after successfully creating a session
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const BakeryHomePage()),
      );
       } else {
      // Handle session creation failure
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create session')),
      );
    }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid credentials or user not found')),
      );
    }
  }
 void _navigateToCreateAccount() {
    // Replace with your Create Account page
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateAccountPage()),
    );
  }

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
        backgroundColor: const Color(0xFF422308),
        foregroundColor: const Color(0xFFEEC07B),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username',
              labelStyle: const TextStyle(color: Color(0xFF422308)), // Label color
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF422308)), // Focused border color
              ),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF422308)), // Enabled border color
              ),
              ),
              style: const TextStyle(color: Color(0xFF422308)), // Input text color
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password',
               labelStyle: const TextStyle(color: Color(0xFF422308)), // Label color
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF422308)), // Focused border color
              ),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF422308)), // Enabled border color
              ),
            ),
            style: const TextStyle(color: Color(0xFF422308)), // Input text color),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _signIn,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF422308), // Background color
                foregroundColor: const Color(0xFFEEC07B), // Text color
              ),
              child: const Text('Sign In'),     
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _navigateToCreateAccount,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF422308), // Background color
                foregroundColor: const Color(0xFFEEC07B), // Text color
              ),
              child: const Text('Create Account'),
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
                    const ProductsPage(), // Replace with the appropriate page for baked goods
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



class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  _CreateAccountPageState createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _streetAddressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
// Assuming the user selects an address type (e.g., home, work, etc.)
  int _selectedAddressType = 1; // Default or user-selected
  

  final _apiUrl = Uri.parse('https://bakerymanagement-efgmhebnd5aggagn.eastus-01.azurewebsites.net/users'); // Replace with your API URL

  Future<void> _createAccount() async {
    final response = await http.post(
      _apiUrl,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'username': _usernameController.text,
        'password': _passwordController.text,
        'email': _emailController.text,
        'phoneNumber': _phoneNumberController.text,
        'address': {
        'streetAddress': _streetAddressController.text,
        'city': _cityController.text,
        'state': _stateController.text,
        'postalCode': _postalCodeController.text,
        'country': _countryController.text,
        'addressTypeID': _selectedAddressType,
      }
      }),
    );
    print("Response status code: ${response.statusCode}");
    print("Response body: ${response.body}");

    if (response.statusCode == 201) {
       Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const BakeryHomePage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create account: ${response.body}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: const Color(0xFF422308),
        foregroundColor: const Color(0xFFEEC07B),
        iconTheme: IconThemeData(color: const Color(0xFFEEC07B)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _firstNameController,
              style: TextStyle(color: const Color(0xFF6D3200)),
              decoration: const InputDecoration(labelText: 'First Name', 
              labelStyle: TextStyle(color: Color(0xFF6D3200)),
              focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: const Color(0xFF6D3200)), // Focused border color
              ),
              enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: const Color(0xFF6D3200)), // Enabled border color
              ),
              ),
            ),
            TextField(
              controller: _lastNameController,
              style: TextStyle(color: const Color(0xFF6D3200)),
              decoration: const InputDecoration(labelText: 'Last Name', 
              labelStyle: TextStyle(color: Color(0xFF6D3200)),
              focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: const Color(0xFF6D3200)), // Focused border color
              ),
              enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: const Color(0xFF6D3200)), // Enabled border color
              ),
              ),
            ),
            TextField(
              controller: _usernameController,
              style: TextStyle(color: const Color(0xFF6D3200)),
              decoration: const InputDecoration(labelText: 'Username',
               labelStyle: TextStyle(color: Color(0xFF6D3200)),
               focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: const Color(0xFF6D3200)), // Focused border color
              ),
              enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: const Color(0xFF6D3200)), // Enabled border color
              ),
               ),
            ),
            TextField(
              controller: _passwordController,
              style: TextStyle(color: const Color(0xFF6D3200)),
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password', 
              labelStyle: TextStyle(color: Color(0xFF6D3200)),
              focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: const Color(0xFF6D3200)), // Focused border color
              ),
              enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: const Color(0xFF6D3200)), // Enabled border color
              ),
              ),
            ),
            TextField(
              controller: _emailController,
              style: TextStyle(color: const Color(0xFF6D3200)),
              decoration: const InputDecoration(labelText: 'Email', 
              labelStyle: TextStyle(color: Color(0xFF6D3200)),
              focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: const Color(0xFF6D3200)), // Focused border color
              ),
              enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: const Color(0xFF6D3200)), // Enabled border color
              ),
              ),
            ),
            TextField(
              controller: _phoneNumberController,
              style: TextStyle(color: const Color(0xFF6D3200)),
              decoration: const InputDecoration(labelText: 'Phone Number', 
              labelStyle: TextStyle(color: Color(0xFF6D3200)),
              focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: const Color(0xFF6D3200)), // Focused border color
              ),
              enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: const Color(0xFF6D3200)), // Enabled border color
              ),
              ),
            ),
           TextField(
            controller: _streetAddressController,
            style: TextStyle(color: const Color(0xFF6D3200)),
            decoration: const InputDecoration(labelText: 'Street Address',
             labelStyle: TextStyle(color: Color(0xFF6D3200)),
              focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: const Color(0xFF6D3200)), // Focused border color
              ),
              enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: const Color(0xFF6D3200)), // Enabled border color
              ),
            ),
          ),
          TextField(
              controller: _cityController,
              style: TextStyle(color: const Color(0xFF6D3200)),
              decoration: const InputDecoration(labelText: 'City',
               labelStyle: TextStyle(color: Color(0xFF6D3200)),
              focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: const Color(0xFF6D3200)), // Focused border color
              ),
              enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: const Color(0xFF6D3200)), // Enabled border color
              ),
              ),
          ),
          TextField(
              controller: _stateController,
              style: TextStyle(color: const Color(0xFF6D3200)),
              decoration: const InputDecoration(labelText: 'State',
               labelStyle: TextStyle(color: Color(0xFF6D3200)),
              focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: const Color(0xFF6D3200)), // Focused border color
              ),
              enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: const Color(0xFF6D3200)), // Enabled border color
              ),
              ),
          ),
          TextField(
              controller: _postalCodeController,
              style: TextStyle(color: const Color(0xFF6D3200)),
              decoration: const InputDecoration(labelText: 'Postal Code',
               labelStyle: TextStyle(color: Color(0xFF6D3200)),
              focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: const Color(0xFF6D3200)), // Focused border color
              ),
              enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: const Color(0xFF6D3200)), // Enabled border color
              ),
              ),
          ),
          TextField(
              controller: _countryController,
              style: TextStyle(color: const Color(0xFF6D3200)),
              decoration: const InputDecoration(labelText: 'Country',
               labelStyle: TextStyle(color: Color(0xFF6D3200)),
              focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: const Color(0xFF6D3200)), // Focused border color
              ),
              enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: const Color(0xFF6D3200)), // Enabled border color
              ),
              ),
          ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _createAccount,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF422308), // Background color
                foregroundColor: const Color(0xFFEEC07B), // Text color
              ),
              child: const Text('Create Account'),
            ),
          ],
        ),
      ),
    );
  }
}


