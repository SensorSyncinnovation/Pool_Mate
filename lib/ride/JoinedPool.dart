import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Constants.dart';
class JoinedPoolsPage extends StatefulWidget {
  final List<dynamic> joinedPools;
  final String userEmail;
  final String userPhone;

  JoinedPoolsPage({
    required this.joinedPools,
    required this.userEmail,
    required this.userPhone,
  });

  @override
  _JoinedPoolsPageState createState() => _JoinedPoolsPageState();
}

class _JoinedPoolsPageState extends State<JoinedPoolsPage> {
  List<dynamic> _pools = [];

  @override
  void initState() {
    super.initState();
    _pools = List.from(widget.joinedPools);
    _fetchJoinedPools();
  }

  Future<void> _fetchJoinedPools() async {
    try {
      final response = await http.get(
        Uri.parse('${APIConstants.baseUrl}/user/joined-pools/${widget.userEmail}'),
      );
      
      if (response.statusCode == 200) {
        setState(() {
          _pools = json.decode(response.body);
        });
      }
    } catch (e) {
      print('Error fetching joined pools: $e');
    }
  }

  Future<void> _leavePool(String poolId) async {
    try {
      final response = await http.delete(
        Uri.parse('${APIConstants.baseUrl}/user/leave-pool'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': widget.userEmail,
          'poolId': poolId,
        }),
      );

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
      appBar: AppBar(
        title: Text('Joined Pools'),
      ),
      body: _pools.isEmpty
          ? Center(child: Text('No pools joined yet.'))
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: _pools.length,
              itemBuilder: (context, index) {
                final pool = _pools[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text('${pool['pickupLocation']} to ${pool['dropoffLocation']}', style: TextStyle(fontWeight: FontWeight.bold),),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Date: ${(pool['startTime'])}'),
                        Text('Driver Phone: ${pool['driver_phone']}'),
                        Text('Available Seats: ${pool['seats_available']}'),
                        Text('Cost: ₹${pool['cost']}'),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Leave Pool'),
                          content: Text('Are you sure you want to leave this pool?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _leavePool(pool['_id']);
                              },
                              child: Text('Leave'),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
