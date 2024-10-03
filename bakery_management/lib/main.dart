import 'package:flutter/material.dart';
import 'package:bakery_management/pages/inventory.dart';
import 'package:bakery_management/pages/recipe.dart';
import 'package:bakery_management/pages/vendors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:bakery_management/pages/bakedgoods.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bakery_management/pages/sessions.dart';


  void _logout(BuildContext context) async {
    // Your logout logic here
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('username'); // Clear the saved username
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SignInPage()),
    );
  }

  void _navigateToUserOptions(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const UserActionSelectionPage()),
  );
}


  
  Future<String?> getUsername() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('username');
}
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
    print('Response status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
       await prefs.setString('username', _usernameController.text); 
      final responseBody = jsonDecode(response.body);
      print('Decoded response body: $responseBody');

      final employeeId = responseBody['employee_id'];
      await prefs.setString('employeeId', employeeId);
      print('Employee ID: $employeeId');
      final firstName = responseBody['first_name']; // Get first name from response
      final jobId = responseBody['job_id'];

      await prefs.setString('firstName', firstName); // Save first name
      await prefs.setInt('jobId', jobId); // Save job ID

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
      final sessionResponseBody = jsonDecode(sessionResponse.body);
      final sessionId = sessionResponseBody['session_id'];  
      await prefs.setInt('sessionId', sessionId);
      print('Session ID: $sessionId');
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
  void _navigateToForgotPassword() {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
  );
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text("Welcome to Flour & Fantasy!"),
      centerTitle: true,
      backgroundColor: const Color(0xFF422308),
      foregroundColor: const Color(0xFFEEC07B),
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Add the image here
          Image.asset(
            'assets/Final_logo2.png',
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
          // Forgot Password Button
         // TextButton(
           // onPressed: _navigateToForgotPassword,
           // child: const Text(
         //     'Forgot Password?',
          //    style: TextStyle(color: Colors.blue),
          //  ),
        //  ),
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


class BakeryHomePage extends StatefulWidget {
  const BakeryHomePage({super.key});

  @override
  _BakeryHomePageState createState() => _BakeryHomePageState();
}

class _BakeryHomePageState extends State<BakeryHomePage> {
  int _selectedIndex = 0; // Track selected tab
  String firstName = "User";
  int? sessionID;
  

  // List of pages corresponding to each tab (Home, Vendors, Recipes, Inventory, Baked Goods, Options)
  final List<Widget> _pages = [
    const HomePage(),          // New Home Page
    const VendorsPage(),
    const RecipePage(),
    const InventoryPage(),
    const ProductsPage(),
    const OptionsPage(),       // Options Page for handling user options and logout
  ];

  // Handler for when a bottom navigation item is tapped
  void _onItemTapped(int index) async{
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
  setState(() {
    _selectedIndex = index;
  });
  }
   @override
  void initState() {
    super.initState();
    _loadFirstName(); // Load first name when the widget is initialized
    _loadSessionID();
  }
   Future<void> _loadFirstName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      firstName = prefs.getString('firstName') ?? "User"; // Default to "User" if not found
    });
  }
  Future<void> _loadSessionID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      sessionID = prefs.getInt('sessionId'); // Default to "User" if not found
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
        title: null, // Remove the title to use FlexibleSpaceBar
       flexibleSpace: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 10.0), // Adjust this value to scoot the image up
          child: _selectedIndex == 0 // Check if the selected index is 0 (Home Page)
              ? Text(
                  'Hi $firstName!', // Display the greeting
                  style: TextStyle(
                    fontSize: 24,
                    color: const Color.fromARGB(255, 243, 217, 162),
                  ), // Customize the text style as needed
                )
              : Container(), // Show an empty container for other pages
        ),
      ),
        centerTitle: true,
        backgroundColor: const Color(0xFF422308),
         leading: PopupMenuButton<String>(
          icon: const Icon(Icons.menu),
          onSelected: (value) {
            if (value == 'logout') {
              _logout(context);
            } else if (value == 'userOptions') {
              _navigateToUserOptions(context);
            }
          },
          itemBuilder: (BuildContext context) {
            return [
              const PopupMenuItem<String>(
                value: 'userOptions',
                child: Text('User Options'),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Text('Logout'),
              ),
            ];
          },
        ),
      ),
      backgroundColor: const Color(0xFFF0D1A0),
      body: _pages[_selectedIndex], // Display the selected page

      // Bottom navigation bar
