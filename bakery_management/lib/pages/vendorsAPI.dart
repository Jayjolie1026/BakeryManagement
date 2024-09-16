import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'vendorsItemClass.dart';

class VendorsApi {
  static const String baseUrl = 'https://bakerymanagement-efgmhebnd5aggagn.eastus-01.azurewebsites.net'; // Replace with your actual base URL

  // Fetch all vendors
  Future<List<Vendor>> fetchVendors() async {
    final response = await http.get(Uri.parse('$baseUrl/vendors'));

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => Vendor.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load vendors');
    }
  }

  // Fetch vendor details by ID
  Future<Vendor> fetchVendorDetails(int vendorId) async {
    final response = await http.get(Uri.parse('$baseUrl/vendors/$vendorId'));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return Vendor.fromJson(jsonResponse);
    } else {
      throw Exception('Failed to load vendor details');
    }
  }
}

// Add a new vendor
Future<void> addVendor(
  int vendorID,
  String vendorName,
  String vendorAreaCode,
  String vendorPhoneNum,
  String vendorEmail,
  String streetAddress,
  String city,
  String state,
  String postalCode,
  String country,
) async {
  final url = Uri.parse('https://bakerymanagement-efgmhebnd5aggagn.eastus-01.azurewebsites.net/vendors');

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      'VendorID': vendorID,
      'VendorName': vendorName,
      'EmailAddress': vendorEmail,
      'AreaCode': vendorAreaCode,
      'PhoneNumber': vendorPhoneNum,
      'StreetAddress': streetAddress,
      'City': city,
      'State': state,
      'PostalCode': postalCode,
      'Country': country,
    }),
  );

  if (response.statusCode == 201) {
    print('Vendor added successfully');
  } else {
    throw Exception('Failed to add vendor: ${response.body}');
  }
}
