import 'package:bakery_management/pages/vendorsAPI.dart';
import 'package:flutter/material.dart';
import 'vendorsFunctions.dart';
import 'vendorsItemClass.dart';
import 'dart:async';
import 'inventorySearchWidget.dart';
import 'package:url_launcher/url_launcher.dart'; 
import 'sessions.dart';
import 'package:bakery_management/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      // error
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    
    backgroundColor: const Color(0xFFF0D1A0),
    body: Column(
      children: <Widget>[
        const SizedBox(height: 25.0),
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
        SharedPreferences prefs = await SharedPreferences.getInstance();
        int? sessionId = prefs.getInt('sessionId'); // Get the sessionId as an int

        if (sessionId != null) {
          // Create an instance of SessionService
          SessionService sessionService = SessionService(context);

          // Check the session status
          await sessionService.checkSession(sessionId); // Check if the session is active

          // If the session is active, update it
          await sessionService.updateSession(sessionId); // Update the session to keep it alive

        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SignInPage()),
          );
        }
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
      backgroundColor: const Color(0xFF422308),
    ),
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
      // error
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
        SharedPreferences prefs = await SharedPreferences.getInstance();
        int? sessionId = prefs.getInt('sessionId'); // Get the sessionId as an int

        if (sessionId != null) {
          // Create an instance of SessionService
          SessionService sessionService = SessionService(context);

          // Check the session status
          await sessionService.checkSession(sessionId); // Check if the session is active

          // If the session is active, update it
          await sessionService.updateSession(sessionId); // Update the session to keep it alive

        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SignInPage()),
          );
        }
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
                                vendor.vendorName,
                                style: const TextStyle(
                                  color: Color(0xFF6D3200), // Dark brown
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Vendor ID
                            const Text(
                              'ID:',
                              style: TextStyle(
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
                            const Text(
                              'Phone:',
                              style: TextStyle(
                                color: Color(0xFF6D3200),
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: InkWell(
                                onTap: vendor.phoneNumbers.isNotEmpty
                                    ? () {
                                        final phoneNumber = vendor.phoneNumbers.first;
                                        final fullPhoneNumber = phoneNumber.areaCode + phoneNumber.phoneNumber;
                                        launchUrl(Uri.parse('sms:$fullPhoneNumber'));
                                      }
                                    : null,
                                child: Text(
                                  vendor.phoneNumbers.isNotEmpty
                                      ? '(${vendor.phoneNumbers.first.areaCode}) ${vendor.phoneNumbers.first.phoneNumber.substring(0, 3)} - ${vendor.phoneNumbers.first.phoneNumber.substring(3, 7)}'
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
                            const Text(
                              'Email:',
                              style: TextStyle(
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
                            const Text(
                              'Address:',
                              style: TextStyle(
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
                                    SharedPreferences prefs = await SharedPreferences.getInstance();
                                    int? sessionId = prefs.getInt('sessionId'); // Get the sessionId as an int

                                    if (sessionId != null) {
                                      // Create an instance of SessionService
                                      SessionService sessionService = SessionService(context);

                                      // Check the session status
                                      await sessionService.checkSession(sessionId); // Check if the session is active

                                      // If the session is active, update it
                                      await sessionService.updateSession(sessionId); // Update the session to keep it alive

                                    } else {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(builder: (context) => const SignInPage()),
                                      );
                                    }
                                    final updatedVendor = await handleEditVendor(context, vendor);
                                    if (updatedVendor) {
                                      Navigator.of(context).pop(true);
                                    }
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: WidgetStateProperty.all(const Color(0xFF6D3200)),
                                    foregroundColor: WidgetStateProperty.all(const Color(0xFFEEC07B)),
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
                                    backgroundColor: WidgetStateProperty.all(const Color(0xFF6D3200)),
                                    foregroundColor: WidgetStateProperty.all(const Color(0xFFEEC07B)),
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
                        backgroundColor: WidgetStateProperty.all(const Color(0xFF6D3200)),
                        foregroundColor: WidgetStateProperty.all(const Color(0xFFEEC07B)),
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
