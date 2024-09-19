import 'package:flutter/material.dart';
import 'vendorsItemClass.dart';
import 'vendorsAPI.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

Future<void> showAddVendorDialog(BuildContext context, VoidCallback onVendorAdded) async {
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
        backgroundColor: const Color(0xFFEEC07B), // Light brown background
        title: const Text(
          'Add Vendor',
          style: TextStyle(
            color: Color(0xFF6D3200), // Dark brown text
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'Vendor ID',
                  labelStyle: TextStyle(color: Color(0xFF6D3200)), // Dark brown label text
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  vendorID = int.tryParse(value) ?? 0;
                },
              ),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Name',
                  labelStyle: TextStyle(color: Color(0xFF6D3200)), // Dark brown label text
                ),
                onChanged: (value) {
                  vendorName = value;
                },
              ),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Area Code',
                  labelStyle: TextStyle(color: Color(0xFF6D3200)), // Dark brown label text
                ),
                keyboardType: TextInputType.phone,
                onChanged: (value) {
                  vendorAreaCode = value;
                },
              ),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  labelStyle: TextStyle(color: Color(0xFF6D3200)), // Dark brown label text
                ),
                keyboardType: TextInputType.phone,
                onChanged: (value) {
                  vendorPhoneNum = value;
                },
              ),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Color(0xFF6D3200)), // Dark brown label text
                ),
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) {
                  vendorEmail = value;
                },
              ),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Street Address',
                  labelStyle: TextStyle(color: Color(0xFF6D3200)), // Dark brown label text
                ),
                onChanged: (value) {
                  streetAddress = value;
                },
              ),
              TextField(
                decoration: InputDecoration(
                  labelText: 'City',
                  labelStyle: TextStyle(color: Color(0xFF6D3200)), // Dark brown label text
                ),
                onChanged: (value) {
                  city = value;
                },
              ),
              TextField(
                decoration: InputDecoration(
                  labelText: 'State',
                  labelStyle: TextStyle(color: Color(0xFF6D3200)), // Dark brown label text
                ),
                onChanged: (value) {
                  state = value;
                },
              ),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Postal Code',
                  labelStyle: TextStyle(color: Color(0xFF6D3200)), // Dark brown label text
                ),
                onChanged: (value) {
                  postalCode = value;
                },
              ),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Country',
                  labelStyle: TextStyle(color: Color(0xFF6D3200)), // Dark brown label text
                ),
                onChanged: (value) {
                  country = value;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel' , style: TextStyle(color: Colors.black)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          ElevatedButton(
            child: const Text('Add'),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Color(0xFF6D3200)), // Dark brown background
              foregroundColor: MaterialStateProperty.all(Color(0xFFEEC07B)), // Light brown text
            ),
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

