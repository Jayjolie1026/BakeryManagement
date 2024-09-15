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
        fontFamily: 'MyFont',
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
      title: const Text("Welcome to Big Baller Bakery!"),
      centerTitle: true,
      backgroundColor: const Color(0xFF422308),
      foregroundColor: const Color(0xFFEEC07B),
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Add the image here
          Image.asset(
            'assets/chatlogo.png',
            height: 207,
          ),
          const SizedBox(height: 20), // Spacing between image and form fields
          
          // Username TextField
          TextField(
            controller: _usernameController,
            decoration: const InputDecoration(
              labelText: 'Username',
              labelStyle: TextStyle(color: Color(0xFF422308)), // Label color
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF422308)), // Focused border color
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF422308)), // Enabled border color
              ),
            ),
            style: const TextStyle(color: Color(0xFF422308)), // Input text color
          ),
          
          // Password TextField
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password',
              labelStyle: TextStyle(color: Color(0xFF422308)), // Label color
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF422308)), // Focused border color
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF422308)), // Enabled border color
              ),
            ),
            style: const TextStyle(color: Color(0xFF422308)), // Input text color
          ),
          
          const SizedBox(height: 20),
          
          // Sign In Button
          ElevatedButton(
            onPressed: _signIn,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF422308), // Background color
              foregroundColor: const Color(0xFFEEC07B), // Text color
            ),
            child: const Text('Sign In'),
          ),
          
          const SizedBox(height: 10),
          
          // Create Account Button
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
        title: null, // Remove the title to use FlexibleSpaceBar
      flexibleSpace: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 10.0), // Adjust this value to scoot the image up
          child: Image.asset(
            'assets/chatlogo.png',
            height: 70,
          ),
        ),
      ),
        centerTitle: true,
        backgroundColor: const Color(0xFF422308), //const Color(0xFF422308)
      ),
      backgroundColor: const Color(0xFFEEC07B),
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
                    'assets/vendor2.png',
                    '',
                    const VendorsPage(),
                  ),
                  _buildGridButton(
                    context,
                    'assets/recipe2.png',
                    '',
                    const RecipePage(),
                  ),
                  _buildGridButton(
                    context,
                    'assets/inventory2.png',
                    '',
                    const InventoryPage(),
                  ),
                  _buildGridButton(
                    context,
                    'assets/bakedgoods2.png',
                    '',
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
  final TextEditingController _areaCodeController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _streetAddressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();

  String?_selectedState;
  final List<String> _states = [
    'AL', 'AK', 'AZ', 'AR', 'CA', 
    'CO', 'CT', 'DE', 'FL', 'GA', 
    'HI', 'ID', 'IL', 'IN', 'IA', 'KS', 
    'KY', 'LA', 'ME', 'MD', 'MA', 
    'MI', 'MN', 'MS', 'MO', 'MT', 
    'NE', 'NV', 'NH', 'NJ', 'NM', 
    'NY', 'NC', 'ND', 'OH', 'OK', 
    'OR', 'PA', 'RI', 'SC', 'SD', 
    'TN', 'TX', 'UT', 'VT', 'VA', 'WA', 
    'WV', 'WI', 'WY'
  ];


 @override
  void dispose() {
    _emailController.dispose();
    _areaCodeController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  bool _isValidPhoneNumber(String areaCode, String number) {
    print('Area Code: $areaCode');
    print('Number: $number');
    
    if (number.length < 7) {
      print('Number is too short');
      return false;
    }
    
    final phoneNumberRegex = RegExp(r'^\d{3}-\d{3}-\d{4}$');
    final formattedNumber = '$areaCode-${number.substring(0, 3)}-${number.substring(3)}';
    print('Formatted Number: $formattedNumber');
    return phoneNumberRegex.hasMatch(formattedNumber);
  }

  bool isValidPostalCode(String postalCode) {
    final postalCodeRegex = RegExp(r'^\d{5}$'); // Matches exactly 5 digits
    return postalCodeRegex.hasMatch(postalCode);
  }

  bool isValidPassword(String password) {
    final passwordRegex = RegExp(r'^(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');
    return passwordRegex.hasMatch(password);
  }



// Assuming the user selects an address type (e.g., home, work, etc.)
  final int _selectedAddressType = 1; // Default or user-selected
  final int _selectedPhoneType =1;
  final int _selectedEmailType = 1;

  final _apiUrl = Uri.parse('https://bakerymanagement-efgmhebnd5aggagn.eastus-01.azurewebsites.net/users'); // Replace with your API URL

  Future<void> _createAccount() async {
  final email = _emailController.text;
  final areaCode = _areaCodeController.text;
  final phoneNumber = _phoneNumberController.text;
  final postalCode = _postalCodeController.text;
  final password = _passwordController.text;

  
  
   if (!_isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid email format')),
      );
      return;
    }

    if (!_isValidPhoneNumber(areaCode, phoneNumber)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid phone number format')),
      );
      return;
    }

    if (!isValidPostalCode(postalCode)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid postal code. Please enter a 5-digit code.')),
      );
      return;
    }

  if (!isValidPassword(password)) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password must contain at least one uppercase letter, one number, and one special character.')),
    );
    return;
  }
  

    final response = await http.post(
      _apiUrl,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'username': _usernameController.text,
        'password': _passwordController.text,
        'email': {
        'emailAddress': _emailController.text,
        'emailTypeID': _selectedEmailType,  // Add dropdown or fixed value for email type
      },
        'phoneNumber': {
        'areaCode': _areaCodeController.text,  // Separate area code
        'number': _phoneNumberController.text,
        'phoneTypeID': _selectedPhoneType,  // Add dropdown or fixed value for phone type
      },
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
        iconTheme: const IconThemeData(color: Color(0xFFEEC07B)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child : Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: _firstNameController,
                  style: const TextStyle(color: Color(0xFF6D3200)),
                  decoration: const InputDecoration(labelText: 'First Name', 
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
                  controller: _lastNameController,
                  style: const TextStyle(color: Color(0xFF6D3200)),
                  decoration: const InputDecoration(labelText: 'Last Name', 
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
                  controller: _usernameController,
                  style: const TextStyle(color: Color(0xFF6D3200)),
                  decoration: const InputDecoration(labelText: 'Username',
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
                  controller: _passwordController,
                  style: const TextStyle(color: Color(0xFF6D3200)),
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password', 
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
                  controller: _emailController,
                  style: const TextStyle(color: Color(0xFF6D3200)),
                  decoration: const InputDecoration(labelText: 'Email', 
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
                  controller: _areaCodeController,  // Controller for the area code
                  style: const TextStyle(color: Color(0xFF6D3200)),
                  decoration: const InputDecoration(
                    labelText: 'Area Code',
                    labelStyle: TextStyle(color: Color(0xFF6D3200)),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF6D3200)), // Focused border color
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF6D3200)), // Enabled border color
                    ),
                  ),
                  keyboardType: TextInputType.number,  // Set input type to number for area code
                ),

                TextField(
                  controller: _phoneNumberController,  // Controller for the remaining phone number
                  style: const TextStyle(color: Color(0xFF6D3200)),
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    labelStyle: TextStyle(color: Color(0xFF6D3200)),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF6D3200)), // Focused border color
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF6D3200)), // Enabled border color
                    ),
                  ),
                  keyboardType: TextInputType.phone,  // Set input type to phone for phone number
                ),
              TextField(
                controller: _streetAddressController,
                style: const TextStyle(color: Color(0xFF6D3200)),
                decoration: const InputDecoration(labelText: 'Street Address',
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
                  controller: _cityController,
                  style: const TextStyle(color: Color(0xFF6D3200)),
                  decoration: const InputDecoration(labelText: 'City',
                  labelStyle: TextStyle(color: Color(0xFF6D3200)),
                  focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF6D3200)), // Focused border color
                  ),
                  enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF6D3200)), // Enabled border color
                  ),
                  ),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft, // Aligns the DropdownButton to the left
                child: Theme(
                  data: ThemeData(
                    hintColor: const Color(0xFFEEC07B), // Set the color of the hint text
                  ),
                  child: DropdownButton<String>(
                    value: _selectedState,
                    hint: const Text(
                      'Select State',
                      style: TextStyle(
                        color: Color(0xFF6D3200), // Hint text color
                      ),
                    ),
                    items: _states.map((state) {
                      return DropdownMenuItem<String>(
                        value: state,
                        child: Text(
                          state,
                          style: const TextStyle(color: Color(0xFF6D3200)), // Dropdown item text color
                        ),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedState = newValue;
                         _stateController.text = newValue ?? '';
                      });
                    },
                    dropdownColor: const Color(0xFFEEC07B), // Background color of the dropdown menu
                    style: const TextStyle(
                      color: Color(0xFFEEC07B), // Text color of the selected item
                      fontSize: 16, // Text size of the selected item
                    ),
                    underline: Container(
                      height: 2,
                      color: const Color(0xFF6D3200), // Underline color
                    ),
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: Color(0xFF6D3200), // Arrow color
                      ),
                  ),
                ),
              ),     
              TextField(
                  controller: _postalCodeController,
                  style: const TextStyle(color: Color(0xFF6D3200)),
                  decoration: const InputDecoration(labelText: 'Postal Code',
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
                  controller: _countryController,
                  style: const TextStyle(color: Color(0xFF6D3200)),
                  decoration: const InputDecoration(labelText: 'County',
                  labelStyle: TextStyle(color: Color(0xFF6D3200)),
                  focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF6D3200)), // Focused border color
                  ),
                  enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF6D3200)), // Enabled border color
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
      ),
    ),
  );
}
}