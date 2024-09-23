import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart'; // For Date Formatting
import 'package:flutter_spinkit/flutter_spinkit.dart'; // For a custom loader animation

class FlightScreen extends StatefulWidget {
  @override
  _FlightScreenState createState() => _FlightScreenState();
}

class _FlightScreenState extends State<FlightScreen> {
  final TextEditingController _departureController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  List<dynamic> _flights = [];
  bool _loading = false;

  Future<void> _searchFlights() async {
    setState(() {
      _loading = true;
    });

    String departure = _departureController.text; // User should input IATA code
    String destination = _destinationController.text; // IATA code
    String date = _dateController.text; // YYYY-MM-DD

    String apiKey = 'd3fc44ffd02860e828ec366b9b1b548b'; // Your actual API key
    String apiUrl =
        'http://api.aviationstack.com/v1/flights?access_key=$apiKey&dep_iata=$departure&arr_iata=$destination&flight_date=$date';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          // Check if data contains a list of flights
          _flights = data['data'] ?? [];
        });
      } else {
        _showErrorDialog('Failed to fetch flight data');
      }
    } catch (error) {
      _showErrorDialog('Error occurred while fetching flights: $error');
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }



  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  _pickDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Find Your Flight ✈️',
          style: TextStyle(fontFamily: 'Montserrat', fontSize: 24),
        ),
        backgroundColor: Colors.deepOrange,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Search Flights',
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat'),
              ),
              SizedBox(height: 20),
              _buildTextField(
                  label: 'Departure Airport (IATA Code)',
                  icon: Icons.flight_takeoff,
                  controller: _departureController),
              SizedBox(height: 10),
              _buildTextField(
                  label: 'Destination Airport (IATA Code)',
                  icon: Icons.flight_land,
                  controller: _destinationController),
              SizedBox(height: 10),
              _buildDatePickerField(
                  label: 'Travel Date', icon: Icons.date_range),
              SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: _searchFlights,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    padding: EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Search Flights',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(height: 30),
              _loading
                  ? Center(
                child: SpinKitFadingCube(
                  color: Colors.deepOrange,
                  size: 50.0,
                ),
              )
                  : _flights.isNotEmpty
                  ? ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _flights.length,
                itemBuilder: (context, index) {
                  var flight = _flights[index];
                  return _buildFlightCard(flight);
                },
              )
                  : SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      {required String label,
        required IconData icon,
        required TextEditingController controller}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.deepOrange),
        labelText: label,
        labelStyle: TextStyle(color: Colors.deepOrange),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.deepOrange, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.deepOrange),
        ),
      ),
    );
  }

  Widget _buildDatePickerField({required String label, required IconData icon}) {
    return GestureDetector(
      onTap: () {
        _pickDate(context);
      },
      child: AbsorbPointer(
        child: TextField(
          controller: _dateController,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.deepOrange),
            labelText: label,
            labelStyle: TextStyle(color: Colors.deepOrange),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: Colors.deepOrange, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: Colors.deepOrange),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFlightCard(dynamic flight) {
    return Card(
      elevation: 8,
      margin: EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Flight: ${flight['airline']['name'] ?? 'N/A'} (${flight['airline']['iata'] ?? 'N/A'})',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  fontFamily: 'Montserrat'),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildFlightDetail(
                    'From', flight['departure']['airport'], flight['departure']['iata']),
                _buildFlightDetail(
                    'To', flight['arrival']['airport'], flight['arrival']['iata']),
              ],
            ),
            SizedBox(height: 10),
            Text(
              'Departure: ${flight['departure']['scheduled'] ?? 'N/A'}',
              style: TextStyle(color: Colors.grey),
            ),
            Text(
              'Arrival: ${flight['arrival']['scheduled'] ?? 'N/A'}',
              style: TextStyle(color: Colors.grey),
            ),
            Text(
              'Status: ${flight['flight_status'] ?? 'N/A'}',
              style: TextStyle(color: Colors.blueAccent),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildFlightDetail(String label, String? airport, String? code) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                color: Colors.grey, fontSize: 14, fontFamily: 'Montserrat')),
        Text(
          '${airport ?? 'N/A'} (${code ?? 'N/A'})',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }
}
