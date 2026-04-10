import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/crop_plan_provider.dart';
import '../theme.dart';
import '../widgets/step_indicator.dart';
import '../widgets/result_card.dart';
import '../widgets/primary_button.dart';
import 'fertilizer_screen.dart';

class CropResultScreen extends StatelessWidget {
  final VoidCallback onNext;

  const CropResultScreen({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CropPlanProvider>();
    final crop = provider.cropResult;
    final seed = provider.seedResult;

    return Scaffold(
      appBar: AppBar(title: const Text('Crop Recommendation')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const StepIndicator(currentStep: 2),
            const SizedBox(height: 8),

            // ── Crop Result ──────────────────────────────────────
            ResultCard(
              icon: Icons.grass,
              title: 'Recommended Crop',
              value: crop?['recommended_crop'] ?? '—',
              highlight: true,
              valueColor: AppTheme.primary,
            ),
            ResultCard(
              icon: Icons.spa,
              title: 'Seed Variety',
              value: seed?['recommended_seed_variety'] ??
                  crop?['seed_variety'] ??
                  '—',
            ),
            ResultCard(
              icon: Icons.bar_chart,
              title: 'Expected Yield',
              value: '${crop?['expected_yield'] ?? '—'} tons/ha',
              valueColor: AppTheme.secondary,
            ),

            // ── Seed Details (if available) ──────────────────────
            if (seed != null) ...[
              const SizedBox(height: 8),
              ResultCard(
                icon: Icons.timer,
                title: 'Maturity Period',
                value: seed['maturity_period'] ?? '—',
              ),
              ResultCard(
                icon: Icons.check_circle_outline,
                title: 'Germination Rate',
                value: seed['germination_rate'] ?? '—',
                valueColor: AppTheme.secondary,
              ),
            ],

            const SizedBox(height: 28),
            PrimaryButton(
              label: 'View Scientific Explanation',
              icon: Icons.science,
              onPressed: onNext,
            ),
          ],
        ),
      ),
    );
  }
}
