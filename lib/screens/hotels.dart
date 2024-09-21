import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Hotels extends StatelessWidget {
  const Hotels({Key? key}) : super(key: key);

  Future<List<Map<String, dynamic>>> _fetchHotels() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('suggestion')
        .where('type', isEqualTo: 'hotel')
        .get();

    return querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Hotels'),
        backgroundColor: Colors.deepOrange,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchHotels(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hotels found.', style: TextStyle(fontSize: 20)));
          }

          final hotels = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
            itemCount: hotels.length,
            itemBuilder: (context, index) {
              final hotel = hotels[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                elevation: 6,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: hotel['imageUrl'] != null
                            ? Image.network(
                          hotel['imageUrl'],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        )
                            : const Icon(Icons.hotel, size: 60, color: Colors.deepOrange),
                      ),
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hotel['name'] ?? 'Unknown Hotel',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepOrange,
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              hotel['address'] ?? 'Address not available.',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
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
