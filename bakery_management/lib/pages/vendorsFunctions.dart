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
      builder: (context) => VendorDetailsPage(vendor: vendor),
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

Future<void> handleRemoveVendor(BuildContext context, Vendor vendor) async {
  if (vendor.vendorID == null) {
    // Handle case where vendorID is null
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: const Text('Vendor ID is null, cannot delete vendor.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    return;
  }

  final shouldDelete = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Confirm Deletion'),
      content: const Text('Are you sure you want to delete this vendor?'),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );

  if (shouldDelete == true) {
    try {
      final response = await http.delete(
        Uri.parse('https://bakerymanagement-efgmhebnd5aggagn.eastus-01.azurewebsites.net/vendors/${vendor.vendorID}'),
      );

      if (response.statusCode == 200) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Success'),
            content: const Text('Vendor has been deleted successfully.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the success dialog
                  Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => VendorsPage(),
                  ),
                  (Route<dynamic> route) => false, // Remove all previous routes
                  );
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        throw Exception('Failed to remove vendor');
      }
    } catch (e) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('Failed to remove vendor: $e'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}




