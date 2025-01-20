import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:pool_mate/ride/JoinedPool.dart';
import 'package:pool_mate/ride/chat.dart';

class ListOfAvailablePools extends StatefulWidget {
  @override
  _ListOfAvailablePoolsState createState() => _ListOfAvailablePoolsState();
}

class _ListOfAvailablePoolsState extends State<ListOfAvailablePools> {
  List<dynamic> carPools = [];
  List<dynamic> joinedPools = []; // List to store joined pools
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCarPools();
  }

  Future<void> fetchCarPools() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.52.146:3000/pools'),
      );

      if (response.statusCode == 200) {
        setState(() {
          carPools = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        throw Exception('Failed to load car pools');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching car pools: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Available Car Pools'),
        actions: [
          IconButton(
            icon: Icon(Icons.list),
            onPressed: () {
              // Navigate to JoinedPoolsPag
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => JoinedPoolsPage(joinedPools: joinedPools),
                ),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: carPools.length,
              itemBuilder: (context, index) {
                final pool = carPools[index];
                final source = pool['source'] ?? 'Unknown Source';
                final destination = pool['destination'] ?? 'Unknown Destination';
                final startTime = pool['startTime'] ?? 'N/A';
                final driverName = pool['driver'] ?? 'Unknown Driver';
                final seatsAvailable = pool['seats']?.toString() ?? 'N/A';
                final chatRoomId = pool['chatRoomId']?.toString() ?? '0';

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
                            Column(
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
                                SizedBox(height: 8),
                                Text(
                                  'Start Time: $startTime',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
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
                        SizedBox(height: 12),
                        Divider(),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                // Add to joined pools and navigate
                                setState(() {
                                  joinedPools.add(pool);
                                });
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => JoinedPoolsPage(
                                      joinedPools: joinedPools,
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                                padding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 20),
                              ),
                              child: Text(
                                'Join',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () {
                                // Navigate to Chat screen
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatBotPage(
                                      chatId: chatRoomId,
                                      source: source,
                                      destination: destination,
                                      seats: seatsAvailable,
                                      startTime: startTime,
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                padding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 20),
                              ),
                              child: Text(
                                'Chat',
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
    );
  }
}
