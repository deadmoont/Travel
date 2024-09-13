import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/auth.dart';

// TripScreen - Displays the user's trips
class TripScreen extends StatefulWidget {
  @override
  _TripScreenState createState() => _TripScreenState();
}

class _TripScreenState extends State<TripScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthServices _authServices = AuthServices();
  List<Map<String, dynamic>> _userTrips = [];

  @override
  void initState() {
    super.initState();
    _loadTripsForUser();
  }

  Future<void> _loadTripsForUser() async {
    try {
      Map<String, dynamic>? userData = await _authServices.getUserData();

      if (userData != null && userData.containsKey('trips')) {
        setState(() {
          _userTrips = List<Map<String, dynamic>>.from(userData['trips']);
        });
      }
    } catch (e) {
      print('Error loading trips: $e');
    }
  }

  void _addNewTrip() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTripScreen(onTripAdded: _onTripAdded),
      ),
    );
  }

  void _onTripAdded(Map<String, dynamic> newTrip) async {
    try {
      Map<String, dynamic>? userData = await _authServices.getUserData();

      if (userData != null) {
        List<Map<String, dynamic>> trips = List<Map<String, dynamic>>.from(userData['trips'] ?? []);
        trips.add(newTrip);

        await _authServices.updateUserProfile({'trips': trips});

        setState(() {
          _userTrips = trips;
        });
      }
    } catch (e) {
      print('Error adding trip: $e');
    }
  }

  void _viewTripDetails(Map<String, dynamic> trip) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TripDetailScreen(trip: trip)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Trips'),
        backgroundColor: Colors.cyan,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addNewTrip,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _userTrips.isEmpty
            ? Center(
          child: Text(
            'No trips available',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        )
            : ListView.builder(
          itemCount: _userTrips.length,
          itemBuilder: (context, index) {
            var trip = _userTrips[index];
            return Card(
              elevation: 5,
              margin: EdgeInsets.symmetric(vertical: 8.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.all(16),
                leading: Image.asset(
                  'assets/images/trip_photo.jpg', // Display the image from assets
                  width: 80, // Adjust width as needed
                  height: 80, // Adjust height as needed
                  fit: BoxFit.cover, // Adjust the fit to make it look better
                ),
                title: Text(
                  trip['destination'],
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  ' ${trip['startDate']} - ${trip['endDate']}',
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

// TripDetailScreen - Displays details of a selected trip
class TripDetailScreen extends StatelessWidget {
  final Map<String, dynamic> trip;

  TripDetailScreen({required this.trip});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trip to ${trip['destination']}'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Destination: ${trip['destination']}',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.teal),
                SizedBox(width: 8),
                Text('Start Date: ${trip['startDate']}',
                    style: TextStyle(fontSize: 18)),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.calendar_today_outlined, color: Colors.teal),
                SizedBox(width: 8),
                Text('End Date: ${trip['endDate']}',
                    style: TextStyle(fontSize: 18)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// AddTripScreen - Allows the user to add a new trip
class AddTripScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onTripAdded;

  AddTripScreen({required this.onTripAdded});

  @override
  _AddTripScreenState createState() => _AddTripScreenState();
}

class _AddTripScreenState extends State<AddTripScreen> {
  final _destinationController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _selectDate(TextEditingController controller) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        controller.text = picked.toLocal().toString().split(' ')[0];
      });
    }
  }

  Future<void> _saveTrip() async {
    if (_formKey.currentState!.validate()) {
      final newTrip = {
        'destination': _destinationController.text,
        'startDate': _startDateController.text,
        'endDate': _endDateController.text,
      };

      widget.onTripAdded(newTrip);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Trip'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _destinationController,
                decoration: InputDecoration(
                  labelText: 'Destination',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a destination';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _startDateController,
                decoration: InputDecoration(
                  labelText: 'Start Date',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () => _selectDate(_startDateController),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a start date';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _endDateController,
                decoration: InputDecoration(
                  labelText: 'End Date',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  suffixIcon: Icon(Icons.calendar_today_outlined),
                ),
                readOnly: true,
                onTap: () => _selectDate(_endDateController),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select an end date';
                  }
                  return null;
                },
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _saveTrip,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                child: const Text(
                  'Save Trip',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
