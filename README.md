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

## Notes
- The app expects API responses matching the current data models.
- Reports support optional filters: employeeId, from, to.
