import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

@override
Widget build(BuildContext context) {
  // Sample vendor names
  final List<String> vendorNames = List.generate(10, (index) => 'Vendor ${index + 1}');

  return Scaffold(
    appBar: AppBar(
      title: const Text(
        'Order Managements',
        style: TextStyle(
          color: Color(0xFF422308), // Set the text color
        ),
      ),
      centerTitle: true,
      backgroundColor: const Color(0xFFd8c4aa),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        color: const Color(0xFF422308), // Color of the back arrow
        onPressed: () {
          Navigator.pop(context); // Go back to the previous screen
        },
      ),
    ),
    backgroundColor: const Color(0xFFF0d1a0),
    body: Column(
      children: [
        const SizedBox(height: 20),
        // Image section
        Container(
          padding: const EdgeInsets.all(16.0),
          child: Image.asset(
            'assets/vendor.png', // Replace with your image path
            height: 150, // Adjust the height to fit the AppBar
            fit: BoxFit.contain, // Ensures the image scales without being cut off
          ),
        ),
        const SizedBox(height: 20),
        // Centered search bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search for a vendor...', // Placeholder text
              prefixIcon: const Icon(Icons.search), // Search icon inside the field
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              filled: true, // Give the search bar a background color
              fillColor: const Color(0xFFd8c4aa),
            ),
          ),
        ),
        const SizedBox(height: 20), // Space between search bar and other content
        Expanded(
          child: ListView.builder(
            itemCount: vendorNames.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  // Navigate to the DetailedVendorPage when the box is tapped
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DetailedVendorPage(),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0), // Space between rows
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFeec07b), // Background color for each entry
                    borderRadius: BorderRadius.circular(8.0), // Rounded corners
                  ),
                  child: Center(
                    child: Text(
                      vendorNames[index],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0), // Padding around the button
          child: ElevatedButton(
            onPressed: () {
              // Define the action when the button is pressed
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddVendorPage(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: const Color(0xFFeec07b), // Text color of the button
              backgroundColor: const Color(0xFF422308), // Background color of the button
              minimumSize: const Size(double.infinity, 70), // Button width and height
              padding: const EdgeInsets.symmetric(horizontal: 20), // Padding inside the button
            ),
            child: const Text(
              'Add a Vendor',
              style: TextStyle(fontSize: 20),
            ),
          ),
        ),
      ],
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
      title: const Text(
        'Order Managements',
        style: TextStyle(
          color: Color(0xFF422308), // Set the text color
        ),
      ),
      centerTitle: true,
      backgroundColor: const Color(0xFFd8c4aa),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        color: const Color(0xFF422308), // Color of the back arrow
        onPressed: () {
          Navigator.pop(context); // Go back to the previous screen
        },
      ),
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