bottomNavigationBar: BottomNavigationBar(
  type: BottomNavigationBarType.fixed, // Ensures background color is applied
  backgroundColor: const Color(0xFF422308), // Dark brown background color
  selectedItemColor: const Color(0xFFEEC07B), // Light brown text for selected item
  unselectedItemColor: const Color(0xFFB89C78), // Light brown text for unselected items
  showSelectedLabels: true, // Always show full label for selected tab
  showUnselectedLabels: true, // Always show full label for unselected tabs
  items: const <BottomNavigationBarItem>[
    BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: 'Home',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.store),
      label: 'Vendors',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.book),
      label: 'Recipes',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.inventory),
      label: 'Stock', // Ensure the full label is displayed
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.cake),
      label: 'Treats', // Ensure the full label is displayed
    ),
   // BottomNavigationBarItem(
     // icon: Icon(Icons.settings),
      //label: 'Options',
    //),
  ],
  currentIndex: _selectedIndex, // Highlight the selected tab
  onTap: _onItemTapped, // Handle tab tap
),

    );
  }
}

// Home Page widget
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
Widget build(BuildContext context) {
  return Column(
    children: [
      // Directly stacking the image and text
      Expanded(
        child: Align(
          alignment: Alignment.topCenter, // Aligns at the top center
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(
                'assets/Final_logo.png',
                width: 300,
                height: 300,
              ),
              Positioned(
                top: 40, // Adjust this value to move text closer to the image
                child: Text(
                  'Welcome to',
                  style: TextStyle(
                    fontSize: 24,
                    fontFamily: 'MyFont',
                    color: Colors.brown[900],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

}


// Options Page for handling User Options and Logout
class OptionsPage extends StatelessWidget {
  const OptionsPage({super.key});

  void _logout(BuildContext context) {
    // Implement your logout logic here
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text('Logout'),
              onPressed: () async{
                SharedPreferences prefs = await SharedPreferences.getInstance();
                  int? sessionId = prefs.getInt('sessionId'); // Get the sessionId as an int

                  if (sessionId != null) {
                  // Create an instance of SessionService
                  SessionService sessionService = SessionService(context);

        
                  // If the session is active, update it
                  await sessionService.updateSession(sessionId); // Update the session to keep it alive

      
                  }

                // Perform logout action here
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  void _navigateToUserOptions(BuildContext context) {
    // Implement navigation to user options page
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const UserOptionsPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () => _navigateToUserOptions(context),
            child: const Text('User Options'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF422308), // Dark brown button
              foregroundColor: const Color(0xFFEEC07B), // Light brown text
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _logout(context),
            child: const Text('Logout'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF422308), // Dark brown button
              foregroundColor: const Color(0xFFEEC07B), // Light brown text
            ),
          ),
        ],
      ),
    );
  }
}

// User Options Page (you can customize it further)
class UserOptionssPage extends StatelessWidget {
  const UserOptionssPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Options'),
        backgroundColor: const Color(0xFF422308),
      ),
      body: Center(
        child: const Text('User Options Page Content'),
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
                    hintColor: const Color(0xFFEEC07B), 
                    

                  ),
                  child: DropdownButton<String>(
                    value: _selectedState,
                    hint: const Text(
                      'Select State',
                      style: TextStyle(
                        color: Color(0xFF6D3200), // Hint text color
                        fontFamily: 'MyFont',
                      ),
                    ),
                    items: _states.map((state) {
                      return DropdownMenuItem<String>(
                        value: state,
                        child: Text(
                          state,
                          style: const TextStyle(color: Color(0xFF6D3200),
                          fontFamily: 'MyFont',), // Dropdown item text color
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
                  decoration: const InputDecoration(labelText: 'Country',
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

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();

  Future<void> _resetPassword() async {
    final response = await http.post(
      Uri.parse('https://bakerymanagement-efgmhebnd5aggagn.eastus-01.azurewebsites.net/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': _emailController.text}),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset link sent to your email')),
      );
      Navigator.pop(context); // Return to Sign In page
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send password reset link')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Enter your email address and we will send you a link to reset your password.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _resetPassword,
              child: const Text('Send Reset Link'),
            ),
          ],
        ),
      ),
    );
  }
}


class UserOptionsPage extends StatefulWidget {
  const UserOptionsPage({super.key});

  @override
  _UserOptionsPageState createState() => _UserOptionsPageState();
}
class _UserOptionsPageState extends State<UserOptionsPage> {
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
  final int _selectedAddressType = 1; // Default or user-selected
  final int _selectedPhoneType =1;
  final int _selectedEmailType = 1;
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

bool _isValidEmail(String? email) {
  if (email == null || email.isEmpty) return true; // Skip validation if not provided
  final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  return emailRegex.hasMatch(email);
}

bool _isValidPhoneNumber(String? areaCode, String? number) {
  if ((areaCode == null || areaCode.isEmpty) || (number == null || number.isEmpty)) return true; // Skip validation if not provided
  
  if (number.length < 7) {
    return false; // Number must be at least 7 digits
  }
  
  final phoneNumberRegex = RegExp(r'^\d{3}-\d{3}-\d{4}$');
  final formattedNumber = '$areaCode-${number.substring(0, 3)}-${number.substring(3)}';
  return phoneNumberRegex.hasMatch(formattedNumber);
  }

  bool isValidPostalCode(String? postalCode) {
  if (postalCode == null || postalCode.isEmpty) return true; // Skip validation if not provided
  final postalCodeRegex = RegExp(r'^\d{5}$'); // Matches exactly 5 digits
  return postalCodeRegex.hasMatch(postalCode);
}

bool isValidPassword(String? password) {
  if (password == null || password.isEmpty) return true; // Skip validation if not provided
  final passwordRegex = RegExp(r'^(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');
  return passwordRegex.hasMatch(password);
}



  String? _username; 
  String? _employeeId; 
  List<dynamic> emails = [];
  List<dynamic> phoneNumbers = [];
  String? selectedEmail;
  String? selectedPhoneNumber;

  @override
  void initState() {
    super.initState();
    _loadEmployeeId();
    _loadUsername(); // Load the username when the state is initialized
      //fetchContacts(_username); // Call fetchContacts on init
  }

Future<void> _loadEmployeeId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  setState(() {
    _employeeId = prefs.getString('employeeId'); // Retrieve the stored employeeId
    print('Employee ID: $_employeeId');
  });

  // Call fetchContacts after loading the employeeId
  if (_employeeId != null) {
    await fetchContacts(_employeeId);
  } else {
    print('Employee ID is null, cannot fetch contacts');
  }
}

Future<void> _loadUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username'); // Retrieve the stored username
      print(_username);
      // Optionally, you can set the username controller's text if you want to pre-fill it
      _usernameController.text = _username ?? '';
      });
          
  }

  Future<void> fetchContacts(String? employeeId) async {
  print('Fetching contacts for employee ID: $employeeId');
  final response = await http.get(
    Uri.parse('https://bakerymanagement-efgmhebnd5aggagn.eastus-01.azurewebsites.net/employee/$employeeId/contacts')
  );
  
  print('Response status code: ${response.statusCode}');
  
  if (response.statusCode == 200) {
    print('Response body: ${response.body}');
    final data = jsonDecode(response.body);
    setState(() {
      emails = data['emails'] ?? [];
      phoneNumbers = data['phoneNumbers'] ?? [];
    });
  } else {
    print('Failed to fetch contacts');
  }
}


  

  Future<void> _updateUser() async {
    if (_username == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username not found')),
      );
      return;
    }
