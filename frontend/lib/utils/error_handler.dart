import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';

class ErrorHandler {
  /// Translates technical exceptions into human-readable strings.
  static String getReadableError(dynamic error) {
    if (kDebugMode) {
      print("ErrorHandler caught: $error");
    }

    final String errorStr = error.toString().toLowerCase();

    // 1. Firebase Errors
    if (errorStr.contains('[core/no-app]')) {
      return "App setup failed. Please restart the app.";
    }
    if (errorStr.contains('firebaseauthexception')) {
      return "Authentication failed. Please try again.";
    }

    // 2. Network Errors
    if (error is SocketException || errorStr.contains('socketexception') || errorStr.contains('failed host lookup')) {
      return "No internet connection. Please check your network.";
    }
    if (error is TimeoutException || errorStr.contains('timeoutexception')) {
      return "Server is taking too long to respond. Please try again.";
    }
    if (errorStr.contains('connection refused') || errorStr.contains('connection failed')) {
      return "Unable to connect to server. Please try again.";
    }

    // 3. HTTP Specific (if passed as string or error message)
    if (errorStr.contains('404')) {
      return "Requested service not found. Please contact support.";
    }
    if (errorStr.contains('500')) {
      return "Server encountered an error. Please try again later.";
    }

    // 4. Custom Backend / Logic Errors
    // Remove "Exception: " prefix and return the raw message
    String cleanMsg = error.toString().replaceFirst('Exception: ', '');
    if (cleanMsg.isNotEmpty && cleanMsg != 'null') return cleanMsg;
    
    // Default
    return "Something went wrong. Please try again.";
  }
}
