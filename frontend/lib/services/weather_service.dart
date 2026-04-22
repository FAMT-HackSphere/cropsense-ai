import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class WeatherService {
  /// Fetches real-time localized weather and historical 30-day rainfall 
  /// unconditionally using the free Open-Meteo API.
  static Future<Map<String, double>> fetchWeatherForLocation(LatLng location) async {
    final double lat = location.latitude;
    final double lon = location.longitude;

    // Open-Meteo API URL: Current Temp/Humidity + 30 days of precipitation data
    final Uri url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current=temperature_2m,relative_humidity_2m&daily=precipitation_sum&past_days=30');

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Parse current metrics
        final current = data['current'] as Map<String, dynamic>;
        final temp = (current['temperature_2m'] as num).toDouble();
        final humidity = (current['relative_humidity_2m'] as num).toDouble();

        // Calculate 30-day accumulated rainfall (mm)
        final daily = data['daily'] as Map<String, dynamic>;
        final precipList = daily['precipitation_sum'] as List<dynamic>;
        
        double totalRainfall = 0.0;
        for (var p in precipList) {
          if (p != null) {
            totalRainfall += (p as num).toDouble();
          }
        }

        return {
          'temperature': temp,
          'humidity': humidity,
          'rainfall': totalRainfall,
        };
      } else {
        throw Exception("Failed to load weather data");
      }
    } catch (e) {
      throw Exception("Weather API Error: $e");
    }
  }
}