final email = _emailController.text;
final areaCode = _areaCodeController.text;
final phoneNumber = _phoneNumberController.text;
final postalCode = _postalCodeController.text;
final password = _passwordController.text;
// Email validation
 if (!_isValidEmail(email)) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Invalid email format')),
  );
  return;
}

// Phone number validation
if (!_isValidPhoneNumber(areaCode, phoneNumber)) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Invalid phone number format')),
  );
  return;
}

// Postal code validation
if (!isValidPostalCode(postalCode)) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Invalid postal code. Please enter a 5-digit code.')),
  );
  return;
}

// Password validation
if (!isValidPassword(password)) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Password must contain at least one uppercase letter, one number, and one special character.')),
  );
  return;
} 
    final response = await http.put(
      Uri.parse('https://bakerymanagement-efgmhebnd5aggagn.eastus-01.azurewebsites.net/users/$_username'),
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

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User updated successfully')),
      );
      Navigator.pop(context); // Go back to the previous screen
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update user')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
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
                // Dropdown for selecting email
                Container(
                  alignment: Alignment.centerLeft, // Align to the left
                  child: DropdownButton<String>(
                    value: selectedEmail,
                    hint: const Text(
                      'Select Email',
                      style: TextStyle(
                        color: Color(0xFF6D3200), // Hint text color
                        fontFamily: 'MyFont',
                      ),
                    ),
                    items: emails.map((email) {
                      return DropdownMenuItem<String>(
                        value: email['EmailAddress'], // Use EmailAddress as the unique value
                        child: Text(
                          email['EmailAddress'],
                          style: const TextStyle(
                            color: Color(0xFF6D3200), // Dropdown item text color
                            fontFamily: 'MyFont',
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedEmail = value!;
                        _emailController.text = value;
                      });
                    },
                    dropdownColor: const Color(0xFFEEC07B), // Background color of the dropdown menu
                    style: const TextStyle(
                      color: Color(0xFF6D3200), // Text color of the selected item
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

                // Dropdown for selecting phone number
                Container(
                  alignment: Alignment.centerLeft, // Align to the left
                  child: DropdownButton<String>(
                    value: selectedPhoneNumber,
                    hint: const Text(
                      'Select Phone Number',
                      style: TextStyle(
                        color: Color(0xFF6D3200), // Hint text color
                        fontFamily: 'MyFont',
                      ),
                    ),
                    items: phoneNumbers.map((phone) {
                      return DropdownMenuItem<String>(
                        value: phone['Number'], // Use Number as the unique value
                        child: Text(
                          '${phone['AreaCode']} - ${phone['Number']}',
                          style: const TextStyle(
                            color: Color(0xFF6D3200), // Dropdown item text color
                            fontFamily: 'MyFont',
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedPhoneNumber = value!;
                        final selectedPhone = phoneNumbers.firstWhere((phone) => phone['Number'] == value);
                        _areaCodeController.text = selectedPhone['AreaCode'];
                        _phoneNumberController.text = selectedPhone['Number'];
                      });
                    },
                    dropdownColor: const Color(0xFFEEC07B), // Background color of the dropdown menu
                    style: const TextStyle(
                      color: Color(0xFF6D3200), // Text color of the selected item
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

                        // Email Address TextField
                        TextField(
                          controller: _emailController,
                          style: const TextStyle(color: Color(0xFF6D3200)), // Text color
                          decoration: const InputDecoration(
                            labelText: 'Email Address',
                            labelStyle: TextStyle(color: Color(0xFF6D3200)), // Label text color
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF6D3200)), // Focused border color
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF6D3200)), // Enabled border color
                            ),
                          ),
                        ),

                        // Area Code TextField
                        TextField(
                          controller: _areaCodeController,
                          style: const TextStyle(color: Color(0xFF6D3200)), // Text color
                          decoration: const InputDecoration(
                            labelText: 'Area Code',
                            labelStyle: TextStyle(color: Color(0xFF6D3200)), // Label text color
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF6D3200)), // Focused border color
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF6D3200)), // Enabled border color
                            ),
                          ),
                        ),

                        // Phone Number TextField
                        TextField(
                          controller: _phoneNumberController,
                          style: const TextStyle(color: Color(0xFF6D3200)), // Text color
                          decoration: const InputDecoration(
                            labelText: 'Phone Number',
                            labelStyle: TextStyle(color: Color(0xFF6D3200)), // Label text color
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF6D3200)), // Focused border color
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF6D3200)), // Enabled border color
                            ),
                          ),
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
                    hintColor: const Color(0xFFEEC07B), 
                  ),
                  child: DropdownButton<String>(
                    value: _selectedState,
                    hint: const Text(
                      'Select State',
                      style: TextStyle(
                        color: Color(0xFF6D3200), // Hint text color
                        fontFamily: 'MyFont',
                      ),
                    ),
                    items: _states.map((state) {
                      return DropdownMenuItem<String>(
                        value: state,
                        child: Text(
                          state,
                          style: const TextStyle(color: Color(0xFF6D3200),
                          fontFamily: 'MyFont',), // Dropdown item text color
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
            Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              // Cancel Button
              ElevatedButton(
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
                  Navigator.pop(context); // Go back to the previous page
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: const Color(0xFF6D3200),
                      backgroundColor: Colors.transparent, // No background color
                      shadowColor: Colors.transparent,
                ),
                child: const Text('Cancel'),
              ),
              // Update User Button
              ElevatedButton(
                onPressed: _updateUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF422308), // Background color
                  foregroundColor: const Color(0xFFEEC07B), // Text color
                ),
                child: const Text('Update User'),
              ),
            ],
            ),
          ],
        ),
      ),
    );
  }
}
class UserActionSelectionPage extends StatelessWidget {
  const UserActionSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(  // Center the entire content
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,  // Allows the column to take minimum space
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'What would you like to do?',
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF6D3200),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Navigate to the update page
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const UserOptionsPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF422308),
                  foregroundColor: const Color(0xFFEEC07B),
                ),
                child: const Text('Update Information'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
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
                  // Navigate to the add page
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddInformationPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF422308),
                  foregroundColor: const Color(0xFFEEC07B),
                ),
                child: const Text('Add Information'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
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
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: const Color(0xFF6D3200),
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                ),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}




