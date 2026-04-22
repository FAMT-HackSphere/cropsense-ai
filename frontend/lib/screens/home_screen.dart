import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme.dart';
import '../providers/crop_plan_provider.dart';
class HomeScreen extends StatelessWidget {
  final Function(int)? onNavigateTab;

  const HomeScreen({super.key, this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final planner = context.watch<CropPlanProvider>();
    final lastCrop = planner.cropResult?['recommended_crop'] ?? planner.cropResult?['crop'] ?? l10n.noHistoryMsg;
    final bool hasHistory = planner.cropResult != null;
    
    String yieldText = "N/A";
    String profitText = "N/A";
    
    if (hasHistory) {
      yieldText = planner.cropResult?['yield']?.toString() ?? l10n.expectedYield;
      profitText = planner.economicResult?['profit']?.toString() ?? l10n.profitEstimate;
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Logo
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.eco_rounded,
                  size: 64,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: 28),

              // Title
              Text(
                l10n.appTitle,
                style: GoogleFonts.montserrat(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.appDescription,
                textAlign: TextAlign.center,
                style: GoogleFonts.sourceSans3(
                  fontSize: 15,
                  height: 1.5,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 32),
              
              // Primary Actions
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.read<CropPlanProvider>().reset();
                    if (onNavigateTab != null) onNavigateTab!(1); // Go to Recommendation Tab
                  },
                  icon: const Icon(Icons.add_circle_outline),
                  label: Text(l10n.startNewPrediction),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: () {
                    if (onNavigateTab != null) onNavigateTab!(2); // Go to History Tab
                  },
                  icon: const Icon(Icons.history),
                  label: Text(l10n.viewHistory),
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Quick Summary
              Text(
                l10n.recentSummary,
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ]
                ),
                child: hasHistory ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.lastRecommendedCrop,
                      style: GoogleFonts.sourceSans3(color: AppTheme.textSecondary, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lastCrop.toString().toUpperCase(),
                      style: GoogleFonts.montserrat(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                    ),
                    const Divider(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _summaryMetric(l10n.expectedYield, yieldText, Icons.grass),
                        _summaryMetric(l10n.profitEstimate, profitText, Icons.attach_money),
                      ],
                    ),
                  ]
                ) : Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      l10n.noHistoryMsg,
                      style: GoogleFonts.sourceSans3(color: AppTheme.textSecondary),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryMetric(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.secondary, size: 20),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.sourceSans3(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
            Text(
              value,
              style: GoogleFonts.sourceSans3(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
