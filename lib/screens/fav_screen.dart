import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:travel/screens/trip_plan.dart'; // Import your TripPlansScreen here
import '../services/auth.dart';

class FavScreen extends StatefulWidget {
  @override
  _FavScreenState createState() => _FavScreenState();
}

class _FavScreenState extends State<FavScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthServices _authServices = AuthServices();
  List<Map<String, dynamic>> _favoriteTrips = [];

  @override
  void initState() {
    super.initState();
    _loadFavoriteTripsForUser();
  }

  Future<void> _loadFavoriteTripsForUser() async {
    try {
      Map<String, dynamic>? userData = await _authServices.getUserData();
      print('User Data: $userData'); // Debugging line

      if (userData != null && userData.containsKey('trips')) {
        List<Map<String, dynamic>> allTrips = List<Map<String, dynamic>>.from(userData['trips']);
        print('All Trips: $allTrips'); // Debugging line

        // Filter trips to include only favorites
        _favoriteTrips = allTrips.where((trip) => trip['fav'] == true).toList();
        print('Favorite Trips: $_favoriteTrips'); // Debugging line

        setState(() {});
      }
    } catch (e) {
      print('Error loading favorite trips: $e');
    }
  }


  void _viewTripDetails(Map<String, dynamic> trip) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TripPlansScreen(serialNumber: trip['serialNumber'])),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Trips'),
        backgroundColor: Colors.deepOrange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _favoriteTrips.isEmpty
            ? Center(
          child: Text(
            'No favorite trips available',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        )
            : ListView.builder(
          itemCount: _favoriteTrips.length,
          itemBuilder: (context, index) {
            var trip = _favoriteTrips[index];
            return Card(
              elevation: 5,
              margin: EdgeInsets.symmetric(vertical: 8.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.all(16),
                leading: Image.asset(
                  'assets/images/trip_photo.jpg',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
                title: Text(
                  trip['destination'],
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${trip['startDate']} - ${trip['endDate']} ',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                onTap: () => _viewTripDetails(trip),
              ),
            );
          },
        ),
      ),
    );
  }
}
