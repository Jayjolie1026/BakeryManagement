import 'package:bakery_management/pages/vendorsAPI.dart';
import 'package:flutter/material.dart';
import 'vendorsFunctions.dart';
import 'vendorsItemClass.dart';
import 'dart:async';
import 'inventorySearchWidget.dart';

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
      setState(() {
        vendors = updatedVendors; // Update the vendor list with fresh data
      });
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
        ),
      ),
      icon: const Icon(
    Icons.add,
    color: Color(0xFFEEC07B), // Light brown icon color
      ),
      backgroundColor: const Color(0xFF6D3200),),
    floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
  );

  Widget buildSearch() => SearchWidget(
    text: query,
    hintText: 'Search by Vendor',
    onChanged: searchVendor,
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

  Widget buildItem(Vendor vendor) => Card(
  color: const Color(0xFF6D3200),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(50),
  ),
  margin: const EdgeInsets.fromLTRB(30, 0, 30, 10),
  elevation: 4,
  child: GestureDetector(
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
            onPressed: () async {
              final shouldDelete = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Confirm Delete'),
                  content: const Text('Are you sure you want to delete this vendor?'),
                  actions: [
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
                await handleRemoveVendor(context, vendor.vendorID);
                Navigator.of(context).pop(true); // Return true to indicate deletion
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<Vendor>(
        future: fetchVendorDetails(vendor.vendorID),
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
                      onPressed: () async {
                        final updatedVendor = await handleEditVendor(context, vendor);
                        if (updatedVendor) {
                          Navigator.of(context).pop(true); // Return true to indicate update
                        }
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(const Color(0xFF6D3200)), // Dark brown background
                        foregroundColor: MaterialStateProperty.all(const Color(0xFFEEC07B)), // Light brown text
                      ),
                      child: const Text('Edit Vendor Info'),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () async {
                        final updated = await handleRemoveVendor(context, vendor.vendorID);
                        if (updated) {
                          Navigator.of(context).pop(true);
                        }
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(const Color(0xFF6D3200)), // Dark brown background
                        foregroundColor: MaterialStateProperty.all(const Color(0xFFEEC07B)), // Light brown text
                      ),
                      child: const Text('Remove Vendor'),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Close the page
                          },
                          child: const Text('Close'),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(const Color(0xFF6D3200)), // Dark brown background
                            foregroundColor: MaterialStateProperty.all(const Color(0xFFEEC07B)), // Light brown text
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return const Center(child: Text('No vendor details available'));
        },
      ),
    );
  }
}