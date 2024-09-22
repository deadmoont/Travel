import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class WeatherPage extends StatefulWidget {
  final String venue;
  final String date;

  WeatherPage({required this.venue, required this.date});

  @override
  _WeatherPageState createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  Map<String, dynamic>? weatherData;

  @override
  void initState() {
    super.initState();
    fetchWeather();
  }

  Future<void> fetchWeather() async {
    String apiKey = '9927cfdcd4d1e0e3efbd3f0f58dd7996';
    String apiUrl =
        'https://api.openweathermap.org/data/2.5/forecast?q=${widget.venue}&appid=$apiKey';

    try {
      final response = await http.get(Uri.parse(apiUrl)).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        setState(() {
          weatherData = json.decode(response.body);
        });
      } else {
        _showError('Failed to fetch weather data. Place may not exist.');
      }
    } catch (error) {
      _showError('Network error: Unable to fetch data. Please check your connection.');
    }
  }

  void _showError(String message) {
    setState(() {
      weatherData = null; // Reset weather data on error
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 5),
        backgroundColor: Colors.red,
      ),
    );
  }


  String formatDate(String dateTime) {
    DateTime parsedDate = DateTime.parse(dateTime);
    return DateFormat('EEE, MMM d, HH:mm').format(parsedDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather for ${widget.venue}'),
        backgroundColor: Colors.blueAccent,
      ),
      body: weatherData == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            // Summary section
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                'Weather Summary',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            GridView.count(
              crossAxisCount: 2,
              padding: EdgeInsets.all(10),
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              childAspectRatio: 2,
              children: [
                _buildSummaryCard('Avg Temp',
                    '${((weatherData!['list'].map((item) => item['main']['temp']).reduce((a, b) => a + b) / weatherData!['list'].length) - 273.15).toStringAsFixed(1)}°C'),
                _buildSummaryCard('Day Status',
                    weatherData!['list'][0]['weather'][0]['description'].toUpperCase()),
                _buildSummaryCard('UV Index', '5'), // Replace with actual data if available
                _buildSummaryCard('Humidity',
                    '${weatherData!['list'][0]['main']['humidity']}%'),
                _buildSummaryCard('Wind',
                    '${weatherData!['list'][0]['wind']['speed']} m/s'),
                _buildSummaryCard('Dew Point', '10°C'), // Replace with actual data if available
                _buildSummaryCard('Pressure',
                    '${weatherData!['list'][0]['main']['pressure']} hPa'),
                _buildSummaryCard('Visibility',
                    '${weatherData!['list'][0]['visibility'] / 1000} km'), // Assuming visibility is in meters
              ],
            ),
            // Forecast section
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                '3-Hour Forecast',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            ListView.builder(
              itemCount: weatherData!['list'].length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                var forecast = weatherData!['list'][index];
                var tempCelsius = (forecast['main']['temp'] - 273.15).toStringAsFixed(1);
                var weatherIcon = forecast['weather'][0]['icon'];
                var description = forecast['weather'][0]['description'];
                var dateTime = forecast['dt_txt'];

                return Card(
                  margin: EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.network(
                          'https://openweathermap.org/img/wn/$weatherIcon@2x.png',
                          width: 50,
                          height: 50,
                        ),
                        SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                formatDate(dateTime),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                description.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Temp: $tempCelsius°C',
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value) {
    return Card(
      margin: EdgeInsets.all(5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 5),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
