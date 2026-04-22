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

  // ── Extended Agricultural Data ────────────────────────────────
  String _soilType = 'Loamy';
  String get soilType => _soilType;
  void setSoilType(String value) { _soilType = value; notifyListeners(); }

  double _soilMoisture = 50.0;
  double get soilMoisture => _soilMoisture;
  void setSoilMoisture(double value) { _soilMoisture = value; notifyListeners(); }

  double _organicCarbon = 1.0;
  double get organicCarbon => _organicCarbon;
  void setOrganicCarbon(double value) { _organicCarbon = value; notifyListeners(); }

  double _soilEC = 1.0;
  double get soilEC => _soilEC;
  void setSoilEC(double value) { _soilEC = value; notifyListeners(); }

  String _season = 'Kharif';
  String get season => _season;
  void setSeason(String value) { _season = value; notifyListeners(); }

  double _landArea = 1.0;
  double get landArea => _landArea;
  void setLandArea(double value) { _landArea = value; notifyListeners(); }

  String _region = '';
  String get region => _region;
  void setRegion(String value) { _region = value; notifyListeners(); }


  String _farmingStrategy = 'Seasonal Farming';
  String get farmingStrategy => _farmingStrategy;
  void setFarmingStrategy(String value) { _farmingStrategy = value; notifyListeners(); }

  int _orchardAge = 0;
  int get orchardAge => _orchardAge;
  void setOrchardAge(int value) { _orchardAge = value; notifyListeners(); }

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
      print("Scaling results using land area: $_landArea");
      _cropResult = await ApiService.predictCrop(
        nitrogen: (_soilInput['nitrogen'] as num).toDouble(),
        phosphorus: (_soilInput['phosphorus'] as num).toDouble(),
        potassium: (_soilInput['potassium'] as num).toDouble(),
        temperature: (_soilInput['temperature'] as num).toDouble(),
        humidity: (_soilInput['humidity'] as num).toDouble(),
        ph: (_soilInput['ph'] as num).toDouble(),
        rainfall: (_soilInput['rainfall'] as num).toDouble(),
        landArea: _landArea,
        district: _region,
        soilType: _soilType,
        organicCarbon: _organicCarbon,
        soilMoisture: _soilMoisture,
        farmingStrategy: _farmingStrategy,
        orchardAge: _orchardAge,
      );

      // 2) Seed prediction (background, uses crop result + soil input)
      try {
        _seedResult = await ApiService.predictSeed(
          cropName: recommendedCrop,
          soilType: _soilInput['soil_type'] ?? 'Loamy',
          temperature: (_soilInput['temperature'] as num).toDouble(),
          rainfall: (_soilInput['rainfall'] as num).toDouble(),
          landArea: _landArea,
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
      print("Scaling results using land area: $_landArea");
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
        landArea: _landArea,
        soilType: _soilType,
        organicCarbon: _organicCarbon,
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
      print("Scaling results using land area: $_landArea");
      _rotationResult = await ApiService.predictRotation(
        currentCrop: recommendedCrop,
        season: season,
        nitrogen: (_soilInput['nitrogen'] as num).toDouble(),
        phosphorus: (_soilInput['phosphorus'] as num).toDouble(),
        potassium: (_soilInput['potassium'] as num).toDouble(),
        ph: (_soilInput['ph'] as num).toDouble(),
        moisture: (_soilInput['moisture'] as num?)?.toDouble() ?? 50,
        landArea: _landArea,
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
      print("Scaling results using land area: $_landArea");
      final yieldPerHa =
          (_cropResult?['expected_yield'] as num?)?.toDouble() ?? 1.0;
      final hectares = _landArea * 0.4047;
      final totalYield = yieldPerHa * hectares;

      _economicResult = await ApiService.predictEconomic(
        cropName: recommendedCrop,
        seedCost: seedCost,
        fertilizerCost: fertilizerCost,
        laborCost: laborCost,
        irrigationCost: irrigationCost,
        yieldAmount: totalYield,
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
    _soilType = 'Loamy';
    _soilMoisture = 50.0;
    _organicCarbon = 1.0;
    _soilEC = 1.0;
    _season = 'Kharif';
    _landArea = 1.0;
    _region = '';

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
