import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DinnerScreen extends StatefulWidget {
  @override
  _DinnerScreenState createState() => _DinnerScreenState();
}

class _DinnerScreenState extends State<DinnerScreen> {
  final CollectionReference suggestions =
  FirebaseFirestore.instance.collection('suggestion');

  Future<List<DocumentSnapshot>> _fetchDiningSuggestions() async {
    QuerySnapshot snapshot = await suggestions.where('type', isEqualTo: 'dining').get();
    return snapshot.docs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dining Suggestions'),
        backgroundColor: Colors.deepOrange,
      ),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: _fetchDiningSuggestions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.data!.isEmpty) {
            return Center(child: Text('No dining suggestions found.'));
          }

          // List of documents fetched from Firestore
          final diningSuggestions = snapshot.data!;

          return ListView.builder(
            itemCount: diningSuggestions.length,
            itemBuilder: (context, index) {
              var suggestion = diningSuggestions[index];
              return Card(
                elevation: 4,
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Display the image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          suggestion['imageUrl'] ?? '', // Use image URL from Firestore
                          fit: BoxFit.cover,
                          height: 150,
                          width: double.infinity,
                        ),
                      ),
                      SizedBox(height: 12),
                      // Display the title
                      Text(
                        suggestion['title'] ?? 'No Title',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      // Display the address and rating in a row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              suggestion['address'] ?? 'No Address',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 8),
                          // Text(
                          //   suggestion['rating']?.toString() ?? 'No Rating',
                          //   style: TextStyle(
                          //     fontSize: 16,
                          //     fontWeight: FontWeight.bold,
                          //     color: Colors.orange,
                          //   ),
                          // ),
                        ],
                      ),
                      SizedBox(height: 8),
                      // Display the description at the end
                      Text(
                        suggestion['description'] ?? 'No Description',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
