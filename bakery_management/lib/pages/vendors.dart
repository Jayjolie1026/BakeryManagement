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

// New page to edit a vendor
class EditVendorPage extends StatelessWidget {
  const EditVendorPage({super.key});

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

