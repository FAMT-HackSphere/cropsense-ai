import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/crop_plan_provider.dart';
import '../theme.dart';
import '../widgets/step_indicator.dart';
import 'home_screen.dart';

class FinalReportScreen extends StatelessWidget {
  final VoidCallback onReset;

  const FinalReportScreen({super.key, required this.onReset});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<CropPlanProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Smart Crop Plan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const StepIndicator(currentStep: 7, totalSteps: 7),
            const SizedBox(height: 8),

            // Header
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.eco_rounded,
                        size: 40, color: AppTheme.primary),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Your Smart Crop Plan',
                    style: GoogleFonts.montserrat(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'AI-Generated Agricultural Report',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Section 1: Crop ──────────────────────────────────
            _section(
              context,
              icon: Icons.grass,
              title: 'Crop Recommendation',
              rows: [
                _row('Recommended Crop',
                    p.cropResult?['recommended_crop'] ?? '—'),
                _row(
                    'Seed Variety',
                    p.seedResult?['recommended_seed_variety'] ??
                        p.cropResult?['seed_variety'] ??
                        '—'),
                _row('Expected Yield',
                    '${p.cropResult?['expected_yield'] ?? '—'} tons/ha'),
                if (p.seedResult != null) ...[
                  _row('Germination Rate',
                      p.seedResult!['germination_rate'] ?? '—'),
                  _row('Maturity Period',
                      p.seedResult!['maturity_period'] ?? '—'),
                ],
                _row('Scientific Basis', 
                      p.cropResult?['scientific_explanation'] ?? '—'),
              ],
            ),

            // ── Section 2: Fertilizer ────────────────────────────
            if (p.fertilizerResult != null)
              _section(
                context,
                icon: Icons.science,
                title: 'Fertilizer Plan',
                rows: [
                  _row('Fertilizer',
                      p.fertilizerResult!['recommended_fertilizer'] ?? '—'),
                  _row('Eco-Friendly',
                      p.fertilizerResult!['eco_friendly_option'] ?? '—'),
                  _row('Quantity',
                      '${p.fertilizerResult!['quantity'] ?? '—'} kg/ha'),
                ],
              ),

            // ── Section 3: Rotation ──────────────────────────────
            if (p.rotationResult != null)
              _section(
                context,
                icon: Icons.loop,
                title: 'Crop Rotation Strategy',
                rows: [
                  _row('Next Crop',
                      p.rotationResult!['recommended_next_crop'] ?? '—'),
                  _row('Soil Benefit',
                      p.rotationResult!['soil_benefit'] ?? '—'),
                ],
              ),

            // ── Section 4: Economics ─────────────────────────────
            if (p.economicResult != null)
              _section(
                context,
                icon: Icons.attach_money,
                title: 'Economic Analysis',
                rows: [
                  _row('Total Cost',
                      '₹ ${_fmt(p.economicResult!['total_cost'])}'),
                  _row('Revenue',
                      '₹ ${_fmt(p.economicResult!['revenue'])}'),
                  _row('Predicted Profit',
                      '₹ ${_fmt(p.economicResult!['predicted_profit'])}'),
                  _row('ROI', '${_fmt(p.economicResult!['roi'])} %'),
                ],
                highlight: true,
              ),

            const SizedBox(height: 32),

            // ── Actions ──────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: onReset,
                icon: const Icon(Icons.replay),
                label: const Text('Start New Plan'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────
  static Widget _section(
    BuildContext context, {
    required IconData icon,
    required String title,
    required List<Widget> rows,
    bool highlight = false,
  }) {
    return Card(
      elevation: highlight ? 4 : 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: highlight
            ? const BorderSide(color: AppTheme.accent, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppTheme.primary, size: 22),
                const SizedBox(width: 10),
                Text(title,
                    style: Theme.of(context).textTheme.headlineSmall),
              ],
            ),
            const Divider(height: 24),
            ...rows,
          ],
        ),
      ),
    );
  }

  static Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: GoogleFonts.sourceSans3(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _fmt(dynamic v) {
    if (v == null) return '—';
    final n = double.tryParse(v.toString());
    if (n == null) return v.toString();
    return n.toStringAsFixed(2);
  }
}
