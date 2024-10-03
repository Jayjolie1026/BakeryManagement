import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class SessionService {
  final BuildContext context;
  
  SessionService(this.context);

  Future<void> checkSession(int sessionId) async {
    final response = await http.get(
      Uri.parse('https://bakerymanagement-efgmhebnd5aggagn.eastus-01.azurewebsites.net/$sessionId/check'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      // Session is active
      print('Session is active');
    } else if (response.statusCode == 401) {
      // Session has expired, redirect to the sign-in page
      Navigator.pushReplacementNamed(context, '/signin');
    } else {
      // Handle other error cases
      print('Error: ${response.body}');
    }
  }

  Future<void> updateSession(int sessionId) async {
    final response = await http.put(
      Uri.parse('https://bakerymanagement-efgmhebnd5aggagn.eastus-01.azurewebsites.net/$sessionId/update'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      // Session updated successfully
      print('Session updated');
    } else {
      // Handle error cases
      print('Error: ${response.body}');
    }
  }
}
