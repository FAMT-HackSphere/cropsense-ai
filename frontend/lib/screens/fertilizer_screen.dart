import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/crop_plan_provider.dart';
import '../widgets/step_indicator.dart';
import '../widgets/result_card.dart';
import '../widgets/primary_button.dart';
import '../widgets/loading_overlay.dart';
import '../theme.dart';
import 'rotation_screen.dart';

class FertilizerScreen extends StatefulWidget {
  final VoidCallback onNext;

  const FertilizerScreen({super.key, required this.onNext});

  @override
  State<FertilizerScreen> createState() => _FertilizerScreenState();
}

class _FertilizerScreenState extends State<FertilizerScreen> {
  bool _fetched = false;

  @override
  void initState() {
    super.initState();
    // Auto-fetch fertilizer recommendation using stored data
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetch());
  }

  Future<void> _fetch() async {
    final provider = context.read<CropPlanProvider>();
    await provider.fetchFertilizer();
    if (mounted) setState(() => _fetched = true);

    if (provider.errorMessage != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CropPlanProvider>();
    final result = provider.fertilizerResult;

    return Scaffold(
      appBar: AppBar(title: const Text('Fertilizer Plan')),
      body: LoadingOverlay(
        isLoading: provider.isLoading,
        message: 'Calculating fertilizer plan...',
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const StepIndicator(currentStep: 4),
              const SizedBox(height: 8),

              // Info chip
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.secondary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        color: AppTheme.secondary, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Based on your soil data and recommended crop: ${provider.recommendedCrop}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              if (_fetched && result != null) ...[
                ResultCard(
                  icon: Icons.science,
                  title: 'Recommended Fertilizer',
                  value: result['recommended_fertilizer'] ?? '—',
                  highlight: true,
                  valueColor: AppTheme.primary,
                ),
                ResultCard(
                  icon: Icons.eco,
                  title: 'Eco-Friendly Option',
                  value: result['eco_friendly_option'] ?? '—',
                  valueColor: AppTheme.secondary,
                ),
                ResultCard(
                  icon: Icons.scale,
                  title: 'Quantity Required',
                  value: '${result['quantity'] ?? '—'} kg/ha',
                ),
              ],

              const SizedBox(height: 28),
              PrimaryButton(
                label: 'Get Crop Rotation Advice',
                icon: Icons.loop,
                isLoading: provider.isLoading,
                onPressed: (_fetched && result != null) ? widget.onNext : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
