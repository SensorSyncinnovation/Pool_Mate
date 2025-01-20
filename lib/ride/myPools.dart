import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:intl/intl.dart';

class MyPools extends StatefulWidget {
  final String driverId; // Pass the driver's ID

  const MyPools({Key? key, required this.driverId}) : super(key: key);

  @override
  _MyPoolsState createState() => _MyPoolsState();
}

class _MyPoolsState extends State<MyPools> {
  List<Map<String, dynamic>> carPools = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCarPools();
  }

Future<void> _fetchCarPools() async {
  try {
    // Fetch all car pools from the server
    final response = await http.get(Uri.parse('http://192.168.129.42:3000/pools'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      
      // Log the entire response to check the structure
      print('API Response: $data');
   

      // Filter car pools by driverId
      setState(() {
        carPools = data
            .where((pool) => pool['driverId'] == widget.driverId)
            .map((pool) => pool as Map<String, dynamic>)
            .toList();
        isLoading = false;
      });

      // Log the filtered car pools
      print('Filtered Car Pools: $carPools');
    } else {
      throw Exception('Failed to load car pools');
    }
  } catch (e) {
    setState(() {
      isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error fetching car pools: $e'),
        duration: Duration(seconds: 3),
      ),
    );
  }
}


  void _deletePool(String id) async {
    try {
      // Call the API to delete the car pool
      final response =
          await http.delete(Uri.parse('http://192.168.129.42:3000/pool/$id'));

      if (response.statusCode == 200) {
        setState(() {
          carPools.removeWhere((pool) => pool['_id'] == id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Car pool deleted successfully!"),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        throw Exception('Failed to delete car pool');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting car pool: $e'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "My Car Pools",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.lightBlueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : carPools.isEmpty
              ? Center(
                  child: Text(
                    "No car pools available",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: carPools.length,
                  itemBuilder: (context, index) {
                    final pool = carPools[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.blueAccent,
                              child: Text(
                                pool["seats"].toString(),
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${pool['source']} → ${pool['destination']}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    "Seats: ${pool['seats']} | Start Time: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(pool['startTime']))}",
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),
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
