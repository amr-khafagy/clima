class City {
  const City({
    required this.name,
    required this.country,
    required this.latitude,
    required this.longitude,
    this.admin1,
  });

  final String name;
  final String country;
  final double latitude;
  final double longitude;
  final String? admin1;

  String get label => country.isEmpty ? name : '$name, $country';

  Map<String, dynamic> toJson() => {
    'name': name,
    'country': country,
    'latitude': latitude,
    'longitude': longitude,
    'admin1': admin1,
  };

  factory City.fromJson(Map<String, dynamic> json) => City(
    name: json['name'] as String,
    country: json['country'] as String? ?? '',
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
    admin1: json['admin1'] as String?,
  );
}

class ForecastDay {
  const ForecastDay({
    required this.date,
    required this.code,
    required this.max,
    required this.min,
    required this.precipitation,
  });

  final DateTime date;
  final int code;
  final double max;
  final double min;
  final int precipitation;
}

class WeatherSnapshot {
  const WeatherSnapshot({
    required this.city,
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.code,
    required this.updatedAt,
    required this.forecast,
  });

  final City city;
  final double temperature;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final int code;
  final DateTime updatedAt;
  final List<ForecastDay> forecast;
}

class WeatherDescription {
  const WeatherDescription(this.label, this.icon);
  final String label;
  final String icon;

  static WeatherDescription fromCode(int code) {
    if (code == 0) return const WeatherDescription('Clear sky', '☀️');
    if (code <= 3) return const WeatherDescription('Partly cloudy', '⛅');
    if (code == 45 || code == 48)
      return const WeatherDescription('Foggy', '🌫️');
    if (code >= 51 && code <= 67)
      return const WeatherDescription('Drizzle', '🌦️');
    if (code >= 71 && code <= 77)
      return const WeatherDescription('Snowfall', '❄️');
    if (code >= 80 && code <= 82)
      return const WeatherDescription('Rain showers', '🌧️');
    if (code >= 85 && code <= 86)
      return const WeatherDescription('Snow showers', '🌨️');
    if (code >= 95) return const WeatherDescription('Thunderstorm', '⛈️');
    return const WeatherDescription('Cloudy', '☁️');
  }
}
