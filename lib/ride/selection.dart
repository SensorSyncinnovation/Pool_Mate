import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pool_mate/authentication/OTPVerification.dart';
import 'package:flutter/material.dart';
import 'package:pool_mate/authentication/PhoneNumber.dart';
import 'package:pool_mate/ride/Find.dart';
import 'package:http/http.dart' as http;
import 'package:pool_mate/ride/myPools.dart';
import 'package:uuid/uuid.dart';
import 'package:pool_mate/authentication/Terms.dart';
import '../Constants.dart';
import 'dart:io';

class RidePage extends StatefulWidget {
  final String email;
  final String phoneNumber;
  final bool isdriver;
  final bool documents;
  RidePage(
      {required this.email, required this.phoneNumber, required this.isdriver , required this.documents});

  @override
  _RidePageState createState() => _RidePageState();
}

class _RidePageState extends State<RidePage> {
  String? _selectedSource;
  String? _selectedDestination;
  final TextEditingController _seatsController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  bool _isLoading = false;

  final List<String> _sourcelocation = ['Tada', 'IIITS', 'Sullurupeta'];
  final List<String> _destinationlocation = ['Tada', 'IIITS', 'Sullurupeta'];

  @override
  void initState() {
    super.initState();
    _selectedSource = null;
    _selectedDestination = null;
    // Set initial state based on user type
    isFindRide = !widget.isdriver; // Non-drivers start with Find Ride
    isOfferRide = false;
  }

  @override
  void dispose() {
    _seatsController.dispose();
    _startTimeController.dispose();
    _costController.dispose();
    super.dispose();
  }

  bool isFindRide = false;
  bool isOfferRide = false;

