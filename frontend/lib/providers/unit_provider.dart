import 'package:flutter/foundation.dart';

enum AreaUnit { acre, hectare, sqm }
enum TempUnit { celsius, fahrenheit }
enum RainUnit { mm, inch }

class UnitProvider extends ChangeNotifier {
  AreaUnit _areaUnit = AreaUnit.acre;
  TempUnit _tempUnit = TempUnit.celsius;
  RainUnit _rainUnit = RainUnit.mm;

  AreaUnit get areaUnit => _areaUnit;
  TempUnit get tempUnit => _tempUnit;
  RainUnit get rainUnit => _rainUnit;

  void setAreaUnit(AreaUnit unit) {
    _areaUnit = unit;
    notifyListeners();
  }

  void setTempUnit(TempUnit unit) {
    _tempUnit = unit;
    notifyListeners();
  }

  void setRainUnit(RainUnit unit) {
    _rainUnit = unit;
    notifyListeners();
  }

  // ── Conversion Logic ──────────────────────────────────────────

  double convertArea(double val, AreaUnit from, AreaUnit to) {
    if (from == to) return val;
    // Base: Acre
    double inAcre;
    switch (from) {
      case AreaUnit.acre: inAcre = val; break;
      case AreaUnit.hectare: inAcre = val / 0.4047; break;
      case AreaUnit.sqm: inAcre = val / 4046.86; break;
    }
    
    switch (to) {
      case AreaUnit.acre: return inAcre;
      case AreaUnit.hectare: return inAcre * 0.4047;
      case AreaUnit.sqm: return inAcre * 4046.86;
    }
  }

  double convertTemp(double val, TempUnit from, TempUnit to) {
    if (from == to) return val;
    if (to == TempUnit.fahrenheit) return (val * 9 / 5) + 32;
    return (val - 32) * 5 / 9;
  }

  double convertRain(double val, RainUnit from, RainUnit to) {
    if (from == to) return val;
    if (to == RainUnit.inch) return val / 25.4;
    return val * 25.4;
  }

  String getAreaLabel(AreaUnit unit) {
    switch (unit) {
      case AreaUnit.acre: return 'Acres';
      case AreaUnit.hectare: return 'Hectares';
      case AreaUnit.sqm: return 'Sq Meters';
    }
  }

  String getTempLabel(TempUnit unit) {
    return unit == TempUnit.celsius ? '°C' : '°F';
  }

  String getRainLabel(RainUnit unit) {
    return unit == RainUnit.mm ? 'mm' : 'inches';
  }
}
