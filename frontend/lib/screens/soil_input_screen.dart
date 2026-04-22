import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import '../l10n/generated/app_localizations.dart';
import '../providers/crop_plan_provider.dart';
import '../providers/unit_provider.dart';
import '../widgets/step_indicator.dart';
import '../widgets/slider_input.dart';
import '../widgets/dropdown_field.dart';
import '../widgets/primary_button.dart';
import '../widgets/loading_overlay.dart';
import '../services/weather_service.dart';
import '../utils/error_handler.dart';
import '../widgets/error_dialog.dart';
import 'map_picker_screen.dart';

class SoilInputScreen extends StatefulWidget {
  final VoidCallback onSubmitted;

  const SoilInputScreen({super.key, required this.onSubmitted});

  @override
  State<SoilInputScreen> createState() => _SoilInputScreenState();
}

class _SoilInputScreenState extends State<SoilInputScreen> {
  final _formKey = GlobalKey<FormState>();

  // Soil nutrients
  double _nitrogen = 50;
  double _phosphorus = 50;
  double _potassium = 50;
  double _ph = 6.5;

  // Environment
  double _temperature = 25;
  double _humidity = 60;
  double _rainfall = 150;

  // Soil Properties
  String _soilType = 'Loamy';
  final TextEditingController _moistureCtrl = TextEditingController();
  final TextEditingController _organicCarbonCtrl = TextEditingController();
  final TextEditingController _ecCtrl = TextEditingController();

  // Farm Context
  String _season = 'Kharif';
  String _farmingStrategy = 'Seasonal Farming';
  final TextEditingController _ageCtrl = TextEditingController(text: '0');
  final TextEditingController _landAreaCtrl = TextEditingController();
  final TextEditingController _regionCtrl = TextEditingController();

  static const _soilTypes = ['Sandy', 'Loamy', 'Clay', 'Black Soil', 'Red Soil'];
  static const _seasons = ['Kharif', 'Rabi', 'Zaid'];
  static const _strategies = ['Seasonal Farming', 'Orchard Farming', 'Mixed Farming (Orchard + Seasonal Intercrop)'];

  bool _loading = false;
  bool _fetchingWeather = false;

  @override
  void dispose() {
    _moistureCtrl.dispose();
    _organicCarbonCtrl.dispose();
    _ecCtrl.dispose();
    _ageCtrl.dispose();
    _landAreaCtrl.dispose();
    _regionCtrl.dispose();
    super.dispose();
  }

  Future<void> _autoFillFromLocation(LatLng location) async {
    print("Soil autofill triggered for location: ${location.latitude}, ${location.longitude}");
    
    // Simple coordinate-to-state mapping logic for major Indian states
    String state = "Maharashtra"; // Default
    double lat = location.latitude;
    double lng = location.longitude;

    if (lat > 20 && lat < 25 && lng > 68 && lng < 75) state = "Gujarat";
    else if (lat > 15 && lat < 20 && lng > 73 && lng < 80) state = "Maharashtra";
    else if (lat > 24 && lat < 30 && lng > 70 && lng < 78) state = "Rajasthan";
    else if (lat > 29 && lat < 33 && lng > 73 && lng < 77) state = "Punjab";
    else if (lat > 11 && lat < 18 && lng > 74 && lng < 78) state = "Karnataka";

    try {
      final String response = await rootBundle.loadString('lib/data/soil_defaults_by_location.json');
      final data = await json.decode(response);
      
      if (data.containsKey(state)) {
        final profile = data[state];
        setState(() {
          _nitrogen = (profile['nitrogen'] as num).toDouble();
          _phosphorus = (profile['phosphorus'] as num).toDouble();
          _potassium = (profile['potassium'] as num).toDouble();
          _ph = (profile['ph'] as num).toDouble();
          _soilType = profile['soil_type'];
          _regionCtrl.text = "${profile['district']}, $state";
          _moistureCtrl.text = profile['moisture'].toString();
          _organicCarbonCtrl.text = profile['organic_carbon'].toString();
        });

        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("${l10n.locationAutofillMsg} ($state)"),
              backgroundColor: Colors.blueAccent,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ErrorDialog.show(context, ErrorHandler.getReadableError(e));
      }
    }
  }

  void _autoFill() {
    setState(() {
      _nitrogen = 45;
      _phosphorus = 30;
      _potassium = 20;
      _ph = 6.5;
      _temperature = 28;
      _humidity = 60;
      _rainfall = 100;
      _soilType = 'Loamy';
      _season = 'Kharif';
    });
    _moistureCtrl.text = '45.0';
    _organicCarbonCtrl.text = '1.2';
    _ecCtrl.text = '1.5';
    _landAreaCtrl.text = '5.0';
    _regionCtrl.text = 'Maharashtra';
  }

