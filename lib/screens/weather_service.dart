import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  final String apiKey = 'c8353cc62503587f8a18889c646a9314';
  final String baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

  Future<double> fetchTemperature(String city) async {
    final response = await http.get(Uri.parse('$baseUrl?q=$city&appid=$apiKey&units=metric'));
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['main']['temp'].toDouble();
    } else {
      throw Exception('Failed to load weather data');
    }
  }
}
