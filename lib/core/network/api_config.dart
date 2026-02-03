import 'package:flutter_dotenv/flutter_dotenv.dart';

enum AppEnvironment { dev, prod }

class ApiConfig {
  static String baseUrl = 'http://10.0.2.2:3000';
  static const int connectTimeoutMs = 15000;
  static const int receiveTimeoutMs = 15000;

  static AppEnvironment environment = AppEnvironment.dev;
  static bool httpLogsEnabled = true;

  static bool get enableHttpLogs => environment == AppEnvironment.dev && httpLogsEnabled;

  static Future<void> load() async {
    await dotenv.load(fileName: ".env");
    baseUrl = dotenv.env['BASE_URL'] ?? 'http://10.0.2.2:3000';
    environment = dotenv.env['APP_ENVIRONMENT'] == 'prod' ? AppEnvironment.prod : AppEnvironment.dev;
  }

  static void useEnvironment(AppEnvironment env, {bool? enableHttpLogs}) {
    environment = env;
    if (enableHttpLogs != null) {
      httpLogsEnabled = enableHttpLogs;
    }
  }
}
