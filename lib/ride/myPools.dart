import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../Constants.dart';

class MyPools extends StatefulWidget {
  final String email;

  const MyPools({Key? key, required this.email}) : super(key: key);

  @override
  _MyPoolsState createState() => _MyPoolsState();
}

class _MyPoolsState extends State<MyPools> {
  List<dynamic> myPools = [];
  bool isLoading = true;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    fetchMyPools();
    // Start long polling
    _pollingTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (mounted) {
        fetchMyPools();
      }
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> fetchMyPools() async {
    try {
      final response = await http.get(
        Uri.parse('${APIConstants.baseUrl}/mypools/${widget.email}'),
      );

      if (response.statusCode == 200) {
        setState(() {
          myPools = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load pools');
      }
    } catch (e) {
      print('Error fetching pools: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _deletePool(String id) async {
    try {
      print('Deleting pool with id: $id'); // Debug log
      final url = '${APIConstants.baseUrl}/pool/$id';
      print('Delete URL: $url'); // Debug log
      
      final response = await http.delete(
        Uri.parse(url),
      ).timeout(Duration(seconds: 10)); // Add timeout

      print('Delete response status: ${response.statusCode}'); // Debug log
      print('Delete response body: ${response.body}'); // Debug log

      if (response.statusCode == 200) {
        setState(() {
          myPools.removeWhere((pool) => pool['_id'] == id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Pool deleted successfully"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        throw Exception('Failed to delete pool: Status ${response.statusCode}');
      }
    } catch (e) {
      print('Delete error: $e'); // Debug log
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting pool: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Pools'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : myPools.isEmpty
              ? Center(child: Text('No pools found'))
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: myPools.length,
                  itemBuilder: (context, index) {
                    final pool = myPools[index];
                    return Card(
                      elevation: 4,
                      margin: EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: EdgeInsets.all(16),
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
                                        'From: ${pool['pickupLocation'] ?? 'N/A'}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'To: ${pool['dropoffLocation'] ?? 'N/A'}',
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
                                      '₹${pool['cost'] ?? '0'}',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                    Text(
                                      '${pool['seats_available'] ?? 0} seats',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                    Text(
                                      '${(pool['passengers'] as List?)?.length ?? 0} passengers',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Time: ${pool['startTime'] ?? 'N/A'}',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            if (pool['driver_phone'] != null) ...[
                              SizedBox(height: 4),
                              Text(
                                'Driver: ${pool['driver_phone']}',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                _deletePool(pool["_id"]);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
