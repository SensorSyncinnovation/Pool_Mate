import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Constants.dart';

class JoinedPoolsPage extends StatefulWidget {
  final List<dynamic> joinedPools;
  final String userEmail;
  final String userPhone;
  final String? starting;
  final String? destination;
  JoinedPoolsPage({
    required this.joinedPools,
    required this.userEmail,
    required this.userPhone,
    required this.starting,
    required this.destination,
  });

  @override
  _JoinedPoolsPageState createState() => _JoinedPoolsPageState();
}

class _JoinedPoolsPageState extends State<JoinedPoolsPage> {
  List<dynamic> _pools = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    print(widget.starting);
    print(widget.destination);
    _pools = List.from(widget.joinedPools);
    _fetchJoinedPools();
  }

  Future<void> _fetchJoinedPools() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await http.get(
        Uri.parse(
            '${APIConstants.baseUrl}/user/joined-pools/${widget.userEmail}'),
      );
      print(response.body);
      if (response.statusCode == 200) {
        setState(() {
          _pools = json.decode(response.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching joined pools: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _leavePool(String poolId) async {
    try {
      final response = await http.delete(
        Uri.parse('${APIConstants.baseUrl}/leave-pool'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': widget.userEmail,
          'poolId': poolId,
        }),
      );
      print(response.body);
      if (response.statusCode == 200) {
        setState(() {
          _pools.removeWhere((pool) => pool['_id'] == poolId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Successfully left the pool')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error leaving pool: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('My Rides',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchJoinedPools,
          ),
        ],
      ),
      body: _isLoading && _pools.isEmpty
          ? Center(child: CircularProgressIndicator())
          : _pools.isEmpty
              ? Center(
                  child: Text(
                    'No rides yet',
                    style: TextStyle(fontSize: 20, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: _pools.length,
                  itemBuilder: (context, index) {
                    final pool = _pools[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      color: Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade300, width: 1),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${pool['pickupLocation']} → ${pool['dropoffLocation']}',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text('Leave Ride',
                                          style:
                                              TextStyle(color: Colors.black)),
                                      content: Text(
                                          'Are you sure you want to leave this ride?',
                                          style:
                                              TextStyle(color: Colors.black)),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: Text('Cancel',
                                              style: TextStyle(
                                                  color: Colors.black)),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            _leavePool(pool['_id']);
                                          },
                                          child: Text('Leave',
                                              style:
                                                  TextStyle(color: Colors.red)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            _buildRideDetailRow('Driver', pool['driver']),
                            _buildRideDetailRow('Date', pool['startTime']),
                            _buildRideDetailRow('Cost', '₹${pool['cost']}'),
                            _buildRideDetailRow('Status', pool['status']),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Passengers: ${pool['passengers'].length}/${pool['seats_available'] + pool['passengers'].length}',
                                  style: TextStyle(
                                      color: Colors.grey[700], fontSize: 14),
                                ),
                                Text(
                                  'Driver Contact: ${pool['driver_phone']}',
                                  style: TextStyle(
                                      color: Colors.grey[700], fontSize: 14),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildRideDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          Text(
            value,
            style: TextStyle(color: Colors.black87, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
