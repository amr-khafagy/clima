import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/weather_repository.dart';
import '../models/weather.dart';

class WeatherController extends ChangeNotifier {
  WeatherController({
    required WeatherRepository repository,
    required SharedPreferences preferences,
  }) : _repository = repository,
       _preferences = preferences;

  final WeatherRepository _repository;
  final SharedPreferences _preferences;
  static const _favoritesKey = 'clima.favorite_cities';
  static const _selectedKey = 'clima.selected_city';

  City selectedCity = const City(
    name: 'Cairo',
    country: 'Egypt',
    latitude: 30.0444,
    longitude: 31.2357,
  );
  WeatherSnapshot? weather;
  List<City> favorites = [];
  List<City> searchResults = [];
  bool loading = false;
  bool searching = false;
  String? error;
  String? searchError;
  int _searchSequence = 0;

  Future<void> initialize() async {
    final saved = _preferences.getString(_selectedKey);
    if (saved != null) {
      try {
        selectedCity = City.fromJson(jsonDecode(saved) as Map<String, dynamic>);
      } catch (_) {}
    }
    final savedFavorites = _preferences.getStringList(_favoritesKey) ?? [];
    favorites = savedFavorites
        .map((item) {
          try {
            return City.fromJson(jsonDecode(item) as Map<String, dynamic>);
          } catch (_) {
            return null;
          }
        })
        .whereType<City>()
        .toList();
    await refresh();
  }

  Future<void> refresh() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      weather = await _repository.getWeather(selectedCity);
    } catch (exception) {
      error = exception.toString().replaceFirst('Exception: ', '');
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> search(String query) async {
    final sequence = ++_searchSequence;
    if (query.trim().length < 2) {
      searchResults = [];
      searchError = null;
      notifyListeners();
      return;
    }
    searching = true;
    searchError = null;
    notifyListeners();
    try {
      final results = await _repository.searchCities(query.trim());
      if (sequence != _searchSequence) return;
      searchResults = results;
      if (searchResults.isEmpty)
        searchError = 'No cities found. Try another spelling.';
    } catch (exception) {
      if (sequence != _searchSequence) return;
      searchResults = [];
      searchError = exception.toString().replaceFirst('Exception: ', '');
    } finally {
      searching = false;
      notifyListeners();
    }
  }

  Future<void> selectCity(City city) async {
    selectedCity = city;
    weather = null;
    await _preferences.setString(_selectedKey, jsonEncode(city.toJson()));
    await refresh();
  }

  bool isFavorite(City city) => favorites.any((item) => _sameCity(item, city));

  Future<void> toggleFavorite(City city) async {
    if (isFavorite(city)) {
      favorites.removeWhere((item) => _sameCity(item, city));
    } else {
      favorites.add(city);
    }
    await _preferences.setStringList(
      _favoritesKey,
      favorites.map((item) => jsonEncode(item.toJson())).toList(),
    );
    notifyListeners();
  }

  bool _sameCity(City a, City b) =>
      a.latitude == b.latitude && a.longitude == b.longitude;
}
