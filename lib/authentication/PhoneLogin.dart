import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pool_mate/authentication/OTPVerification.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pool_mate/authentication/UserProvider.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController _phoneController = TextEditingController();

  Future<void> fetchUserByPhone(String phoneNumber, UserProvider userProvider, BuildContext context) async {
    final url = 'http://your-server-address/users/phone/$phoneNumber'; // Update with your server address
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final user = jsonDecode(response.body);
      userProvider.setUser(user['userId'], user['phoneNumber']);
      Navigator.pushNamed(context, '/home'); // Navigate to the home screen
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User not found! Please sign up first.', style: TextStyle(color: Colors.red)),
          backgroundColor: Colors.grey.shade100,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Illustration
            Container(
              height: 200,
              child: Image.asset('assets/login.png'), // Replace with your asset
            ),
            const SizedBox(height: 20),

            // App Name
            Text(
              "LOGIN",
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),

            // Info Text
            Text(
              "Enter your phone number to login",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 20),

            // Mobile Number Input
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
              decoration: InputDecoration(
                prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                labelText: 'Mobile Number',
                labelStyle: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
                hintText: 'Enter your mobile number',
                hintStyle: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey.shade400,
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.blueAccent, width: 1.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              ),
            ),

            const SizedBox(height: 20),

            // Login Button
            ElevatedButton(
              onPressed: () async {
                final phoneNumber = _phoneController.text;

                // Validate phone number length
                if (phoneNumber.length != 10) {
                  // Show error message if the number is not 10 digits
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please enter a valid 10-digit phone number.', style: TextStyle(color: Colors.red)),
                      backgroundColor: Colors.grey.shade100,
                    ),
                  );
                } else {
                  // Check if the user exists by phone number
                  await fetchUserByPhone(phoneNumber, userProvider, context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'LOGIN',
                    style: GoogleFonts.inter(fontSize: 16, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() => runApp(MaterialApp(home: LoginScreen()));
