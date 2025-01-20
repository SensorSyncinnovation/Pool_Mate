import 'package:flutter/material.dart';

class JoinedPoolsPage extends StatelessWidget {
  final List<dynamic> joinedPools;

  JoinedPoolsPage({required this.joinedPools});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Joined Pools'),
      ),
      body: joinedPools.isEmpty
          ? Center(child: Text('No pools joined yet.'))
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: joinedPools.length,
              itemBuilder: (context, index) {
                final pool = joinedPools[index];
                final source = pool['source'] ?? 'Unknown Source';
                final destination = pool['destination'] ?? 'Unknown Destination';
                final startTime = pool['startTime'] ?? 'N/A';
                final driverName = pool['driver'] ?? 'Unknown Driver';
                final seatsAvailable = pool['seats']?.toString() ?? 'N/A';

                return Dismissible(
                  key: Key(pool.toString()), // Unique key for each pool
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    // Remove the item from the list
                    joinedPools.removeAt(index);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Pool removed successfully.'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  background: Container(
                    alignment: Alignment.centerRight,
                    color: Colors.red,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                  child: Card(
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
                          Text(
                            'Source: $source',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Destination: $destination',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Start Time: $startTime',
                            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Driver: $driverName',
                            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Seats Available: $seatsAvailable',
                            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                          ),
                          SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () {
                              // Remove the pool from the joinedPools list
                              joinedPools.removeAt(index);
                              (context as Element).reassemble(); // Rebuild the widget
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Pool removed successfully.'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                            ),
                            child: Text(
                              'Leave Pool',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
