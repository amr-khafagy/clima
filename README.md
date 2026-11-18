# Clima ☀️

A Flutter weather app for discovering a city’s current conditions and 7-day forecast. Search for places around the world, save favorites locally, and come back to your selected city later.

> **Portfolio project:** built to demonstrate a maintainable Flutter app structure, REST API integration, asynchronous UI states, and local persistence.

## Features

- Current temperature, feels-like temperature, humidity, and wind speed
- 7-day forecast with daily highs, lows, weather conditions, and precipitation probability
- City search with debounced requests and stale-response protection
- Saved places and selected city persisted on the device
- Pull to refresh, loading indicators, empty states, and retryable error messages
- Responsive Material 3 interface

## Tech stack

- Flutter and Dart
- Open-Meteo Forecast API and Geocoding API (no API key required)
- `http` for REST requests
- `shared_preferences` for lightweight local persistence

## Run locally

1. Install the [Flutter SDK](https://docs.flutter.dev/get-started/install) and set up an emulator or device.
2. Clone this repository and enter the project folder.
3. Fetch dependencies and launch the app:

   ```sh
   flutter pub get
   flutter run
   ```

## Project structure

```text
lib/
  main.dart
  src/
    app.dart
    data/weather_repository.dart
    models/weather.dart
    state/weather_controller.dart
```

The repository owns API requests and JSON mapping. The controller coordinates UI state and persistence. Widgets render the current state and send user actions to the controller.

## API and attribution

Weather data is provided by [Open-Meteo](https://open-meteo.com/). Its free API is available for non-commercial use under its published terms; attribution is required by the data license. Check the provider’s current terms before using this project commercially or increasing request volume.

## Roadmap

- Unit tests for API mapping and controller state transitions
- Weather details by hour and richer condition descriptions
- Accessibility review and localization
- CI workflow for formatting, analysis, and tests

## License

This project is released under the MIT License. Weather data remains subject to Open-Meteo’s terms and attribution requirements.
