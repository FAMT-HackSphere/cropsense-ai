import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import '../utils/error_handler.dart';

class ApiService {
  // ── Health Check & Logging ─────────────────────────────
  static Future<bool> checkHealth() async {
    // STEP 3: HARD-LOG BASE URL
    print("Initialized with BaseURL: ${ApiConfig.baseUrl}");
    print("Attempting to connect to backend: ${ApiConfig.baseUrl}/health");
    
    try {
      // 1. Try the current configured base URL with strict 8s timeout
      final response = await http
          .get(Uri.parse('${ApiConfig.baseUrl}/health'))
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        print("Backend connection success: ${response.statusCode}");
        return true;
      } else {
        print("Backend connection failed with status: ${response.statusCode}");
      }
    } catch (e) {
      print("Backend connection failed with error: $e");
    }

    // 2. Emulator Check (Logging only, no assignment)
    if (ApiConfig.baseUrl.contains('127.0.0.1')) {
      print("Note: If using an emulator without ADB reverse, the backend at 127.0.0.1 may be unreachable.");
    }

    return false;
  }

  static Future<Map<String, dynamic>> predictCrop({
    required double nitrogen,
    required double phosphorus,
    required double potassium,
    required double temperature,
    required double humidity,
    required double ph,
    required double rainfall,
    required double landArea,
    String? district,
    String? soilType,
    double? organicCarbon,
    double? soilMoisture,
    String? farmingStrategy,
    int? orchardAge,
  }) async {
    return _post('/predict/crop', {
      'nitrogen': nitrogen,
      'phosphorus': phosphorus,
      'potassium': potassium,
      'temperature': temperature,
      'humidity': humidity,
      'ph': ph,
      'rainfall': rainfall,
      'land_area': landArea,
      'district': district,
      'soil_type': soilType,
      'organic_carbon': organicCarbon,
      'soil_moisture': soilMoisture,
      'farming_strategy': farmingStrategy,
      'orchard_age': orchardAge,
    });
  }

  static Future<Map<String, dynamic>> predictSeed({
    required String cropName,
    required String soilType,
    double temperature = 25,
    double rainfall = 150,
    double landArea = 1.0,
  }) async {
    return _post('/predict/seed', {
      'crop_name': cropName,
      'soil_type': soilType,
      'temperature': temperature,
      'rainfall': rainfall,
      'land_area': landArea,
    });
  }

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
    required double landArea,
    String? soilType,
    double? organicCarbon,
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
      'land_area': landArea,
      'soil_type': soilType,
      'organic_carbon': organicCarbon,
    });
  }

  static Future<Map<String, dynamic>> predictRotation({
    required String currentCrop,
    required String season,
    double nitrogen = 50,
    double phosphorus = 50,
    double potassium = 50,
    double ph = 6.5,
    double moisture = 50,
    double landArea = 1.0,
  }) async {
    return _post('/predict/rotation', {
      'current_crop': currentCrop,
      'season': season,
      'nitrogen': nitrogen,
      'phosphorus': phosphorus,
      'potassium': potassium,
      'ph': ph,
      'moisture': moisture,
      'land_area': landArea,
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

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        String msg;
        try {
          final data = json.decode(response.body);
          msg = (data is Map && data.containsKey('detail')) 
              ? data['detail'].toString() 
              : 'Server error (${response.statusCode})';
        } catch (_) {
          msg = 'Server encountered an error (${response.statusCode}). Please check backend logs.';
        }
        throw Exception(msg);
      }
    } catch (e) {
      // Use mapper to translate network/server errors
      throw Exception(ErrorHandler.getReadableError(e));
    }
  }
}
