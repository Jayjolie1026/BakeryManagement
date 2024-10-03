import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:bakery_management/main.dart';

class SessionService {
  final BuildContext context;
  
  SessionService(this.context);

  Future<void> checkSession(int sessionId) async {
    final response = await http.get(
      Uri.parse('https://bakerymanagement-efgmhebnd5aggagn.eastus-01.azurewebsites.net/sessions/$sessionId/check'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      // Session is active
      print('Session is active');
    } else if (response.statusCode == 401) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Session expired. Please sign in again.'),
          duration: Duration(seconds: 3),
        ),
      );

      // Delay to allow the SnackBar to be displayed before navigating
      await Future.delayed(Duration(seconds: 3));
      Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SignInPage()),
    );
    } else {
      // Handle other error cases
      print('Error: ${response.body}');
    }
  }

  Future<void> updateSession(int sessionId) async {
    final response = await http.put(
      Uri.parse('https://bakerymanagement-efgmhebnd5aggagn.eastus-01.azurewebsites.net/sessions/$sessionId/update'),
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
