import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/crop_plan_provider.dart';
import '../theme.dart';
import '../widgets/step_indicator.dart';
import '../widgets/dropdown_field.dart';
import '../widgets/result_card.dart';
import '../widgets/primary_button.dart';
import '../widgets/loading_overlay.dart';
import 'economic_screen.dart';

class RotationScreen extends StatefulWidget {
  final VoidCallback onNext;

  const RotationScreen({super.key, required this.onNext});

  @override
  State<RotationScreen> createState() => _RotationScreenState();
}

class _RotationScreenState extends State<RotationScreen> {
  String _season = 'Kharif';
  static const _seasons = [
    'Kharif',
    'Rabi',
    'Summer',
    'Winter',
    'Whole Year',
    'Autumn',
  ];
  bool _fetched = false;

  Future<void> _fetch() async {
    final provider = context.read<CropPlanProvider>();
    await provider.fetchRotation(_season);
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
    final result = provider.rotationResult;

    return Scaffold(
      appBar: AppBar(title: const Text('Crop Rotation')),
      body: LoadingOverlay(
        isLoading: provider.isLoading,
        message: 'Planning rotation...',
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const StepIndicator(currentStep: 5),
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
                        'Current crop: ${provider.recommendedCrop}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              DropdownField(
                label: 'Growing Season',
                value: _season,
                items: _seasons,
                onChanged: (v) => setState(() {
                  _season = v ?? 'Kharif';
                  _fetched = false;
                }),
              ),
              const SizedBox(height: 12),

              if (!_fetched)
                PrimaryButton(
                  label: 'Get Rotation Advice',
                  icon: Icons.loop,
                  isLoading: provider.isLoading,
                  onPressed: _fetch,
                ),

              if (_fetched && result != null) ...[
                const SizedBox(height: 8),
                ResultCard(
                  icon: Icons.swap_horiz,
                  title: 'Recommended Next Crop',
                  value: result['recommended_next_crop'] ?? '—',
                  highlight: true,
                  valueColor: AppTheme.primary,
                ),
                ResultCard(
                  icon: Icons.eco,
                  title: 'Soil Benefit',
                  value: result['soil_benefit'] ?? '—',
                  valueColor: AppTheme.secondary,
                ),
                const SizedBox(height: 28),
                PrimaryButton(
                  label: 'Economic Estimation',
                  icon: Icons.attach_money,
                  onPressed: widget.onNext,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
