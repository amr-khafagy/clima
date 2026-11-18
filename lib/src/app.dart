import 'dart:async';

import 'package:flutter/material.dart';

import 'models/weather.dart';
import 'state/weather_controller.dart';

const _ink = Color(0xFF152343);
const _muted = Color(0xFF8290A8);
const _blue = Color(0xFF4E7BFF);
const _canvas = Color(0xFFF4F7FC);

class ClimaApp extends StatelessWidget {
  const ClimaApp({super.key, required this.controller});
  final WeatherController controller;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Clima',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: _canvas,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _blue,
        brightness: Brightness.light,
      ),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: _canvas,
        foregroundColor: _ink,
        elevation: 0,
      ),
    ),
    home: WeatherHome(controller: controller),
  );
}

class WeatherHome extends StatefulWidget {
  const WeatherHome({super.key, required this.controller});
  final WeatherController controller;

  @override
  State<WeatherHome> createState() => _WeatherHomeState();
}

class _WeatherHomeState extends State<WeatherHome> {
  int _tab = 0;
  WeatherController get c => widget.controller;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: c,
    builder: (context, _) => Scaffold(
      body: SafeArea(child: _tab == 0 ? _buildHome() : _buildSaved()),
      bottomNavigationBar: NavigationBar(
        height: 68,
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFEAF0FF),
        selectedIndex: _tab,
        onDestinationSelected: (index) => setState(() => _tab = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.grid_view_rounded),
            label: 'Weather',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_outline_rounded),
            label: 'Saved',
          ),
        ],
      ),
    ),
  );

  Widget _buildHome() => RefreshIndicator(
    onRefresh: c.refresh,
    child: ListView(
      padding: const EdgeInsets.fromLTRB(22, 10, 22, 28),
      children: [
        _topBar(),
        const SizedBox(height: 22),
        if (c.loading && c.weather == null)
          const SizedBox(
            height: 440,
            child: Center(child: CircularProgressIndicator()),
          ),
        if (c.error != null && c.weather == null)
          _errorCard(c.error!, c.refresh),
        if (c.weather case final snapshot?) ...[
          _hero(snapshot),
          const SizedBox(height: 22),
          _sectionTitle('This week', '7 day forecast'),
          const SizedBox(height: 12),
          _forecast(snapshot.forecast),
          const SizedBox(height: 23),
          _sectionTitle(
            'Today’s highlights',
            'Local time · ${_time(snapshot.updatedAt)}',
          ),
          const SizedBox(height: 12),
          _highlights(snapshot),
          const SizedBox(height: 15),
          const Center(
            child: Text(
              'Weather data by Open-Meteo',
              style: TextStyle(color: _muted, fontSize: 11),
            ),
          ),
        ],
      ],
    ),
  );

  Widget _topBar() => Row(
    children: [
      Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.wb_sunny_rounded, color: _blue),
      ),
      const SizedBox(width: 11),
      const Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CLIMA',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
                color: _ink,
              ),
            ),
            Text(
              'Your day, at a glance',
              style: TextStyle(fontSize: 11, color: _muted),
            ),
          ],
        ),
      ),
      IconButton.filledTonal(
        onPressed: () => _openSearch(context),
        icon: const Icon(Icons.search_rounded),
        style: IconButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: _ink,
        ),
        tooltip: 'Search city',
      ),
      IconButton.filledTonal(
        onPressed: c.weather == null
            ? null
            : () => c.toggleFavorite(c.selectedCity),
        icon: Icon(
          c.isFavorite(c.selectedCity)
              ? Icons.bookmark_rounded
              : Icons.bookmark_add_outlined,
        ),
        style: IconButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: c.isFavorite(c.selectedCity) ? _blue : _ink,
        ),
        tooltip: 'Save city',
      ),
    ],
  );

  Widget _hero(WeatherSnapshot w) {
    final description = WeatherDescription.fromCode(w.code);
    return Container(
      padding: const EdgeInsets.fromLTRB(23, 22, 20, 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF416EF0), Color(0xFF7194FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: _blue.withValues(alpha: .22),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.location_on_rounded,
                color: Colors.white70,
                size: 16,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  w.city.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Text(
                'NOW',
                style: TextStyle(
                  color: Colors.white70,
                  letterSpacing: 1.4,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${w.temperature.round()}°',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 76,
                        height: .98,
                        fontWeight: FontWeight.w300,
                        letterSpacing: -4,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      description.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Feels like ${w.feelsLike.round()}°',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(description.icon, style: const TextStyle(fontSize: 74)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, String trailing) => Row(
    children: [
      Expanded(
        child: Text(
          title,
          style: const TextStyle(
            color: _ink,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      Text(trailing, style: const TextStyle(color: _muted, fontSize: 10)),
    ],
  );

  Widget _forecast(List<ForecastDay> days) => SizedBox(
    height: 133,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: days.length,
      separatorBuilder: (_, __) => const SizedBox(width: 9),
      itemBuilder: (context, index) {
        final day = days[index];
        return Container(
          width: 73,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: index == 0 ? const Color(0xFFEAF0FF) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: index == 0
                ? Border.all(color: const Color(0xFFD6E1FF))
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                index == 0 ? 'Today' : _weekday(day.date),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: index == 0 ? _blue : _muted,
                ),
              ),
              Text(
                WeatherDescription.fromCode(day.code).icon,
                style: const TextStyle(fontSize: 24),
              ),
              Text(
                '${day.max.round()}°  ${day.min.round()}°',
                style: const TextStyle(
                  color: _ink,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.water_drop, size: 10, color: _blue),
                  Text(
                    ' ${day.precipitation}%',
                    style: const TextStyle(color: _muted, fontSize: 9),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    ),
  );

  Widget _highlights(WeatherSnapshot w) => Row(
    children: [
      Expanded(
        child: _metric(
          Icons.water_drop_rounded,
          'Humidity',
          '${w.humidity}%',
          'Relative humidity',
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: _metric(
          Icons.air_rounded,
          'Wind',
          '${w.windSpeed.round()} km/h',
          'Wind speed',
        ),
      ),
    ],
  );

  Widget _metric(IconData icon, String label, String value, String caption) =>
      Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(19),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: _blue, size: 18),
            const SizedBox(height: 13),
            Text(label, style: const TextStyle(color: _muted, fontSize: 11)),
            const SizedBox(height: 3),
            Text(
              value,
              style: const TextStyle(
                color: _ink,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(caption, style: const TextStyle(color: _muted, fontSize: 9)),
          ],
        ),
      );

  Widget _buildSaved() => Padding(
    padding: const EdgeInsets.fromLTRB(22, 18, 22, 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Saved places',
                    style: TextStyle(
                      color: _ink,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Keep an eye on the cities you love',
                    style: TextStyle(color: _muted, fontSize: 12),
                  ),
                ],
              ),
            ),
            IconButton.filledTonal(
              onPressed: () => _openSearch(context),
              icon: const Icon(Icons.add_rounded),
            ),
          ],
        ),
        const SizedBox(height: 18),
        if (c.favorites.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 78,
                    height: 78,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEAF0FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.bookmark_add_outlined,
                      color: _blue,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'No saved cities yet',
                    style: TextStyle(
                      color: _ink,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Search for a place and tap the bookmark icon.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: _muted, fontSize: 12),
                  ),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: ListView.separated(
              itemCount: c.favorites.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final city = c.favorites[index];
                final isCurrent =
                    city.latitude == c.selectedCity.latitude &&
                    city.longitude == c.selectedCity.longitude;
                return Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(19),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(19),
                    onTap: () async {
                      await c.selectCity(city);
                      if (mounted) setState(() => _tab = 0);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEAF0FF),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.location_on_outlined,
                              color: _blue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  city.name,
                                  style: const TextStyle(
                                    color: _ink,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  city.country,
                                  style: const TextStyle(
                                    color: _muted,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isCurrent)
                            const Text(
                              'CURRENT',
                              style: TextStyle(
                                color: _blue,
                                fontSize: 9,
                                letterSpacing: 1,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          IconButton(
                            onPressed: () => c.toggleFavorite(city),
                            icon: const Icon(
                              Icons.close_rounded,
                              color: _muted,
                              size: 18,
                            ),
                            tooltip: 'Remove',
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    ),
  );

  Widget _errorCard(String message, Future<void> Function() retry) => Container(
    margin: const EdgeInsets.only(top: 35),
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
    ),
    child: Column(
      children: [
        const Icon(Icons.cloud_off_rounded, color: _blue, size: 38),
        const SizedBox(height: 10),
        const Text(
          'Couldn’t load the forecast',
          style: TextStyle(color: _ink, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 5),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: _muted, fontSize: 12),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: retry,
          icon: const Icon(Icons.refresh),
          label: const Text('Try again'),
        ),
      ],
    ),
  );

  void _openSearch(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CitySearchSheet(controller: c),
    );
  }
}

class _CitySearchSheet extends StatefulWidget {
  const _CitySearchSheet({required this.controller});
  final WeatherController controller;

  @override
  State<_CitySearchSheet> createState() => _CitySearchSheetState();
}

class _CitySearchSheetState extends State<_CitySearchSheet> {
  final _field = TextEditingController();
  Timer? _debounce;
  WeatherController get c => widget.controller;

  @override
  void dispose() {
    _debounce?.cancel();
    _field.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: c,
    builder: (context, _) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        height: MediaQuery.sizeOf(context).height * .78,
        padding: const EdgeInsets.fromLTRB(22, 13, 22, 20),
        decoration: const BoxDecoration(
          color: _canvas,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD9DFE9),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Find a city',
              style: TextStyle(
                color: _ink,
                fontSize: 23,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Search the world by city name',
              style: TextStyle(color: _muted, fontSize: 12),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _field,
              autofocus: true,
              onChanged: (value) {
                _debounce?.cancel();
                _debounce = Timer(
                  const Duration(milliseconds: 450),
                  () => c.search(value),
                );
              },
              decoration: InputDecoration(
                hintText: 'Try Tokyo, London, Cairo…',
                prefixIcon: const Icon(Icons.search_rounded, color: _muted),
                suffixIcon: c.searching
                    ? const Padding(
                        padding: EdgeInsets.all(14),
                        child: SizedBox(
                          width: 15,
                          height: 15,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (c.searchError != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Center(
                  child: Text(
                    c.searchError!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: _muted),
                  ),
                ),
              ),
            Expanded(
              child: ListView.separated(
                itemCount: c.searchResults.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, indent: 56),
                itemBuilder: (context, index) {
                  final city = c.searchResults[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 3,
                      vertical: 3,
                    ),
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF0FF),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Icon(
                        Icons.location_on_outlined,
                        color: _blue,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      city.name,
                      style: const TextStyle(
                        color: _ink,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      [city.admin1, city.country]
                          .where((value) => value != null && value.isNotEmpty)
                          .join(', '),
                      style: const TextStyle(color: _muted, fontSize: 11),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: _muted,
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      await c.selectCity(city);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

String _weekday(DateTime date) =>
    const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][date.weekday - 1];
String _time(DateTime date) =>
    '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
