import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pool_mate/ride/Find.dart';
import 'package:http/http.dart' as http;
import 'package:pool_mate/ride/myPools.dart';
import 'package:uuid/uuid.dart';

class RidePage extends StatefulWidget {
  @override
  _RidePageState createState() => _RidePageState();
}

class _RidePageState extends State<RidePage> {
  String? _selectedSource;
  String? _selectedDestination;
  String? _selectedSeats;
  String? _selectedStartTime;

  List<String> _sourcelocation = [];
  List<String> _destinationlocation = [];

  final List<String> _seatOptions = ['1', '2', '3', '4', '5'];
  final List<String> _startTimes = [
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '1:00 PM'
  ];

  @override
  void initState() {
    super.initState();
    fetchSources();
    fetchDestinations(); // Fetch destinations when widget is initialized
  }

  Future<void> fetchSources() async {
    const String apiUrl = 'http://10.0.52.146:3000/sources';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        // Parse the response body
        List<dynamic> data = json.decode(response.body);

        // Convert to a List<String>
        setState(() {
          _sourcelocation = List<String>.from(data);
        });
      } else {
        print('Failed to load sources: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching sources: $e');
    }
  }

  Future<void> fetchDestinations() async {
    const String apiUrl =
        'http://10.0.52.146:3000/destinations';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        // Parse the response body
        List<dynamic> data = json.decode(response.body);

        // Convert to a List<String>
        setState(() {
          _destinationlocation = List<String>.from(data);
        });
      } else {
        print('Failed to load destinations: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching destinations: $e');
    }
  }

  bool isFindRide = false;
  bool isOfferRide = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                onPressed: () {},
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
                              builder: (context) => MyPools(driverId: '1',)),
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
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ListOfAvailablePools()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black, // Customize button color
                        foregroundColor: Colors.white,
                        minimumSize: Size(200, 50), // Set button size
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: Text('SEARCH'),
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
                    _buildDropdownField(
                      hint: 'Number of Seats',
                      value: _selectedSeats,
                      items: _seatOptions,
                      onChanged: (value) {
                        setState(() {
                          _selectedSeats = value;
                        });
                      },
                      icon: Icons.event_seat,
                    ),
                    SizedBox(height: 10.0),
                    _buildDropdownField(
                      hint: 'Start Time',
                      value: _selectedStartTime,
                      items: _startTimes,
                      onChanged: (value) {
                        setState(() {
                          _selectedStartTime = value;
                        });
                      },
                      icon: Icons.access_time,
                    ),
                    SizedBox(height: 20.0),
                    // Add the Join button here
                    ElevatedButton(
                      onPressed: () async {
                        // Generate a unique carPoolId
                        var uuid = Uuid();
                        String carPoolId =
                            uuid.v4(); // Generate unique id for car pool

                        // Get the current time for start time and updatedAt
                        DateTime now = DateTime.now();
                        String startTime =
                            now.toIso8601String(); // Format as ISO8601 string
                        String updatedAt = startTime; // Same as start time

                        // Prepare the payload for the POST request
                        var body = json.encode({
                          'carPoolId': carPoolId,
                          'source': _selectedSource,
                          'destination': _selectedDestination,
                          'seats': _selectedSeats,
                          'startTime': startTime,
                          'driverId':
                              1, // Assuming driverId is 1 as per your request
                          'chatRoomId':
                              carPoolId, // Use the same ID for chatRoomId
                          'createdAt': startTime,
                          'updatedAt': updatedAt,
                        });

                        // Make the HTTP POST request
                        try {
                          final response = await http.post(
                            Uri.parse('http://192.168.129.42:3000/pool'),
                            headers: {'Content-Type': 'application/json'},
                            body: body,
                          );

                          // Check if the response is successful
                          if (response.statusCode == 201) {
                            // Success, handle the response as needed
                            print(
                                'Car pool created successfully: ${response.body}');
                          } else {
                            // Error handling
                            print(
                                'Failed to create car pool: ${response.body}');
                          }
                        } catch (e) {
                          print('Error: $e');
                        }

                        // Show the confirmation dialog
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text("Confirm Ride Details"),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text("Source: $_selectedSource"),
                                Text("Destination: $_selectedDestination"),
                                Text("Seats: $_selectedSeats"),
                                Text("Start Time: $startTime"),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text("Cancel"),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text("Confirm"),
                              ),
                            ],
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black, // Customize button color
                        foregroundColor: Colors.white,
                        minimumSize: Size(200, 50), // Set button size
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: Text('CREATE'),
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
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[200],
        prefixIcon: Icon(icon, color: Colors.black),
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
          borderSide: BorderSide.none,
        ),
      ),
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
