import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/weather.dart';

class WeatherRepository {
  WeatherRepository({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;

  Future<List<City>> searchCities(String query) async {
    final uri = Uri.https('geocoding-api.open-meteo.com', '/v1/search', {
      'name': query,
      'count': '8',
      'language': 'en',
      'format': 'json',
    });
    final response = await _client
        .get(uri)
        .timeout(const Duration(seconds: 12));
    if (response.statusCode != 200)
      throw Exception('City search is unavailable. Try again.');
    final results =
        (jsonDecode(response.body) as Map<String, dynamic>)['results']
            as List<dynamic>? ??
        [];
    return results.map((item) {
      final data = item as Map<String, dynamic>;
      return City(
        name: data['name'] as String,
        country: data['country'] as String? ?? '',
        latitude: (data['latitude'] as num).toDouble(),
        longitude: (data['longitude'] as num).toDouble(),
        admin1: data['admin1'] as String?,
      );
    }).toList();
  }

  Future<WeatherSnapshot> getWeather(City city) async {
    final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': city.latitude.toString(),
      'longitude': city.longitude.toString(),
      'current': 'temperature_2m,relative_humidity_2m,apparent_temperature,is_day,precipitation,weather_code,wind_speed_10m',
      'daily': 'weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max',
      'timezone': 'auto',
      'forecast_days': '7',
    });
    final response = await _client
        .get(uri)
        .timeout(const Duration(seconds: 12));
    if (response.statusCode != 200)
      throw Exception('Weather service is unavailable. Try again.');
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final current = body['current'] as Map<String, dynamic>;
    final daily = body['daily'] as Map<String, dynamic>;
    final dates = daily['time'] as List<dynamic>;
    final codes = daily['weather_code'] as List<dynamic>;
    final highs = daily['temperature_2m_max'] as List<dynamic>;
    final lows = daily['temperature_2m_min'] as List<dynamic>;
    final rain = daily['precipitation_probability_max'] as List<dynamic>;
    return WeatherSnapshot(
      city: city,
      temperature: (current['temperature_2m'] as num).toDouble(),
      feelsLike: (current['apparent_temperature'] as num).toDouble(),
      humidity: (current['relative_humidity_2m'] as num).toInt(),
      windSpeed: (current['wind_speed_10m'] as num).toDouble(),
      code: (current['weather_code'] as num).toInt(),
      updatedAt: DateTime.parse(current['time'] as String),
      forecast: List.generate(
        dates.length,
        (i) => ForecastDay(
          date: DateTime.parse(dates[i] as String),
          code: (codes[i] as num).toInt(),
          max: (highs[i] as num).toDouble(),
          min: (lows[i] as num).toDouble(),
          precipitation: (rain[i] as num).toInt(),
        ),
      ),
    );
  }
}
