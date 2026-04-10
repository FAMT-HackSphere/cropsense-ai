import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/crop_plan_provider.dart';
import '../theme.dart';
import '../widgets/primary_button.dart';
import '../widgets/step_indicator.dart';

class ExplanationScreen extends StatelessWidget {
  final VoidCallback onNext;

  const ExplanationScreen({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CropPlanProvider>();
    final crop = provider.cropResult;
    final explanation = crop?['scientific_explanation'] ?? 'Data calculating...';

    return Scaffold(
      appBar: AppBar(title: const Text('Scientific Breakdown')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const StepIndicator(currentStep: 3, totalSteps: 7),
            const SizedBox(height: 16),

            // Main Explainer Card
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppTheme.primary, width: 2),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.science,
                        size: 40,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Why ${provider.recommendedCrop}?',
                      style: GoogleFonts.montserrat(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      explanation,
                      textAlign: TextAlign.justify,
                      style: GoogleFonts.sourceSans3(
                        fontSize: 16,
                        height: 1.6,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),
            PrimaryButton(
              label: 'Proceed to Fertilizer Plan',
              icon: Icons.arrow_forward_rounded,
              onPressed: onNext,
            ),
          ],
        ),
      ),
    );
  }
}