class AddInformationPage extends StatefulWidget {
  const AddInformationPage({super.key});

  @override
  _AddInformationPageState createState() => _AddInformationPageState();
}

class _AddInformationPageState extends State<AddInformationPage> {

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _areaCodeController = TextEditingController();

  String? _selectedEmailType;
  String? _selectedPhoneType;
  String? employeeId;

  final List<String> emailTypes = ['Personal', 'Work', 'Billing', 'Support', 'Other'];
  final List<String> phoneTypes = ['Mobile', 'Home', 'Work', 'Fax', 'Other'];

  @override
  void initState() {
    super.initState();
    _loadEmployeeId(); // Load the employee ID when the page initializes
  }

 bool _isValidEmail(String? email) {
  if (email == null || email.isEmpty) return true; // Skip validation if not provided
  final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  return emailRegex.hasMatch(email);
}

bool _isValidPhoneNumber(String? areaCode, String? number) {
  if ((areaCode == null || areaCode.isEmpty) || (number == null || number.isEmpty)) return true; // Skip validation if not provided
  
  if (number.length < 7) {
    return false; // Number must be at least 7 digits
  }
  
  final phoneNumberRegex = RegExp(r'^\d{3}-\d{3}-\d{4}$');
  final formattedNumber = '$areaCode-${number.substring(0, 3)}-${number.substring(3)}';
  return phoneNumberRegex.hasMatch(formattedNumber);
}

 
  Future<void> _loadEmployeeId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      employeeId = prefs.getString('employeeId'); // Retrieve the employee ID
    });
  }


  Future<void> _addInformation() async {
    final email = _emailController.text;
    final areaCode = _areaCodeController.text;
    final phoneNumber = _phoneController.text;

// Email validation
if (!_isValidEmail(email)) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Invalid email format')),
  );
  return;
}

