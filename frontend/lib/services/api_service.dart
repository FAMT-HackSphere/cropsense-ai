import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class ApiService {
  // ── Health Check ──────────────────────────────────────────────
  static Future<bool> checkHealth() async {
    // 1. Try the configured base URL first (this covers physical devices on Wi-Fi)
    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/health'))
          .timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        return true;
      }
    } catch (_) {}

    // 2. Try the Android Emulator specific alias if the first failed
    try {
      String url = 'http://10.0.2.2:8000';
      final response = await http.get(Uri.parse('$url/health'))
          .timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        ApiConfig.baseUrl = url;
        return true;
      }
    } catch (_) {}

    // 3. Try localhost fallback (Desktop, Web, or ADB reverse tcp)
    try {
      String url = 'http://127.0.0.1:8000';
      final response = await http.get(Uri.parse('$url/health'))
          .timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        ApiConfig.baseUrl = url;
        return true;
      }
    } catch (_) {}

    return false;
  }

  // ── Crop Prediction ───────────────────────────────────────────
  static Future<Map<String, dynamic>> predictCrop({
    required double nitrogen,
    required double phosphorus,
    required double potassium,
    required double temperature,
    required double humidity,
    required double ph,
    required double rainfall,
  }) async {
    return _post('/predict/crop', {
      'nitrogen': nitrogen,
      'phosphorus': phosphorus,
      'potassium': potassium,
      'temperature': temperature,
      'humidity': humidity,
      'ph': ph,
      'rainfall': rainfall,
    });
  }

  // ── Seed Prediction ───────────────────────────────────────────
  static Future<Map<String, dynamic>> predictSeed({
    required String cropName,
    required String soilType,
    double temperature = 25,
    double rainfall = 150,
  }) async {
    return _post('/predict/seed', {
      'crop_name': cropName,
      'soil_type': soilType,
      'temperature': temperature,
      'rainfall': rainfall,
    });
  }

  // ── Fertilizer Prediction ─────────────────────────────────────
  static Future<Map<String, dynamic>> predictFertilizer({
    required double nitrogen,
    required double phosphorus,
    required double potassium,
    required double ph,
    required double moisture,
    required double temperature,
    required double humidity,
    required double rainfall,
    required String cropName,
  }) async {
    return _post('/predict/fertilizer', {
      'nitrogen': nitrogen,
      'phosphorus': phosphorus,
      'potassium': potassium,
      'ph': ph,
      'moisture': moisture,
      'temperature': temperature,
      'humidity': humidity,
      'rainfall': rainfall,
      'crop_name': cropName,
    });
  }

  // ── Rotation Prediction ───────────────────────────────────────
  static Future<Map<String, dynamic>> predictRotation({
    required String currentCrop,
    required String season,
    double nitrogen = 50,
    double phosphorus = 50,
    double potassium = 50,
    double ph = 6.5,
    double moisture = 50,
  }) async {
    return _post('/predict/rotation', {
      'current_crop': currentCrop,
      'season': season,
      'nitrogen': nitrogen,
      'phosphorus': phosphorus,
      'potassium': potassium,
      'ph': ph,
      'moisture': moisture,
    });
  }

  // ── Economic Prediction ───────────────────────────────────────
  static Future<Map<String, dynamic>> predictEconomic({
    required String cropName,
    required double seedCost,
    required double fertilizerCost,
    required double laborCost,
    required double irrigationCost,
    required double yieldAmount,
    required double marketPrice,
  }) async {
    return _post('/predict/economic', {
      'crop_name': cropName,
      'seed_cost': seedCost,
      'fertilizer_cost': fertilizerCost,
      'labor_cost': laborCost,
      'irrigation_cost': irrigationCost,
      'yield_amount': yieldAmount,
      'market_price': marketPrice,
    });
  }

  // ── Private POST Helper ───────────────────────────────────────
  static Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body,
  ) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$path');
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: json.encode(body),
          )
          .timeout(ApiConfig.timeout);

      final data = json.decode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return data;
      } else {
        final detail = data['detail'] ?? 'Server error (${response.statusCode})';
        throw Exception(detail);
      }
    } on Exception catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      throw Exception(msg);
    }
  }
}
