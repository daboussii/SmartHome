import 'package:flutter/material.dart';
import 'package:fikraa/screens/weather_service.dart';

class WeatherCard extends StatefulWidget {
  @override
  _WeatherCardState createState() => _WeatherCardState();
}

class _WeatherCardState extends State<WeatherCard> {
  double? _temperature;
  final WeatherService _weatherService = WeatherService();

  @override
  void initState() {
    super.initState();
    _fetchTemperature();
  }

  Future<void> _fetchTemperature() async {
    try {
      final temp = await _weatherService.fetchTemperature('Tunisia');
      setState(() {
        _temperature = temp;
      });
    } catch (e) {
      // Handle errors or show a message
      print('Error fetching temperature: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF30334A), // Dark background color
        borderRadius: BorderRadius.circular(15), // Rounded corners
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(10, 12, 20, 30),
            Color.fromARGB(60, 12, 20, 30)
          ], // Gradient background
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.wb_sunny,
                      size: 80, color: Colors.amber), // Sun icon
                  SizedBox(width: 8),
                  Icon(Icons.cloud,
                      size: 50, color: Colors.white54), // Cloud icon
                ],
              ),
              SizedBox(height: 8),
              Text(
                'Cloudy',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.blueGrey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Tonight',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blueGrey,
                ),
              ),
            ],
          ),
          Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _temperature != null
                  ? Text(
                      '${_temperature!.toStringAsFixed(1)}°',
                      style: TextStyle(
                        fontSize: 40,
                        color: Colors.blueGrey,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : CircularProgressIndicator(), // Show loading indicator while fetching
              SizedBox(height: 8),
              Text(
                'Tunisia country',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white54,
                ),
              ),
              SizedBox(height: 10),
              // Wind icon or other weather details
            ],
          ),
        ],
      ),
    );
  }
}
