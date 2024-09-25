import 'package:bakery_management/pages/vendorsAPI.dart';
import 'package:flutter/material.dart';
import 'vendorsFunctions.dart';
import 'vendorsItemClass.dart';
import 'dart:async';
import 'inventorySearchWidget.dart';
import 'package:url_launcher/url_launcher.dart'; // For launching phone and email

class VendorsPage extends StatefulWidget {
  final int? vendorID;  // Add vendorID as an optional parameter

  const VendorsPage({super.key, this.vendorID});  // Add vendorID to the constructor

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
    _refreshVendors();
  }

  @override
  void dispose() {
    debouncer?.cancel();
    super.dispose();
  }

  void debounce(VoidCallback callback, {Duration duration = const Duration(milliseconds: 1000)}) {
    if (debouncer != null) {
      debouncer!.cancel();
    }
    debouncer = Timer(duration, callback);
  }

Future<void> _refreshVendors() async {
  setState(() {
    query = ''; // Clear the search query
    vendors = []; // Clear the existing vendor list
  });

  try {
    final updatedVendors = await VendorsApi().fetchVendors();

    // If vendorID is provided, filter the list to only include that vendor
    if (widget.vendorID != null) {
      setState(() {
        vendors = updatedVendors
            .where((vendor) => vendor.vendorID == widget.vendorID)
            .toList();
      });
    } else {
      setState(() {
        vendors = updatedVendors; // Show all vendors if no specific vendorID
      });
    }
  } catch (e) {
    print('Error fetching vendors: $e');
  }
}
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      toolbarHeight: 125,
      title: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/vendor.png',
            height: 100,
          ),
          const SizedBox(height: 10),
        ],
      ),
      centerTitle: true,
      backgroundColor: const Color(0xFFF0D1A0),
      iconTheme: const IconThemeData(
        color: Color(0xFF6D3200), // Set your desired back button color (dark brown)
  ),
    ),
    backgroundColor: const Color(0xFFF0D1A0),
    body: Column(
      children: <Widget>[
        buildSearch(),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 80.0),
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
      onPressed: () async {
        await showAddVendorDialog(context, _refreshVendors); // Refresh the vendor list after adding a new vendor
      },
      label: const Text(
        'Add Vendors',
        style: TextStyle(
          color: Color(0xFFEEC07B), // Light brown text color
          fontSize: 17,
        ),
      ),
      icon: const Icon(
    Icons.add,
    color: Color(0xFFEEC07B), // Light brown icon color
      ),
      backgroundColor: const Color(0xFF422308),),
    floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
  );

  Widget buildSearch() => SearchWidget(
    text: query,
    hintText: 'Search by Vendor',
    onChanged: searchVendor,
    backgroundColor: const Color(0XFFEEC07B)
  );

  Future<void> searchVendor(String query) async => debounce(() async {
    try {
      final vendors = await VendorsApi().fetchVendors();
      if (!mounted) return;

      setState(() {
        this.query = query;
        this.vendors = vendors.where((vendor) => vendor.vendorName.toLowerCase().contains(query.toLowerCase())).toList();
      });
    } catch (e) {
      print('Error searching vendors: $e');
    }
  });

  Widget buildItem(Vendor vendor) => GestureDetector(
    onTap: () async {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VendorDetailsPage(vendor: vendor),
        ),
      );
      if (result == true) {
        _refreshVendors(); // Refresh the list if there were changes
      }
    },
    child: Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
      child: Center(
        child: Text(
          vendor.vendorName.isNotEmpty ? vendor.vendorName : 'Unnamed Vendor',
          style: const TextStyle(
            color: Color(0xFFEEC07B),
            fontSize: 18,
            fontWeight: FontWeight.bold,
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
        backgroundColor: const Color(0xFFF0D1A0),
        elevation: 0,
        toolbarHeight: 100,
        title: Image.asset(
          'assets/vendor2.png',
          height: 100,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF6D3200)), // Back button
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: FutureBuilder<Vendor>(
        future: fetchVendorDetails(vendor.vendorID),
        builder: (BuildContext context, AsyncSnapshot<Vendor> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Color(0xFF6D3200))));
          } else if (snapshot.hasData) {
            final vendor = snapshot.data!;
            return Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // Align text to the left
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start, // Aligns all children to the left
                          children: <Widget>[
                            // Centered Vendor Name
                            Center(
                              child: Text(
                                '${vendor.vendorName}',
                                style: const TextStyle(
                                  color: Color(0xFF6D3200), // Dark brown
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Vendor ID
                            Text(
                              'ID:',
                              style: const TextStyle(
                                color: Color(0xFF6D3200), // Dark brown
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 16.0), // Indent the details
                              child: Text(
                                '${vendor.vendorID}',
                                style: const TextStyle(
                                  color: Color(0xFF6D3200),
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Phone Number
                            Text(
                              'Phone:',
                              style: const TextStyle(
                                color: Color(0xFF6D3200),
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: InkWell(
                                onTap: vendor.phoneNumbers.isNotEmpty
                                    ? () => launchUrl(Uri.parse('sms:${vendor.phoneNumbers.first.phoneNumber}'))
                                    : null,
                                child: Text(
                                  vendor.phoneNumbers.isNotEmpty
                                      ? '(${vendor.phoneNumbers.first.areaCode}) ${vendor.phoneNumbers.first.phoneNumber.substring(0, 3)} - ${vendor.phoneNumbers.first.phoneNumber.substring(4, 8)}'
                                      : 'No phone number available',
                                  style: const TextStyle(
                                    color: Color(0xFF6D3200),
                                    fontSize: 20,
                                    decoration: TextDecoration.underline, // To signify it's clickable
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Email
                            Text(
                              'Email:',
                              style: const TextStyle(
                                color: Color(0xFF6D3200),
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: InkWell(
                                onTap: vendor.emails.isNotEmpty
                                    ? () => launchUrl(Uri.parse('mailto:${vendor.emails.first.emailAddress}'))
                                    : null,
                                child: Text(
                                  vendor.emails.isNotEmpty
                                      ? vendor.emails.first.emailAddress
                                      : 'No email provided',
                                  style: const TextStyle(
                                    color: Color(0xFF6D3200),
                                    fontSize: 20,
                                    decoration: TextDecoration.underline, // To signify it's clickable
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Address
                            Text(
                              'Address:',
                              style: const TextStyle(
                                color: Color(0xFF6D3200),
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: Text(
                                vendor.addresses.isNotEmpty
                                    ? '${vendor.addresses.first.streetAddress}\n${vendor.addresses.first.city}, ${vendor.addresses.first.state}\n${vendor.addresses.first.postalCode} ${vendor.addresses.first.country}'
                                    : 'No address provided',
                                style: const TextStyle(
                                  color: Color(0xFF6D3200),
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            const SizedBox(height: 25),

                            // Buttons (Update/Delete)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                ElevatedButton(
                                  onPressed: () async {
                                    final updatedVendor = await handleEditVendor(context, vendor);
                                    if (updatedVendor) {
                                      Navigator.of(context).pop(true);
                                    }
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(const Color(0xFF6D3200)),
                                    foregroundColor: MaterialStateProperty.all(const Color(0xFFEEC07B)),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.add, color: Color(0xFFEEC07B)),
                                      SizedBox(width: 8),
                                      Text('Update', style: TextStyle(fontSize: 17)),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 20),
                                ElevatedButton(
                                  onPressed: () async {
                                    final updated = await handleRemoveVendor(context, vendor.vendorID);
                                    if (updated) {
                                      Navigator.of(context).pop(true);
                                    }
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(const Color(0xFF6D3200)),
                                    foregroundColor: MaterialStateProperty.all(const Color(0xFFEEC07B)),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.delete, color: Color(0xFFEEC07B)),
                                      SizedBox(width: 8),
                                      Text('Delete', style: TextStyle(fontSize: 17)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 80), // Added space for the close button
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Close Button at the Bottom
                Positioned(
                  bottom: 0, // Aligns the close button to the bottom of the screen
                  left: 0,
                  right: 0,
                  child: Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(const Color(0xFF6D3200)),
                        foregroundColor: MaterialStateProperty.all(const Color(0xFFEEC07B)),
                      ),
                      child: const Text('Close', style: TextStyle(fontSize: 17)),
                    ),
                  ),
                ),
              ],
            );
          }
          return const Center(child: Text('No vendor details available', style: TextStyle(color: Color(0xFF6D3200))));
        },
      ),
    );
  }
}
