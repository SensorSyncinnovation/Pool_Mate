import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Constants.dart';
import 'package:pool_mate/ride/JoinedPool.dart';
import 'package:pool_mate/ride/chat.dart';

class ListOfAvailablePools extends StatefulWidget {
  final List<dynamic> availableRides;
  final String userEmail;
  final String userPhone;

  ListOfAvailablePools({
    required this.availableRides,
    required this.userEmail,
    required this.userPhone,
  });

  @override
  _ListOfAvailablePoolsState createState() => _ListOfAvailablePoolsState();
}

class _ListOfAvailablePoolsState extends State<ListOfAvailablePools> {
  List<dynamic> joinedPools = [];
  List<dynamic> availableRides = [];
  bool _isLoading = false;
  Map<String, bool> joiningStates = {}; // Track joining state for each pool

  @override
  void initState() {
    super.initState();
    availableRides = List.from(widget.availableRides);
    _fetchAvailableRides();
  }

  Future<void> _fetchAvailableRides() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final response = await http.get(
        Uri.parse('${APIConstants.baseUrl}/available-rides'),
      );
      
      if (response.statusCode == 200) {
        setState(() {
          availableRides = json.decode(response.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching available rides: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> joinPool(Map<String, dynamic> ride) async {
    final poolId = ride['_id'];
    if (joiningStates[poolId] == true) return; // Prevent double-joining

    setState(() {
      joiningStates[poolId] = true;
    });

    try {
      // First join the pool in user's joined_pools
      final joinPoolResponse = await http.post(
        Uri.parse('${APIConstants.baseUrl}/user/join-pool'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'poolId': poolId,
          'email': widget.userEmail,
        }),
      );

      if (joinPoolResponse.statusCode == 200) {
        // Then add passenger to the ride
        final addPassengerResponse = await http.post(
          Uri.parse('${APIConstants.baseUrl}/add-passenger'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'poolId': poolId,
            'email': widget.userEmail,
            'phoneNumber': widget.userPhone,
            'name': widget.userEmail.split('@')[0],
          }),
        );

        if (addPassengerResponse.statusCode == 200) {
          setState(() {
            joinedPools.add(ride);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Successfully joined the pool!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => JoinedPoolsPage(
                joinedPools: joinedPools,
                userEmail: widget.userEmail,
                userPhone: widget.userPhone,
              ),
            ),
          );
        }
      } else {
        final errorData = json.decode(joinPoolResponse.body);
        throw Exception(errorData['message'] ?? 'Failed to join pool');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error joining pool: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        joiningStates[poolId] = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Pools'),
        actions: [
          if (_isLoading)
            Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchAvailableRides,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchAvailableRides,
        child: _isLoading && availableRides.isEmpty
            ? Center(child: CircularProgressIndicator())
            : availableRides.isEmpty
                ? Center(child: Text('No available pools found'))
                : ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: availableRides.length,
                  itemBuilder: (context, index) {
                    final ride = availableRides[index];
                    final poolId = ride['_id'];
                    final source = ride['pickupLocation'] ?? 'Unknown Source';
                    final destination = ride['dropoffLocation'] ?? 'Unknown Destination';
                    final startTime = ride['startTime'] ?? 'N/A';
                    final driverPhone = ride['driver_phone'] ?? 'Unknown';
                    final seatsAvailable = ride['seats_available']?.toString() ?? 'N/A';
                    final cost = ride['cost']?.toString() ?? '0';
                    final isJoining = joiningStates[poolId] ?? false;

                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        source,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Container(
                                        width: 2,
                                        height: 30,
                                        color: Colors.grey,
                                        margin: EdgeInsets.symmetric(vertical: 4),
                                      ),
                                      Text(
                                        destination,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '₹$cost',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Seats: $seatsAvailable',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Start Time: $startTime',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              'Driver Contact: $driverPhone',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              'Driver Email: ${ride['driver_email'] ?? 'Unknown'}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 12),
                            Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  onPressed: isJoining ? null : () => joinPool(ride),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    padding: EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 20),
                                  ),
                                  child: isJoining
                                      ? SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                          ),
                                        )
                                      : Text(
                                          'Join Pool',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      ),
    );
  }
}