Future<bool> handleEditVendor(BuildContext context, Vendor vendor) async {
  // Controllers to pre-fill the data
  final nameController = TextEditingController(text: vendor.vendorName);
  final areaCodeController = TextEditingController(text: vendor.phoneNumbers.isNotEmpty ? vendor.phoneNumbers.first.areaCode : '');
  final phoneController = TextEditingController(text: vendor.phoneNumbers.isNotEmpty ? vendor.phoneNumbers.first.phoneNumber : '');
  final emailController = TextEditingController(text: vendor.emails.isNotEmpty ? vendor.emails.first.emailAddress : '');
  final streetController = TextEditingController(text: vendor.addresses.isNotEmpty ? vendor.addresses.first.streetAddress : '');
  final cityController = TextEditingController(text: vendor.addresses.isNotEmpty ? vendor.addresses.first.city : '');
  final stateController = TextEditingController(text: vendor.addresses.isNotEmpty ? vendor.addresses.first.state : '');
  final postalCodeController = TextEditingController(text: vendor.addresses.isNotEmpty ? vendor.addresses.first.postalCode : '');
  final countryController = TextEditingController(text: vendor.addresses.isNotEmpty ? vendor.addresses.first.country : '');

  final result = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: const Color(0xFFEEC07B), // Light brown background
        title: const Text(
          'Edit Vendor Info',
          style: TextStyle(color: Color(0xFF6D3200)), // Dark brown text
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  labelStyle: TextStyle(color: Color(0xFF6D3200)), // Dark brown label text
                ),
              ),
              TextField(
                controller: areaCodeController,
                decoration: InputDecoration(
                  labelText: 'Area Code',
                  labelStyle: TextStyle(color: Color(0xFF6D3200)), // Dark brown label text
                ),
                keyboardType: TextInputType.phone,
              ),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  labelStyle: TextStyle(color: Color(0xFF6D3200)), // Dark brown label text
                ),
                keyboardType: TextInputType.phone,
              ),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Color(0xFF6D3200)), // Dark brown label text
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: streetController,
                decoration: InputDecoration(
                  labelText: 'Street Address',
                  labelStyle: TextStyle(color: Color(0xFF6D3200)), // Dark brown label text
                ),
              ),
              TextField(
                controller: cityController,
                decoration: InputDecoration(
                  labelText: 'City',
                  labelStyle: TextStyle(color: Color(0xFF6D3200)), // Dark brown label text
                ),
              ),
              TextField(
                controller: stateController,
                decoration: InputDecoration(
                  labelText: 'State',
                  labelStyle: TextStyle(color: Color(0xFF6D3200)), // Dark brown label text
                ),
              ),
              TextField(
                controller: postalCodeController,
                decoration: InputDecoration(
                  labelText: 'Postal Code',
                  labelStyle: TextStyle(color: Color(0xFF6D3200)), // Dark brown label text
                ),
              ),
              TextField(
                controller: countryController,
                decoration: InputDecoration(
                  labelText: 'Country',
                  labelStyle: TextStyle(color: Color(0xFF6D3200)), // Dark brown label text
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel' , style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () async {
              final shouldEdit = await showDialog<bool>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    backgroundColor: const Color(0xFFEEC07B), // Light brown background
                    title: const Text(
                      'Confirm Edit',
                      style: TextStyle(color: Color(0xFF6D3200)), // Dark brown text
                    ),
                    content: const Text('Are you sure you want to save the changes?'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel' , style: TextStyle(color: Colors.black)),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Confirm'),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Color(0xFF6D3200)), // Dark brown background
                          foregroundColor: MaterialStateProperty.all(Color(0xFFEEC07B)), // Light brown text
                        ),
                      ),
                    ],
                  );
                },
              );

              if (shouldEdit == true) {
                await updateVendor(
                  vendor.vendorID,
                  nameController.text,
                  areaCodeController.text,
                  phoneController.text,
                  emailController.text,
                  streetController.text,
                  cityController.text,
                  stateController.text,
                  postalCodeController.text,
                  countryController.text,
                );

                await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor: const Color(0xFFEEC07B), // Light brown background
                      title: const Text(
                        'Success',
                        style: TextStyle(color: Color(0xFF6D3200)), // Dark brown text
                      ),
                      content: const Text('Vendor details have been updated.'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('OK'),
                          style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Color(0xFF6D3200)), // Dark brown background
                          foregroundColor: MaterialStateProperty.all(Color(0xFFEEC07B)), // Light brown text
                        ),
                        ),
                      ],
                    );
                  },
                );

                Navigator.of(context).pop(true); // Indicate success
              }
            },
            child: const Text('Save Changes'),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Color(0xFF6D3200)), // Dark brown background
              foregroundColor: MaterialStateProperty.all(Color(0xFFEEC07B)), // Light brown text
            ),
          ),
        ],
      );
    },
  );

  return result ?? false;
}

Future<bool> handleRemoveVendor(BuildContext context, int id) async {
  final shouldDelete = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: const Color(0xFFEEC07B), // Light brown background
      title: const Text(
        'Confirm Deletion',
        style: TextStyle(color: Color(0xFF6D3200)), // Dark brown text
      ),
      content: const Text('Are you sure you want to delete this vendor?'),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel', style: TextStyle(color: Colors.black)),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Delete'),
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Color(0xFF6D3200)), // Dark brown background
            foregroundColor: MaterialStateProperty.all(Color(0xFFEEC07B)), // Light brown text
          ),
        ),
      ],
    ),
  );

  if (shouldDelete == true) {
    try {
      final response = await http.delete(
        Uri.parse('https://bakerymanagement-efgmhebnd5aggagn.eastus-01.azurewebsites.net/vendors/$id'),
      );

      if (response.statusCode == 200) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFFEEC07B), // Light brown background
            title: const Text(
              'Success',
              style: TextStyle(color: Color(0xFF6D3200)), // Dark brown text
            ),
            content: const Text('Vendor has been deleted successfully.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the success dialog
                },
                child: const Text('OK'),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Color(0xFF6D3200)), // Dark brown background
                  foregroundColor: MaterialStateProperty.all(Color(0xFFEEC07B)), // Light brown text
                ),
              ),
            ],
          ),
        );
        return true; // Indicate success
      } else {
        throw Exception('Failed to remove vendor');
      }
    } catch (e) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFFEEC07B), // Light brown background
          title: const Text(
            'Error',
            style: TextStyle(color: Color(0xFF6D3200)), // Dark brown text
          ),
          content: Text('Failed to remove vendor: $e'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return false; // Indicate failure
    }
  }

  return false; // Indicate cancellation
}
