import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'src/app.dart';
import 'src/data/weather_repository.dart';
import 'src/state/weather_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  runApp(
    ClimaApp(
      controller: WeatherController(
        repository: WeatherRepository(),
        preferences: preferences,
      )..initialize(),
    ),
  );
}
