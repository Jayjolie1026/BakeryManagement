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
        'Add Vendor',
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
            fontSize: 20,
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
      body: FutureBuilder<Vendor>(
        future: fetchVendorDetails(vendor.vendorID),
        builder: (BuildContext context, AsyncSnapshot<Vendor> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Color(0xFF6D3200))));
          } else if (snapshot.hasData) {
            final vendor = snapshot.data!;
            return SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const SizedBox(height: 50),
                        Image.asset(
                          'assets/vendor.png', // Replace with your image asset
                          height: 100,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          '${vendor.vendorName}',
                          style: const TextStyle(
                            color: Color(0xFF6D3200), // Dark brown
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text.rich(
                          TextSpan(
                            children: <TextSpan>[
                              TextSpan(
                                text: 'ID: ',
                                style: TextStyle(
                                  color: Color(0xFF6D3200), // Dark brown
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold, // Bold heading
                                ),
                              ),
                              TextSpan(
                                text: '${vendor.vendorID}',
                                style: const TextStyle(
                                  color: Color(0xFF6D3200), // Dark brown
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text.rich(
                          TextSpan(
                            children: <TextSpan>[
                              TextSpan(
                                text: 'Phone:\n',
                                style: TextStyle(
                                  color: Color(0xFF6D3200), // Dark brown
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold, // Bold heading
                                ),
                              ),
                              TextSpan(
                                text: vendor.phoneNumbers.isNotEmpty
                                  ? '(${vendor.phoneNumbers.first.areaCode}) ${vendor.phoneNumbers.first.phoneNumber.substring(0, 3)} - ${vendor.phoneNumbers.first.phoneNumber.substring(4, 8)} '
                                  : 'No phone number available',
                                style: const TextStyle(
                                  color: Color(0xFF6D3200), // Dark brown
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text.rich(
                          TextSpan(
                            children: <TextSpan>[
                              TextSpan(
                                text: 'Email:\n',
                                style: TextStyle(
                                  color: Color(0xFF6D3200), // Dark brown
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold, // Bold heading
                                ),
                              ),
                              TextSpan(
                                text: vendor.emails.isNotEmpty
                                  ? vendor.emails.first.emailAddress
                                  : 'No email provided',
                                style: const TextStyle(
                                  color: Color(0xFF6D3200), // Dark brown
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text.rich(
                          TextSpan(
                            children: <TextSpan>[
                              TextSpan(
                                text: 'Address:\n',
                                style: TextStyle(
                                  color: Color(0xFF6D3200), // Dark brown
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold, // Bold heading
                                ),
                              ),
                              TextSpan(
                                text: vendor.addresses.isNotEmpty
                                  ? '${vendor.addresses.first.streetAddress}\n${vendor.addresses.first.city}, ${vendor.addresses.first.state}\n${vendor.addresses.first.postalCode} ${vendor.addresses.first.country}'
                                  : 'No address provided',
                                style: const TextStyle(
                                  color: Color(0xFF6D3200), // Dark brown
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 25),
                        
                        // Row for buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
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
                              child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.add, color: Color(0xFFEEC07B)), // Light brown icon color
                                SizedBox(width: 8), // Spacing between icon and text
                                Text(
                                  'Update',
                                  style: TextStyle(
                                    fontSize: 17, // Consistent font size
                                    color: Color(0xFFEEC07B), // Light brown text
                                                          ),
                                                        ),
                              ],
                            ),
                            ),
                            const SizedBox(width: 20), // Space between the buttons
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
                              child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.delete, color: Color(0xFFEEC07B)), // Light brown icon color
                                SizedBox(width: 8), // Spacing between icon and text
                                Text(
                                  'Delete',
                                  style: TextStyle(
                                    fontSize: 17, // Consistent font size
                                    color: Color(0xFFEEC07B), // Light brown text
                                                          ),
                                                        ),
                              ],
                            ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 50),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context, true); // Close the page
                        },
                          child: const Text(
                            'Close',
                            style: TextStyle(
                              fontSize: 17, // Font size
                            ),
                          ),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(const Color(0xFF6D3200)), // Dark brown background
                          foregroundColor: MaterialStateProperty.all(const Color(0xFFEEC07B)), // Light brown text
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text('No vendor details available', style: TextStyle(color: Color(0xFF6D3200))));
        },
      ),
    );
  }
}

// Search widget component
class SearchWidget extends StatefulWidget {
  final String text;
  final ValueChanged<String> onChanged;
  final String hintText;

  const SearchWidget({
    super.key,
    required this.text,
    required this.onChanged,
    required this.hintText,
  });

  @override
  _SearchWidgetState createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  final controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller.text = widget.text;
  }

  @override
  Widget build(BuildContext context) {
    const styleActive = TextStyle(color: Color(0xFF6D3200));
    const styleHint = TextStyle(color: Color(0xFF6D3200));
    final style = widget.text.isEmpty ? styleHint : styleActive;

    return Container(
      height: 50,
      margin: const EdgeInsets.fromLTRB(30, 0, 30, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: const Color(0xFFD8C4AA),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: TextField(
        controller: controller,
        cursorColor: const Color(0xFFEEC07B),
        decoration: InputDecoration(
          iconColor: const Color(0xFFEEC07B),
          icon: Icon(Icons.search, color: style.color),
          suffixIcon: widget.text.isNotEmpty
              ? GestureDetector(
                  child: Icon(Icons.close, color: style.color),
                  onTap: () {
                    controller.clear();
                    widget.onChanged('');
                    FocusScope.of(context).requestFocus(FocusNode());
                  },
                )
              : null,
          hintText: widget.hintText,
          hintStyle: style,
          border: InputBorder.none,
        ),
        style: style,
        onChanged: widget.onChanged,
      ),
    );
  }
}
