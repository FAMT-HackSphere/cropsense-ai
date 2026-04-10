import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class CropPlanProvider extends ChangeNotifier {
  // ── Soil Input Data ───────────────────────────────────────────
  Map<String, dynamic> _soilInput = {};
  Map<String, dynamic> get soilInput => _soilInput;

  void setSoilInput(Map<String, dynamic> data) {
    _soilInput = Map.from(data);
    notifyListeners();
  }

  // ── Crop Result ───────────────────────────────────────────────
  Map<String, dynamic>? _cropResult;
  Map<String, dynamic>? get cropResult => _cropResult;

  // ── Seed Result ───────────────────────────────────────────────
  Map<String, dynamic>? _seedResult;
  Map<String, dynamic>? get seedResult => _seedResult;

  // ── Fertilizer Result ─────────────────────────────────────────
  Map<String, dynamic>? _fertilizerResult;
  Map<String, dynamic>? get fertilizerResult => _fertilizerResult;

  // ── Rotation Result ───────────────────────────────────────────
  Map<String, dynamic>? _rotationResult;
  Map<String, dynamic>? get rotationResult => _rotationResult;

  // ── Economic Result ───────────────────────────────────────────
  Map<String, dynamic>? _economicResult;
  Map<String, dynamic>? get economicResult => _economicResult;

  // ── Loading State ─────────────────────────────────────────────
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // ── Helper: Recommended Crop Name ─────────────────────────────
  String get recommendedCrop =>
      _cropResult?['recommended_crop'] ?? '';

  // ── API Calls ─────────────────────────────────────────────────

  /// Predicts crop, then silently fetches seed recommendation.
  Future<void> fetchCropAndSeed() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1) Crop prediction
      _cropResult = await ApiService.predictCrop(
        nitrogen: (_soilInput['nitrogen'] as num).toDouble(),
        phosphorus: (_soilInput['phosphorus'] as num).toDouble(),
        potassium: (_soilInput['potassium'] as num).toDouble(),
        temperature: (_soilInput['temperature'] as num).toDouble(),
        humidity: (_soilInput['humidity'] as num).toDouble(),
        ph: (_soilInput['ph'] as num).toDouble(),
        rainfall: (_soilInput['rainfall'] as num).toDouble(),
      );

      // 2) Seed prediction (background, uses crop result + soil input)
      try {
        _seedResult = await ApiService.predictSeed(
          cropName: recommendedCrop,
          soilType: _soilInput['soil_type'] ?? 'Loamy',
          temperature: (_soilInput['temperature'] as num).toDouble(),
          rainfall: (_soilInput['rainfall'] as num).toDouble(),
        );
      } catch (_) {
        // Seed fetch failure is non-critical; crop result still valid
        _seedResult = null;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetches fertilizer recommendation using stored soil + crop data.
  Future<void> fetchFertilizer() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _fertilizerResult = await ApiService.predictFertilizer(
        nitrogen: (_soilInput['nitrogen'] as num).toDouble(),
        phosphorus: (_soilInput['phosphorus'] as num).toDouble(),
        potassium: (_soilInput['potassium'] as num).toDouble(),
        ph: (_soilInput['ph'] as num).toDouble(),
        moisture: (_soilInput['moisture'] as num?)?.toDouble() ?? 50,
        temperature: (_soilInput['temperature'] as num).toDouble(),
        humidity: (_soilInput['humidity'] as num).toDouble(),
        rainfall: (_soilInput['rainfall'] as num).toDouble(),
        cropName: recommendedCrop,
      );
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetches crop rotation advice using stored crop + user-selected season.
  Future<void> fetchRotation(String season) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _rotationResult = await ApiService.predictRotation(
        currentCrop: recommendedCrop,
        season: season,
        nitrogen: (_soilInput['nitrogen'] as num).toDouble(),
        phosphorus: (_soilInput['phosphorus'] as num).toDouble(),
        potassium: (_soilInput['potassium'] as num).toDouble(),
        ph: (_soilInput['ph'] as num).toDouble(),
        moisture: (_soilInput['moisture'] as num?)?.toDouble() ?? 50,
      );
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetches economic estimation with user-entered costs.
  Future<void> fetchEconomic({
    required double seedCost,
    required double fertilizerCost,
    required double laborCost,
    required double irrigationCost,
    required double marketPrice,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final yieldAmount =
          (_cropResult?['expected_yield'] as num?)?.toDouble() ?? 1.0;

      _economicResult = await ApiService.predictEconomic(
        cropName: recommendedCrop,
        seedCost: seedCost,
        fertilizerCost: fertilizerCost,
        laborCost: laborCost,
        irrigationCost: irrigationCost,
        yieldAmount: yieldAmount,
        marketPrice: marketPrice,
      );
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Resets everything for a new planning session.
  void reset() {
    _soilInput = {};
    _cropResult = null;
    _seedResult = null;
    _fertilizerResult = null;
    _rotationResult = null;
    _economicResult = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}
