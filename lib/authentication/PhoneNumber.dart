import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pool_mate/authentication/OTPVerification.dart'; // Assuming this is where you have the PhoneVerificationScreen
import 'package:http/http.dart' as http; // For sending HTTP requests
import 'dart:convert'; // To decode JSON responses
import '../Constants.dart'; // Import the constants file
import 'package:pool_mate/ride/selection.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class SignUpScreen extends StatelessWidget {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController(); // Added email controller
  final _secureStorage = const FlutterSecureStorage();
    Future<void> sendOtp(String phoneNumber, String email, BuildContext context) async {
      final url = '${APIConstants.baseUrl}/email'; // Use the endpoint for sending OTP
      
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': phoneNumber,
          'email': email,
        }),
      );
      print('Response status code: ${response.statusCode}');
    print('Response body: ${response.body}');
    if (response.statusCode == 200) {
      // If OTP is sent successfully, navigate to the OTP verification screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PhoneVerificationScreen(
            phoneNumber: phoneNumber,
            email: email,  // Optionally pass email if needed
          ),
        ),
      );
    } else {
      // If the response is not successful, show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send OTP. Please try again.'),
          backgroundColor: Colors.grey.shade100,
        ),
      );
    }
  }
    
    Future<void> checkVerification(BuildContext context) async {
    final token = await _secureStorage.read(key: 'jwt_token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You are not authenticated.'),
          backgroundColor: Colors.red.shade400,
        ),
      );
      return;
    }

    final url = '${APIConstants.baseUrl}/is-verified';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['message'] == 'User is already verified') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RidePage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User is not verified. Please complete verification.'),
            backgroundColor: Colors.orange.shade400,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to check verification. Please try again.'),
          backgroundColor: Colors.red.shade400,
        ),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Illustration
            SizedBox(
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

            // OTP Info Text
            Text(
              "Enter your email and phone number to get the OTP for verification",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 20),

            // Email Input
            TextField(
              controller: _emailController, // Email controller
              keyboardType: TextInputType.emailAddress,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
              decoration: InputDecoration(
                prefixIconConstraints:
                    BoxConstraints(minWidth: 0, minHeight: 0),
                labelText: 'Email Address',
                labelStyle: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
                hintText: 'Enter your email address',
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
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              ),
            ),

            const SizedBox(height: 20),

            // Mobile Number Input
            TextField(
              controller: _phoneController, // Phone controller
              keyboardType: TextInputType.phone,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
              decoration: InputDecoration(
                prefixIconConstraints:
                    BoxConstraints(minWidth: 0, minHeight: 0),
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
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              ),
            ),

            const SizedBox(height: 20),

            // Next Button
            ElevatedButton(
              onPressed: () {
                // Validate phone number and email
                if (_phoneController.text.length != 10 || !_emailController.text.contains('@')) {
                  // Show error message if phone or email is invalid
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please enter a valid phone number and email.'),
                      backgroundColor: Colors.grey.shade100,
                    ),
                  );
                } else {
                  // Call the method to send OTP
                  sendOtp(_phoneController.text, _emailController.text, context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 10), // Adjust the horizontal padding
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'SEND OTP',
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

void main() => runApp(MaterialApp(home: SignUpScreen()));
