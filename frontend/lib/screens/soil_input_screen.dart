import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/crop_plan_provider.dart';
import '../widgets/step_indicator.dart';
import '../widgets/slider_input.dart';
import '../widgets/dropdown_field.dart';
import '../widgets/primary_button.dart';
import '../widgets/loading_overlay.dart';
import 'crop_result_screen.dart';

class SoilInputScreen extends StatefulWidget {
  final VoidCallback onNext;

  const SoilInputScreen({super.key, required this.onNext});

  @override
  State<SoilInputScreen> createState() => _SoilInputScreenState();
}

class _SoilInputScreenState extends State<SoilInputScreen> {
  // Soil nutrients
  double _nitrogen = 50;
  double _phosphorus = 50;
  double _potassium = 50;
  double _ph = 6.5;

  // Environment
  double _temperature = 25;
  double _humidity = 60;
  double _rainfall = 150;
  double _moisture = 50;

  // Soil type
  String _soilType = 'Loamy';
  static const _soilTypes = ['Clayey', 'Loamy', 'Peaty', 'Sandy', 'Silty'];

  bool _loading = false;

  Future<void> _predict() async {
    final provider = context.read<CropPlanProvider>();

    // Store soil input data
    provider.setSoilInput({
      'nitrogen': _nitrogen,
      'phosphorus': _phosphorus,
      'potassium': _potassium,
      'ph': _ph,
      'temperature': _temperature,
      'humidity': _humidity,
      'rainfall': _rainfall,
      'moisture': _moisture,
      'soil_type': _soilType,
    });

    setState(() => _loading = true);

    await provider.fetchCropAndSeed();

    if (!mounted) return;
    setState(() => _loading = false);

    if (provider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Soil & Environment')),
      body: LoadingOverlay(
        isLoading: _loading,
        message: 'Analyzing soil data...',
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const StepIndicator(currentStep: 1),
              const SizedBox(height: 8),

              // ── Soil Health Section ────────────────────────────
              _sectionHeader(context, Icons.landscape, 'Soil Health'),
              SliderInput(
                label: 'Nitrogen (N)',
                value: _nitrogen,
                onChanged: (v) => setState(() => _nitrogen = v),
              ),
              SliderInput(
                label: 'Phosphorus (P)',
                value: _phosphorus,
                onChanged: (v) => setState(() => _phosphorus = v),
              ),
              SliderInput(
                label: 'Potassium (K)',
                value: _potassium,
                onChanged: (v) => setState(() => _potassium = v),
              ),
              SliderInput(
                label: 'pH Level',
                value: _ph,
                min: 0,
                max: 14,
                divisions: 140,
                onChanged: (v) => setState(() => _ph = v),
              ),
              SliderInput(
                label: 'Soil Moisture',
                value: _moisture,
                max: 100,
                divisions: 100,
                unit: '%',
                onChanged: (v) => setState(() => _moisture = v),
              ),
              DropdownField(
                label: 'Soil Type',
                value: _soilType,
                items: _soilTypes,
                onChanged: (v) => setState(() => _soilType = v ?? 'Loamy'),
              ),
              const SizedBox(height: 16),

              // ── Weather Section ────────────────────────────────
              _sectionHeader(
                  context, Icons.thermostat, 'Weather Conditions'),
              SliderInput(
                label: 'Temperature',
                value: _temperature,
                min: 0,
                max: 50,
                divisions: 100,
                unit: '°C',
                onChanged: (v) => setState(() => _temperature = v),
              ),
              SliderInput(
                label: 'Humidity',
                value: _humidity,
                max: 100,
                divisions: 100,
                unit: '%',
                onChanged: (v) => setState(() => _humidity = v),
              ),
              SliderInput(
                label: 'Rainfall',
                value: _rainfall,
                max: 300,
                divisions: 300,
                unit: ' mm',
                onChanged: (v) => setState(() => _rainfall = v),
              ),
              const SizedBox(height: 24),

              PrimaryButton(
                label: 'Predict Crop',
                icon: Icons.search,
                isLoading: _loading,
                onPressed: _predict,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(BuildContext ctx, IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(ctx).colorScheme.secondary),
          const SizedBox(width: 8),
          Text(title, style: Theme.of(ctx).textTheme.headlineSmall),
        ],
      ),
    );
  }
}
