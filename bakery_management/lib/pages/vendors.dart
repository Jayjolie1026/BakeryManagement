import 'dart:convert';

import 'package:bakery_management/pages/vendorsAPI.dart';
import 'package:flutter/material.dart';
import 'vendorsFunctions.dart';
import 'vendorsItemClass.dart';
import 'dart:async';
import 'inventorySearchWidget.dart';
import 'package:http/http.dart' as http;

class VendorsPage extends StatefulWidget {
  const VendorsPage({super.key});

  @override
  _VendorsPageState createState() => _VendorsPageState();
}

class _VendorsPageState extends State<VendorsPage> {
  List<Vendor> vendors = [];
  String query = '';
  Timer? debouncer;

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void dispose() {
    debouncer?.cancel();
    super.dispose();
  }

  // Debounce for search bar
  void debounce(VoidCallback callback, {Duration duration = const Duration(milliseconds: 1000)}) {
    if (debouncer != null) {
      debouncer!.cancel();
    }
    debouncer = Timer(duration, callback);
  }

  // Initialize vendor items
  Future<void> init() async {
    final vendors = await VendorsApi().fetchVendors();
    setState(() => this.vendors = vendors);
  }

  // Handle refresh from vendor details page
  Future<void> _refreshVendors() async {
    await init();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      toolbarHeight: 125,
      title: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
        children: [
          Image.asset(
            'assets/vendor.png',
            height: 100,
          ),
          const SizedBox(height: 10), // Add space below the image
        ],
      ),
      centerTitle: true,
      backgroundColor: const Color(0xFFF0D1A0),
    ),
    backgroundColor: const Color(0xFFF0D1A0),
    body: Column(
      children: <Widget>[
        buildSearch(),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 80.0), // Adds padding to avoid overlap with the button
            itemCount: vendors.length,
            itemBuilder: (context, index) {
              final vendor = vendors[index];
              return buildItem(vendor);
            },
          ),
        ),
      ],
    ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () {
        showAddVendorDialog(context, () async {
          await init(); // Refresh the vendor list
        });
      },
      label: const Text('Add Vendors'),
      icon: const Icon(Icons.add),
      backgroundColor: const Color.fromARGB(255, 243, 217, 162),
    ),
    floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat, // Center at the bottom
  );

  // Search bar widget
  Widget buildSearch() => SearchWidget(
    text: query,
    hintText: 'Search by Vendor',
    onChanged: searchVendor,
  );

  // Search for a vendor by query
  Future<void> searchVendor(String query) async => debounce(() async {
    final vendors = await VendorsApi().fetchVendors();

    if (!mounted) return;

    setState(() {
      this.query = query;
      this.vendors = vendors.where((vendor) => vendor.vendorName.toLowerCase().contains(query.toLowerCase())).toList();
    });
  });

  // List of vendors
  Widget buildItem(Vendor vendor) => Card(
    color: const Color(0xFFEEC07B),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(50),
    ),
    margin: const EdgeInsets.fromLTRB(30, 0, 30, 10),
    elevation: 4,
    child: GestureDetector(
      onTap: () async {
        // Navigate to the vendor details page and await result
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VendorDetailsPage(vendor: vendor),
          ),
        );
        // If the result is true (indicating deletion), refresh the vendor list
        if (result == true) {
          _refreshVendors();
        }
      },
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
        child: Center(
          child: Text(
            vendor.vendorName.isNotEmpty ? vendor.vendorName : 'Unnamed Vendor', // Ensure something is displayed
            style: const TextStyle(
              color: Color(0xFF6D3200),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    ),
  );
}

class VendorDetailsPage extends StatelessWidget {
  final Vendor vendor;

  const VendorDetailsPage({super.key, required this.vendor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0D1A0),
      appBar: AppBar(
        title: const Text('Vendor Details'),
        backgroundColor: const Color(0xFFF0D1A0),
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => handleRemoveVendor(context, vendor.vendorID!),
          ),
        ],
      ),
      body: FutureBuilder<Vendor>(
        future: fetchVendorDetails(vendor.vendorID!), // Fetch vendor details using vendor ID
        builder: (BuildContext context, AsyncSnapshot<Vendor> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final vendor = snapshot.data!;
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Vendor: ${vendor.vendorName}',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      vendor.phoneNumbers.isNotEmpty
                        ? 'Phone: \n(${vendor.phoneNumbers.first.areaCode}) ${vendor.phoneNumbers.first.phoneNumber}'
                        : 'Phone: No phone number available',
                      style: const TextStyle(color: Colors.black, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      vendor.emails.isNotEmpty
                        ? 'Email: \n${vendor.emails.first.emailAddress}'
                        : 'Email: No email provided',
                      style: const TextStyle(color: Colors.black, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      vendor.addresses.isNotEmpty
                        ? 'Address: \n${vendor.addresses.first.streetAddress} \n${vendor.addresses.first.city}, ${vendor.addresses.first.state} \n${vendor.addresses.first.postalCode} ${vendor.addresses.first.country}'
                        : 'Address: No address provided',
                      style: const TextStyle(color: Colors.black, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        // Add your edit functionality here
                      },
                      child: const Text('Edit Vendor Info'),
                      style: ButtonStyle(
                        foregroundColor: MaterialStateProperty.all(Colors.blue),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => handleRemoveVendor(context, vendor.vendorID!),
                      child: const Text('Remove Vendor'),
                      style: ButtonStyle(
                        foregroundColor: MaterialStateProperty.all(Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return const Center(child: Text('No vendor data available.'));
          }
        },
      ),
    );
  }
  Future<void> handleRemoveVendor(BuildContext context, int id) async {
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
          Uri.parse('https://bakerymanagement-efgmhebnd5aggagn.eastus-01.azurewebsites.net/vendors/$id'),
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
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const VendorsPage(), // Redirect to VendorsPage
                      ),
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
}

// New page to edit a vendor
class EditVendorPage extends StatelessWidget {
  const EditVendorPage({super.key, required int vendor});

  @override
  Widget build(BuildContext context) {
    // Implement this page to handle vendor editing
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


