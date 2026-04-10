import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  // Using your computer's local Wi-Fi IP address instead of 127.0.0.1
  // so the physical mobile device can connect to the backend server.
  static String baseUrl = 'http://192.168.1.165:8000';
  static const Duration timeout = Duration(seconds: 15);
}
