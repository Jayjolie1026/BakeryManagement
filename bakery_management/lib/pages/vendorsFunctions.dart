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

void showVendorDetails(BuildContext context, Vendor vendor) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return FutureBuilder<Vendor>(
        future: fetchVendorDetails(vendor.vendorID),
        builder: (BuildContext context, AsyncSnapshot<Vendor> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text('Failed to load vendor details: ${snapshot.error}'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Text('Close'),
                ),
              ],
            );
          } else if (snapshot.hasData) {
            final Vendor vendorDetails = snapshot.data!;
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              elevation: 4,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Text(
                        vendorDetails.vendorName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF6D3200),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Display phone number if available
                    if (vendorDetails.phoneNumbers.isNotEmpty)
                      Center(
                        child: Text(
                          'Phone: \n(${vendorDetails.phoneNumbers.first.areaCode}) ${vendorDetails.phoneNumbers.first.phoneNumber}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF6D3200),
                            fontSize: 16,
                          ),
                        ),
                      ),

                    const SizedBox(height: 10),

                    // Display email if available
                    if (vendorDetails.emails.isNotEmpty)
                      Center(
                        child: Text(
                          'Email: \n${vendorDetails.emails.first.emailAddress}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF6D3200),
                            fontSize: 16,
                          ),
                        ),
                      ),

                    const SizedBox(height: 10),

                    // Display address if available
                    if (vendorDetails.addresses.isNotEmpty)
                      Center(
                        child: Text(
                          'Address: \n${vendorDetails.addresses.first.streetAddress} \n${vendorDetails.addresses.first.city}, ${vendorDetails.addresses.first.state} \n${vendorDetails.addresses.first.postalCode} ${vendorDetails.addresses.first.country}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF6D3200),
                            fontSize: 16,
                          ),
                        ),
                      ),

                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: const Color(0xFF422308),
                      ),
                      child: const Text(
                        'Close',
                        style: TextStyle(color: Color(0xFFEEC07B)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return AlertDialog(
              title: const Text('No Data'),
              content: const Text('No vendor details found.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Text('Close'),
                ),
              ],
            );
          }
        },
      );
    },
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