  Future<void> _pickLocationAndFetchWeather() async {
    final LatLng? pickedLocation = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MapPickerScreen()),
    );

    if (pickedLocation == null) return;

    setState(() => _fetchingWeather = true);
    
    try {
      final weatherData = await WeatherService.fetchWeatherForLocation(pickedLocation);
      
      setState(() {
        _temperature = double.parse(weatherData['temperature']!.toStringAsFixed(1));
        // Clamp bounds for sliders safety
        if (_temperature < 0) _temperature = 0;
        if (_temperature > 50) _temperature = 50;

        _humidity = double.parse(weatherData['humidity']!.toStringAsFixed(1));
        if (_humidity > 100) _humidity = 100;

        double rain = weatherData['rainfall']!;
        if (rain > 300) rain = 300;
        _rainfall = double.parse(rain.toStringAsFixed(1));
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Live Weather Auto-Filled from Open-Meteo!'), backgroundColor: Colors.green),
        );
      }

      // NEW: Trigger Soil Autofill based on location
      await _autoFillFromLocation(pickedLocation);

    } catch (e) {
      if (mounted) {
        ErrorDialog.show(context, ErrorHandler.getReadableError(e));
      }
    } finally {
      if (mounted) {
        setState(() => _fetchingWeather = false);
      }
    }
  }

  Future<void> _predict() async {
    if (!_formKey.currentState!.validate()) return;

    double moisture = double.tryParse(_moistureCtrl.text) ?? 50.0;
    double organicCarbon = double.tryParse(_organicCarbonCtrl.text) ?? 1.0;
    double ec = double.tryParse(_ecCtrl.text) ?? 1.0;
    double landArea = double.tryParse(_landAreaCtrl.text) ?? 1.0;
    String region = _regionCtrl.text;

    final units = context.read<UnitProvider>();
    final provider = context.read<CropPlanProvider>();
    double landAreaInAcres = units.convertArea(landArea, units.areaUnit, AreaUnit.acre);

    provider.setSoilInput({
      'nitrogen': _nitrogen,
      'phosphorus': _phosphorus,
      'potassium': _potassium,
      'ph': _ph,
      'temperature': _temperature, // Already normalized to Celsius in state
      'humidity': _humidity,
      'rainfall': _rainfall,    // Already normalized to mm in state
      'moisture': moisture,
      'soil_type': _soilType,
    });

    provider.setSoilType(_soilType);
    provider.setSoilMoisture(moisture);
    provider.setOrganicCarbon(organicCarbon);
    provider.setSoilEC(ec);
    provider.setSeason(_season);
    provider.setFarmingStrategy(_farmingStrategy);
    provider.setOrchardAge(int.tryParse(_ageCtrl.text) ?? 0);
    provider.setLandArea(landAreaInAcres);
    provider.setRegion(region);

    setState(() => _loading = true);

    await provider.fetchCropAndSeed();

    if (!mounted) return;
    setState(() => _loading = false);

    if (provider.errorMessage != null && mounted) {
      ErrorDialog.show(context, ErrorHandler.getReadableError(provider.errorMessage!));
      return;
    }

    widget.onSubmitted();
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String? Function(String?) validator,
    TextInputType keyboardType = const TextInputType.numberWithOptions(decimal: true),
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey.withOpacity(0.05),
        ),
        validator: validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.soilInput)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _autoFill,
        icon: const Icon(Icons.flash_on),
        label: Text(l10n.autoFill),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: LoadingOverlay(
        isLoading: _loading || _fetchingWeather,
        message: _fetchingWeather ? 'Retrieving satellite weather data...' : 'Analyzing context data...',
        child: SafeArea(
          child: Form(
            key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),

                // Card 1: Soil Nutrients
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Consumer<UnitProvider>(
                    builder: (context, units, _) => Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionHeader(context, Icons.landscape, l10n.sectionSoilNutrients),
                          SliderInput(label: l10n.nitrogen + ' [mg/kg]', value: _nitrogen, max: 300, onChanged: (v) => setState(() => _nitrogen = v)),
                          SliderInput(label: l10n.phosphorus + ' [mg/kg]', value: _phosphorus, max: 200, onChanged: (v) => setState(() => _phosphorus = v)),
                          SliderInput(label: l10n.potassium + ' [mg/kg]', value: _potassium, max: 500, onChanged: (v) => setState(() => _potassium = v)),
                          SliderInput(label: l10n.ph, value: _ph, min: 0, max: 14, onChanged: (v) => setState(() => _ph = v)),
                          
                          const Divider(height: 32),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                l10n.weatherProfile, 
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
                              ),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.map, size: 18),
                                label: Text(l10n.pickLocation),
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(120, 36),
                                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                  foregroundColor: Theme.of(context).colorScheme.primary,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                ),
                                onPressed: _pickLocationAndFetchWeather,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          SliderInput(
                            label: 'Temperature [${units.getTempLabel(units.tempUnit)}]', 
                            value: units.convertTemp(_temperature, TempUnit.celsius, units.tempUnit), 
                            min: units.convertTemp(0, TempUnit.celsius, units.tempUnit), 
                            max: units.convertTemp(50, TempUnit.celsius, units.tempUnit), 
                            unit: ' ${units.getTempLabel(units.tempUnit)}', 
                            onChanged: (v) => setState(() => _temperature = units.convertTemp(v, units.tempUnit, TempUnit.celsius))
                          ),
                          SliderInput(label: 'Humidity [%]', value: _humidity, max: 100, unit: '%', onChanged: (v) => setState(() => _humidity = v)),
                          SliderInput(
                            label: 'Rainfall [${units.getRainLabel(units.rainUnit)}]', 
                            value: units.convertRain(_rainfall, RainUnit.mm, units.rainUnit), 
                            max: units.convertRain(300, RainUnit.mm, units.rainUnit), 
                            unit: ' ${units.getRainLabel(units.rainUnit)}', 
                            onChanged: (v) => setState(() => _rainfall = units.convertRain(v, units.rainUnit, RainUnit.mm))
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Card 2: Soil Properties
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionHeader(context, Icons.science, l10n.sectionSoilProperties),
                        DropdownField(
                          label: l10n.soilType,
                          value: _soilType,
                          items: _soilTypes,
                          onChanged: (v) => setState(() => _soilType = v ?? 'Loamy'),
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _moistureCtrl,
                          label: l10n.soilMoisture,
                          hint: 'Enter moisture from 0 to 100',
                          validator: (val) {
                            if (val == null || val.isEmpty) return 'Moisture is required';
                            final parsed = double.tryParse(val);
                            if (parsed == null || parsed < 0 || parsed > 100) return 'Must be 0-100';
                            return null;
                          },
                        ),
                        _buildTextField(
                          controller: _organicCarbonCtrl,
                          label: l10n.organicCarbon,
                          hint: 'Enter organic carbon from 0 to 10',
                          validator: (val) {
                            if (val == null || val.isEmpty) return 'Organic Carbon is required';
                            final parsed = double.tryParse(val);
                            if (parsed == null || parsed < 0 || parsed > 10) return 'Must be 0-10';
                            return null;
                          },
                        ),
                        _buildTextField(
                          controller: _ecCtrl,
                          label: 'Electrical Conductivity (dS/m)',
                          hint: 'Enter EC from 0 to 10',
                          validator: (val) {
                            if (val == null || val.isEmpty) return 'EC is required';
                            final parsed = double.tryParse(val);
                            if (parsed == null || parsed < 0 || parsed > 10) return 'Must be 0-10';
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Card 3: Farm Context
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionHeader(context, Icons.agriculture, l10n.sectionFarmContext),
                        DropdownField(
                          label: 'Season',
                          value: _season,
                          items: _seasons,
                          onChanged: (v) => setState(() => _season = v ?? 'Kharif'),
                        ),
                        const SizedBox(height: 16),
                        DropdownField(
                          label: 'Farming Strategy',
                          value: _farmingStrategy,
                          items: _strategies,
                          onChanged: (v) => setState(() => _farmingStrategy = v ?? 'Seasonal Farming'),
                        ),
                        if (_farmingStrategy != 'Seasonal Farming') ...[
                           const SizedBox(height: 16),
                           _buildTextField(
                            controller: _ageCtrl,
                            label: 'Years Since Plantation',
                            hint: 'Enter age from 0 to 20',
                            validator: (val) {
                              if (val == null || val.isEmpty) return 'Age is required';
                              final parsed = int.tryParse(val);
                              if (parsed == null || parsed < 0 || parsed > 20) return 'Must be 0-20';
                              return null;
                            },
                          ),
                        ],
                        const SizedBox(height: 16),
                        Consumer<UnitProvider>(
                          builder: (context, units, _) => _buildTextField(
                            controller: _landAreaCtrl,
                            label: 'Land Area (${units.getAreaLabel(units.areaUnit)})',
                            hint: 'Enter total land area in ${units.getAreaLabel(units.areaUnit)}',
                            validator: (val) {
                              if (val == null || val.isEmpty) return 'Land area is required';
                              final parsed = double.tryParse(val);
                              if (parsed == null || parsed <= 0) return 'Invalid land area';
                              return null;
                            },
                          ),
                        ),
                        _buildTextField(
                          controller: _regionCtrl,
                          label: l10n.region,
                          hint: 'e.g., Pune, Maharashtra',
                          keyboardType: TextInputType.text,
                          validator: (val) {
                            if (val == null || val.isEmpty) return 'Region is required';
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                PrimaryButton(
                  label: l10n.generateRecommendation,
                  icon: Icons.auto_awesome,
                  isLoading: _loading,
                  onPressed: _predict,
                ),
              ],
            ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(BuildContext ctx, IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Theme.of(ctx).colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(child: Text(title, style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}