  // Helper function to make HTTP/HTTPS requests
  Future<Map<String, dynamic>> makeRequest(String endpoint, dynamic body) async {
    try {
      if (APIConstants.baseUrl.startsWith('https')) {
        // For HTTPS
        final client = HttpClient()
          ..badCertificateCallback = ((X509Certificate cert, String host, int port) => true);
        final request = await client.postUrl(Uri.parse('${APIConstants.baseUrl}$endpoint'));
        request.headers.set('content-type', 'application/json');
        request.write(json.encode(body));
        final response = await request.close();
        final responseBody = await response.transform(utf8.decoder).join();
        return {
          'statusCode': response.statusCode,
          'body': responseBody,
        };
      } else {
        // For HTTP
        final response = await http.post(
          Uri.parse('${APIConstants.baseUrl}$endpoint'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(body),
        );
        return {
          'statusCode': response.statusCode,
          'body': response.body,
        };
      }
    } catch (e) {
      return {
        'statusCode': 500,
        'body': json.encode({'message': 'Network error: ${e.toString()}'})
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ride Page"),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () => _logOut(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Dummy Map Container
          Container(
            color: Colors.grey[300],
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                // ignore: deprecated_member_use
                Colors.black.withOpacity(0.5), // Apply black tint with opacity
                BlendMode.darken, // Darken the image
              ),
              child: Image.asset(
                'assets/map.png', // Replace with your image path
                width: double.infinity, // Set the width to fill the screen
                height: double.infinity, // Set the height to fill the screen
                fit: BoxFit
                    .cover, // Ensures the image scales correctly to cover the screen
              ),
            ),
          ),

          // Menu and Search Buttons (Top-Left and Top-Right)
          Positioned(
            top: 40,
            left: 10,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: Icon(Icons.menu, color: Colors.black),
                onPressed: () => {},
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 10,
            child: widget.isdriver
                ? CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: Icon(Icons.search, color: Colors.black),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MyPools(
                                    email: widget.email,
                                  )),
                        );
                      },
                    ),
                  )
                : SizedBox(), // Empty widget if not a driver
          ),

          // Ride Information Section (Bottom)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10.0,
                    spreadRadius: 5.0,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Find Ride and Offer Ride Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isFindRide = true;
                            isOfferRide = false;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isFindRide ? Colors.black : Colors.grey[300],
                          foregroundColor:
                              isFindRide ? Colors.white : Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                        child: Text('Find Ride'),
                      ),
                      if (widget.documents) // Show Offer Ride if driver or if user has documents
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              isOfferRide = true;
                              isFindRide = false;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isOfferRide ? Colors.black : Colors.grey[300],
                            foregroundColor:
                                isOfferRide ? Colors.white : Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                          child: Text('Offer Ride'),
                        ),
                      if ( !widget.documents) // Show Upload Documents if user doesn't have documents
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => TermsAndConditionsPage(
                                  email: widget.email,
                                  phoneNumber: widget.phoneNumber,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isOfferRide ? Colors.black : Colors.grey[300],
                            foregroundColor:
                                isOfferRide ? Colors.white : Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                          child: Text('Offer Ride'),
                        ),
                    ],
                  ),
                  SizedBox(height: 16.0),

                  // THIS IS TO FIND THE RIDE

                  // Fields for Find Ride
                  if (isFindRide) ...[
                    _buildDropdownField(
                      hint: 'Select Source',
                      value: _selectedSource,
                      items: _sourcelocation,
                      onChanged: (value) {
                        setState(() {
                          _selectedSource = value;
                        });
                      },
                      icon: Icons.location_on,
                    ),
                    SizedBox(height: 10.0),
                    _buildDropdownField(
                      hint: 'Select Destination',
                      value: _selectedDestination,
                      items: _destinationlocation,
                      onChanged: (value) {
                        setState(() {
                          _selectedDestination = value;
                        });
                      },
                      icon: Icons.location_on_outlined,
                    ),
                    // Add the Join button here
                    SizedBox(height: 20.0),
                    ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () async {
                              if (_selectedSource == null ||
                                  _selectedDestination == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Please select both source and destination')),
                                );
                                return;
                              }

                              if (_selectedSource == _selectedDestination) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Source and destination cannot be the same')),
                                );
                                return;
                              }

                              setState(() => _isLoading = true);
                              try {
                                final requestBody = {
                                  'pickupLocation': _selectedSource,
                                  'dropoffLocation': _selectedDestination,
                                };

                                final response = await makeRequest('/findride', requestBody);

                                if (response['statusCode'] == 200) {
                                  final rides = json.decode(response['body']);
                                  if (rides is List && rides.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'No rides available for this route')),
                                    );
                                    return;
                                  }
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ListOfAvailablePools(
                                        availableRides: rides,
                                        userEmail: widget.email,
                                        userPhone: widget.phoneNumber,
                                      ),
                                    ),
                                  );
                                } else {
                                  var errorMessage = 'Failed to find rides';
                                  try {
                                    final errorBody =
                                        json.decode(response['body']);
                                    errorMessage =
                                        errorBody['message'] ?? errorMessage;
                                  } catch (_) {}
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(errorMessage)),
                                  );
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Network error: Please check your connection')),
                                );
                              } finally {
                                setState(() => _isLoading = false);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        minimumSize: Size(200, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text('SEARCH'),
                    ),
                  ],

                  // Fields for Offer Ride
                  if (isOfferRide && widget.documents) ...[
                    _buildDropdownField(
                      hint: 'Select Source',
                      value: _selectedSource,
                      items: _sourcelocation,
                      onChanged: (value) {
                        setState(() {
                          _selectedSource = value;
                        });
                      },
                      icon: Icons.location_on,
                    ),
                    SizedBox(height: 10.0),
                    _buildDropdownField(
                      hint: 'Select Destination',
                      value: _selectedDestination,
                      items: _destinationlocation,
                      onChanged: (value) {
                        setState(() {
                          _selectedDestination = value;
                        });
                      },
                      icon: Icons.location_on_outlined,
                    ),
                    SizedBox(height: 10.0),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 5.0,
                            spreadRadius: 2.0,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: TextFormField(
                          controller: _seatsController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            prefixIcon:
                                Icon(Icons.event_seat, color: Colors.black),
                            hintText: 'Enter Number of Seats',
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.0),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 5.0,
                            spreadRadius: 2.0,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: TextFormField(
                          controller: _startTimeController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            prefixIcon:
                                Icon(Icons.access_time, color: Colors.black),
                            hintText: 'Enter Start Time (e.g., 10:00 AM)',
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.0),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 5.0,
                            spreadRadius: 2.0,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: TextFormField(
                          controller: _costController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            prefixIcon:
                                Icon(Icons.currency_rupee, color: Colors.black),
                            hintText: 'Enter Cost Per Person',
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.0),
                    // Add the Join button here
                    ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () async {
                              // Validate all required fields
                              if (_selectedSource == null ||
                                  _selectedDestination == null ||
                                  _seatsController.text.isEmpty ||
                                  _startTimeController.text.isEmpty ||
                                  _costController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text('Please fill in all fields')),
                                );
                                return;
                              }

                              if (_selectedSource == _selectedDestination) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Source and destination cannot be the same')),
                                );
                                return;
                              }

                              // Validate seats
                              final seats = int.tryParse(_seatsController.text);
                              if (seats == null || seats <= 0 || seats > 20) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Please enter a valid number of seats (1-20)')),
                                );
                                return;
                              }

                              // Validate time format
                              final timePattern = RegExp(
                                  r'^\d{1,2}:\d{2}\s*(AM|PM)$',
                                  caseSensitive: false);
                              if (!timePattern
                                  .hasMatch(_startTimeController.text)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Please enter time in format: HH:MM AM/PM')),
                                );
                                return;
                              }

                              // Validate cost
                              final cost = int.tryParse(_costController.text);
                              if (cost == null || cost <= 0) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text('Please enter a valid cost')),
                                );
                                return;
                              }

                              setState(() => _isLoading = true);
                              try {
                                final requestBody = {
                                  'pickupLocation': _selectedSource,
                                  'dropoffLocation': _selectedDestination,
                                  'startTime': _startTimeController.text,
                                  'cost': cost,
                                  'seats_available':
                                      int.parse(_seatsController.text),
                                  'driver_phone': widget.phoneNumber,
                                  'driver_email': widget.email,
                                };

                                final response = await makeRequest('/rides', requestBody);

                                if (response['statusCode'] == 201) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content:
                                          Text('Car pool created successfully'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                  // Clear all fields after successful creation
                                  setState(() {
                                    _selectedSource = null;
                                    _selectedDestination = null;
                                    _seatsController.clear();
                                    _startTimeController.clear();
                                    _costController.clear();
                                  });
                                  // Navigate to MyPools page
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          MyPools(email: widget.email),
                                    ),
                                  );
                                } else {
                                  var errorMessage =
                                      'Failed to create car pool';
                                  try {
                                    final errorBody =
                                        json.decode(response['body']);
                                    errorMessage =
                                        errorBody['message'] ?? errorMessage;
                                  } catch (_) {}
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(errorMessage),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Network error: Please check your connection'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              } finally {
                                setState(() => _isLoading = false);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        minimumSize: Size(200, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text('Offer Ride'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required IconData icon,
  }) {
    // Filter out the selected value from the other dropdown to prevent same selection
    List<String> availableItems = items.where((item) {
      if (hint.contains('Source')) {
        return item != _selectedDestination;
      } else {
        return item != _selectedSource;
      }
    }).toList();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: DropdownButton<String>(
        value: value,
        hint: Text(hint),
        isExpanded: true,
        underline: Container(), // Remove the default underline
        items: availableItems.map<DropdownMenuItem<String>>((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: (newValue) {
          if (newValue != null) {
            // Clear the other dropdown if it has the same value
            if (hint.contains('Source') && newValue == _selectedDestination) {
              setState(() => _selectedDestination = null);
            } else if (hint.contains('Destination') && newValue == _selectedSource) {
              setState(() => _selectedSource = null);
            }
            onChanged(newValue);
          }
        },
      ),
    );
  }

  void _logOut(BuildContext context) async {
    // Delete the token from secure storage
    await secureStorage.delete(key: 'jwt_token');

    // Navigate to SignUpPage with email and phone number
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => SignUpScreen(),
      ),
    );
  }
}
