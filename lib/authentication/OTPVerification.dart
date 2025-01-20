import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../Constants.dart'; // Import the constants file

import 'Terms.dart';

class PhoneVerificationScreen extends StatelessWidget {
  final String phoneNumber;
  final String email;
  final _secureStorage = const FlutterSecureStorage();
  PhoneVerificationScreen({required this.phoneNumber, required this.email});

  Future<void> verifyOTP(BuildContext context, String otp) async {
    try {
      // Example API endpoint
      final url = Uri.parse('${APIConstants.baseUrl}/verify');

      // API request body
      final response = await http.post(
        url,
        body: jsonEncode({'email': email, 'otp': otp}),
        headers: {'Content-Type': 'application/json'},
      );
      print(response);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['message'] == 'OTP verified successfully') {
          // Store the token in secure storage
          final token = data['token'];
          await _secureStorage.write(key: 'jwt_token', value: token);

          // Navigate to the next screen on success
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TermsAndConditionsPage(
                 email: email, 
              ),
            ),
          );
        } else {
          print(response.body);
          // Show error message
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Verification Failed'),
              content: Text(data['message'] ?? 'Invalid OTP.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('OK'),
                ),
              ],
            ),
          );
        }
      } else {
           print(response);
        throw Exception(
          
            'Failed to verify OTP. Status code: ${response.statusCode}');
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController otpController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
      ),
      backgroundColor: Colors.grey.shade100,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 200,
                child: Center(
                  child: Image.asset('assets/verification.png'),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "OTP Verification",
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Enter the OTP sent to your number",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: otpController,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: InputDecoration(
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  final otp = otpController.text.trim();
                  if (otp.isNotEmpty) {
                    verifyOTP(context, otp);
                  } else {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Error'),
                        content: Text('Please enter the OTP.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('OK'),
                          ),
                        ],
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Center(
                  child: Text(
                    "Verify",
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  // Resend code logic
                },
                child: Text.rich(
                  TextSpan(
                    text: "Didn't get code? ",
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                    children: [
                      TextSpan(
                        text: "Resend it",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: const Color.fromARGB(255, 0, 0, 0),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
