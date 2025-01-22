import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pool_mate/authentication/OTPVerification.dart';
import 'package:flutter/material.dart';
import 'package:pool_mate/authentication/PhoneNumber.dart';
import 'package:pool_mate/ride/Find.dart';
import 'package:http/http.dart' as http;
import 'package:pool_mate/ride/myPools.dart';
import 'package:uuid/uuid.dart';
import '../Constants.dart';

class RidePage extends StatefulWidget {
  final String email;
  final String phoneNumber;
  final bool isdriver;
  RidePage(
      {required this.email, required this.phoneNumber, required this.isdriver});

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

  final List<String> _sourcelocation = ['Tada', 'IIITS', 'Sulluepeta'];
  final List<String> _destinationlocation = ['Tada', 'IIITS', 'Sulluepeta'];

  @override
  void initState() {
    super.initState();
    _selectedSource = null;
    _selectedDestination = null;
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
            child: CircleAvatar(
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
            ),
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
                              if (_selectedSource == null || _selectedDestination == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Please select both source and destination')),
                                );
                                return;
                              }

                              if (_selectedSource == _selectedDestination) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Source and destination cannot be the same')),
                                );
                                return;
                              }

                              setState(() => _isLoading = true);
                              try {
                                var body = json.encode({
                                  'pickupLocation': _selectedSource,
                                  'dropoffLocation': _selectedDestination,
                                });

                                final response = await http.post(
                                  Uri.parse('${APIConstants.baseUrl}/findride'),
                                  headers: {'Content-Type': 'application/json'},
                                  body: body,
                                );

                                if (response.statusCode == 200) {
                                  final rides = json.decode(response.body);
                                  if (rides is List && rides.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('No rides available for this route')),
                                    );
                                    return;
                                  }
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ListOfAvailablePools(
                                        availableRides: rides,
                                        userEmail: widget.email,
                                        userPhone: widget.phoneNumber,
                                      ),
                                    ),
                                  );
                                } else {
                                  var errorMessage = 'Failed to find rides';
                                  try {
                                    final errorBody = json.decode(response.body);
                                    errorMessage = errorBody['message'] ?? errorMessage;
                                  } catch (_) {}
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(errorMessage)),
                                  );
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Network error: Please check your connection')),
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
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text('SEARCH'),
                    ),
                  ],

                  // Fields for Offer Ride
                  if (isOfferRide) ...[
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
                            prefixIcon: Icon(Icons.event_seat, color: Colors.black),
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
                            prefixIcon: Icon(Icons.access_time, color: Colors.black),
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
                            prefixIcon: Icon(Icons.currency_rupee, color: Colors.black),
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
                                  SnackBar(content: Text('Please fill in all fields')),
                                );
                                return;
                              }

                              if (_selectedSource == _selectedDestination) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Source and destination cannot be the same')),
                                );
                                return;
                              }

                              // Validate seats
                              final seats = int.tryParse(_seatsController.text);
                              if (seats == null || seats <= 0 || seats > 20) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Please enter a valid number of seats (1-20)')),
                                );
                                return;
                              }

                              // Validate time format
                              final timePattern = RegExp(r'^\d{1,2}:\d{2}\s*(AM|PM)$', caseSensitive: false);
                              if (!timePattern.hasMatch(_startTimeController.text)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Please enter time in format: HH:MM AM/PM')),
                                );
                                return;
                              }

                              // Validate cost
                              final cost = int.tryParse(_costController.text);
                              if (cost == null || cost <= 0) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Please enter a valid cost')),
                                );
                                return;
                              }

                              setState(() => _isLoading = true);
                              try {
                                var body = json.encode({
                                  'pickupLocation': _selectedSource,
                                  'dropoffLocation': _selectedDestination,
                                  'startTime': _startTimeController.text,
                                  'cost': cost,
                                  'seats_available': int.parse(_seatsController.text),
                                  'driver_phone': widget.phoneNumber,
                                  'driver_email': widget.email,
                                });

                                final response = await http.post(
                                  Uri.parse('${APIConstants.baseUrl}/rides'),
                                  headers: {'Content-Type': 'application/json'},
                                  body: body,
                                );

                                if (response.statusCode == 201) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Car pool created successfully'),
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
                                      builder: (context) => MyPools(email: widget.email),
                                    ),
                                  );
                                } else {
                                  var errorMessage = 'Failed to create car pool';
                                  try {
                                    final errorBody = json.decode(response.body);
                                    errorMessage = errorBody['message'] ?? errorMessage;
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
                                    content: Text('Network error: Please check your connection'),
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
        items: items.map<DropdownMenuItem<String>>((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  void _logOut(BuildContext context) async {
    // Delete the token from secure storage
    await secureStorage.delete(key: 'jwt_token');

    // Navigate to SignUpPage with email and phone number
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SignUpScreen(),
      ),
    );
  }
}