// Phone number validation
if (!_isValidPhoneNumber(areaCode, phoneNumber)) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Invalid phone number format')),
  );
  return;
} 

    // Prepare the data to send
   final contactData = {
  'emailAddress': _emailController.text.isNotEmpty ? _emailController.text : null,
  'emailTypeID': _emailController.text.isNotEmpty ? _getEmailTypeID(_selectedEmailType) : null,
  'employeeID': employeeId, // Replace with actual employeeID
  'areaCode': _areaCodeController.text.isNotEmpty ? _areaCodeController.text : null,
  'phoneNumber': _phoneController.text.isNotEmpty ? _phoneController.text : null,
  'phoneTypeID': _phoneController.text.isNotEmpty ? _getPhoneTypeID(_selectedPhoneType) : null,
};

// Send the combined data to your new API endpoint
final response = await http.post(
  Uri.parse('https://bakerymanagement-efgmhebnd5aggagn.eastus-01.azurewebsites.net/contacts'),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode(contactData),
);

// Handle the response
if (response.statusCode == 200) {
 ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Information added successfully!')),
      );
} else {
  // Error handling
  ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error occured')),
      );
}

  }

  int _getEmailTypeID(String? type) {
    switch (type) {
      case 'Personal':
        return 1;
      case 'Work':
        return 2;
      case 'Billing':
        return 3;
      case 'Support':
        return 4;
      case 'Other':
        return 5;
      default:
        return 1; // Default to Personal
    }
  }

  int _getPhoneTypeID(String? type) {
    switch (type) {
      case 'Mobile':
        return 1;
      case 'Home':
        return 2;
      case 'Work':
        return 3;
      case 'Fax':
        return 4;
      case 'Other':
        return 5;
      default:
        return 1; // Default to Mobile
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Email field
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
            // Email type dropdown

            
            DropdownButton<String>(
              value: _selectedEmailType,
              hint: const Text(
                'Select Email Type',
                style: TextStyle(
                  color: Color(0xFF6D3200), // Hint text color
                  fontFamily: 'MyFont',
                ),
              ),
              items: emailTypes.map((String type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(
                    type,
                    style: const TextStyle(
                      color: Color(0xFF6D3200), // Dropdown item text color
                      fontFamily: 'MyFont',
                    ),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedEmailType = newValue;
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

            const SizedBox(height: 20),
            // Phone area code field
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
                  controller: _phoneController,  // Controller for the remaining phone number
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
            // Phone type dropdown
            DropdownButton<String>(
              value: _selectedPhoneType,
              hint: const Text(
                'Select Phone Type',
                style: TextStyle(
                  color: Color(0xFF6D3200), // Hint text color
                  fontFamily: 'MyFont',
                ),
              ),
                items: phoneTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(
                      type,
                      style: const TextStyle(
                        color: Color(0xFF6D3200), // Dropdown item text color
                        fontFamily: 'MyFont',
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                setState(() {
                  _selectedPhoneType = newValue;
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

            const SizedBox(height: 20),
            // Add Information button
             Row(
                mainAxisAlignment: MainAxisAlignment.center, // Center the buttons horizontally
                children: [
                  // Add Information button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: const Color(0xFF6D3200),
                      backgroundColor: Colors.transparent, // No background color
                      shadowColor: Colors.transparent,
                    ),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 20), // Space between buttons
                  // Cancel button
                  ElevatedButton(
                    onPressed: _addInformation,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: const Color(0xFFEEC07B),
                      backgroundColor: const Color(0xFF422308),
                    ),
                    child: const Text('Add Information'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
