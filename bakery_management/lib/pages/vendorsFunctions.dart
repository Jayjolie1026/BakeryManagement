import 'package:flutter/material.dart';
import 'vendorsItemClass.dart';
import 'vendorsAPI.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'vendors.dart';

// Fetch vendor details from the API
Future<Vendor> fetchVendorDetails(int id) async {
  try {
    final response = await http.get(Uri.parse('https://bakerymanagement-efgmhebnd5aggagn.eastus-01.azurewebsites.net/vendors/$id'));

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);
      print('Vendor Details JSON: $json'); // Debugging line
      return Vendor.fromJson(json);
    } else {
      print('Failed to load vendor details. Status code: ${response.statusCode}');
      throw Exception('Failed to load vendor details');
    }
  } catch (e) {
    print('Error: $e');
    throw Exception('Failed to load vendor details');
  }
}

void showVendorDetails(BuildContext context, Vendor vendor) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => VendorDetailsPage(vendorID: vendor.vendorID),
    ),
  );
}


// Show dialog to add a new vendor
void showAddVendorDialog(BuildContext context, VoidCallback onVendorAdded) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      int vendorID = 0;
      String vendorName = '';
      String vendorAreaCode = '';
      String vendorPhoneNum = '';
      String vendorEmail = '';
      String streetAddress = '';
      String city = '';
      String state = '';
      String postalCode = '';
      String country = '';

      return AlertDialog(
        title: const Text('Add Vendor'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Vendor ID'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  vendorID = int.tryParse(value) ?? 0;
                },
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Name'),
                onChanged: (value) {
                  vendorName = value;
                },
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Area Code'),
                keyboardType: TextInputType.phone,
                onChanged: (value) {
                  vendorAreaCode = value;
                },
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
                onChanged: (value) {
                  vendorPhoneNum = value;
                },
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) {
                  vendorEmail = value;
                },
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Street Address'),
                onChanged: (value) {
                  streetAddress = value;
                },
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'City'),
                onChanged: (value) {
                  city = value;
                },
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'State'),
                onChanged: (value) {
                  state = value;
                },
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Postal Code'),
                onChanged: (value) {
                  postalCode = value;
                },
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Country'),
                onChanged: (value) {
                  country = value;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          ElevatedButton(
            child: const Text('Add'),
            onPressed: () async {
              if (vendorName.isEmpty ||
                  vendorAreaCode.isEmpty ||
                  vendorPhoneNum.isEmpty ||
                  vendorEmail.isEmpty ||
                  streetAddress.isEmpty ||
                  city.isEmpty ||
                  state.isEmpty ||
                  postalCode.isEmpty ||
                  country.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill out all fields')),
                );
                return;
              }

              try {
                // Add vendor using the provided details
                await addVendor(
                  vendorID,
                  vendorName,
                  vendorAreaCode,
                  vendorPhoneNum,
                  vendorEmail,
                  streetAddress,
                  city,
                  state,
                  postalCode,
                  country,
                );
                Navigator.of(context).pop();
                onVendorAdded(); // Call the callback to refresh the list
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error adding vendor: $e')),
                );
              }
            },
          ),
        ],
      );
    },
  );
}

// Function to edit vendor details
void editVendor(BuildContext context, Vendor vendor) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => EditVendorPage(vendor: vendor.vendorID),
    ),
  );
}

// Function to remove vendor
Future<void> removeVendor(BuildContext context, Vendor vendor) async {
  final response = await http.delete(
    Uri.parse('https://bakerymanagement-efgmhebnd5aggagn.eastus-01.azurewebsites.net/vendors/${vendor.vendorID}'),
  );

  if (response.statusCode == 200) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Vendor removed successfully'),
        action: SnackBarAction(
          label: 'Close',
          onPressed: () {
            Navigator.of(context).pop(); // Close the snackbar
          },
        ),
      ),
    );
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Vendor Removed'),
          content: const Text('The vendor has been successfully removed.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pop(); // Go back to previous screen
                // Optionally, refresh the page
                // Navigator.of(context).pushReplacement(MaterialPageRoute(
                //   builder: (context) => VendorListPage(), // Replace with your vendor list page
                // ));
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Failed to remove vendor'),
        action: SnackBarAction(
          label: 'Close',
          onPressed: () {
            Navigator.of(context).pop(); // Close the snackbar
          },
        ),
      ),
    );
  }
}