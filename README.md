# kpi_mobile_app

KPI Mobile App built with Flutter, Clean Architecture, and Provider.

## Features
- Auth login with secure token storage and refresh flow
- Employees, KPIs, Reports, Projects modules
- Material 3 UI with loading/error/empty states
- Dio networking with centralized API client and debug logging

## Architecture
```
lib/
  core/
    error/
    network/
    utils/
    widgets/
  features/
    auth/
    employees/
    kpis/
    projects/
    reports/
    home/
  main.dart
```

## Requirements
- Flutter 3.9+
- Dart 3.9+

## Configuration
Update the API base URL:
```
lib/core/network/api_config.dart
```

Backend repository:
```
https://github.com/aldoprogrammer/forge-kpi-api
```

Default (Android emulator):
```
http://10.0.2.2:3000
```

For a real device, use your machine LAN IP, for example:
```
http://192.168.1.10:3000
```

## Run
```
flutter pub get
flutter run
```

## Logging (Dev/Prod)
Logging is controlled in code (no CLI required).

Set environment in `lib/main.dart`:
```
ApiConfig.useEnvironment(AppEnvironment.dev);
```
or
```
ApiConfig.useEnvironment(AppEnvironment.prod);
```

You can also disable logs while staying in dev by setting:
```
ApiConfig.httpLogsEnabled = false;
```

## Testing

The test suite for this project covers unit and widget tests, ensuring the application's logic and UI components behave as expected. The tests are configured to run on web, Android, and iOS platforms, providing comprehensive coverage across all supported devices.

To run the tests, use the following command:

```
flutter test
```

## Notes
- The app expects API responses matching the current data models.
- Reports support optional filters: employeeId, from, to.
