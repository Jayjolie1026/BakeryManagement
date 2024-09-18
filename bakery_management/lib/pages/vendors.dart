import 'dart:convert';

import 'package:bakery_management/pages/vendorsAPI.dart';
import 'package:flutter/material.dart';
import 'vendorsFunctions.dart';
import 'vendorsItemClass.dart';
import 'dart:async';
import 'inventorySearchWidget.dart';

// Vendors Page
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
      onTap: () => showVendorDetails(context, vendor),
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
  final int vendorID;

  const VendorDetailsPage({super.key, required this.vendorID});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Vendor>(
        future: fetchVendorDetails(vendorID),
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
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Display phone number if available
                    Text(
                      vendor.phoneNumbers.isNotEmpty
                        ? 'Phone: \n(${vendor.phoneNumbers.first.areaCode}) ${vendor.phoneNumbers.first.phoneNumber}'
                        : 'Phone: No phone number available',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.black, fontSize: 16),
                    ),
                    const SizedBox(height: 10),

                    // Display email if available
                    Text(
                      vendor.emails.isNotEmpty
                        ? 'Email: \n${vendor.emails.first.emailAddress}'
                        : 'Email: No email provided',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.black, fontSize: 16),
                    ),
                    const SizedBox(height: 10),

                    // Display address if available
                    Text(
                      vendor.addresses.isNotEmpty
                        ? 'Address: \n${vendor.addresses.first.streetAddress} \n${vendor.addresses.first.city}, ${vendor.addresses.first.state} \n${vendor.addresses.first.postalCode} ${vendor.addresses.first.country}'
                        : 'Address: No address provided',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.black, fontSize: 16),
                    ),
                    const SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: () {
                        editVendor(context, vendor);
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black, // Text color
                        backgroundColor: const Color(0xFFEEC07B), // Background color
                      ),
                      child: const Text('Edit Vendor Info'),
                    ),
                    const SizedBox(height: 10),

                    ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Confirm Deletion'),
                              content: const Text('Are you sure you want to delete this vendor?'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(); // Close the dialog
                                  },
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    Navigator.of(context).pop(); // Close the confirmation dialog
                                    await removeVendor(context, vendor);
                                  },
                                  child: const Text('Delete'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black, // Text color
                        backgroundColor: Colors.red, // Background color
                      ),
                      child: const Text('Remove Vendor'),
                    ),
                    const SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the details page
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black, // Text color
                        backgroundColor: const Color(0xFFEEC07B), // Background color
                      ),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return const Center(child: Text('No vendor details found.'));
          }
        },
      ),
    );
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

