import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../providers/crop_plan_provider.dart';
import 'pipeline_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                'CropSense AI',
                style: GoogleFonts.montserrat(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your intelligent crop planning assistant.\nEnter your soil data once — get a complete\nfarm plan powered by AI.',
                textAlign: TextAlign.center,
                style: GoogleFonts.sourceSans3(
                  fontSize: 15,
                  height: 1.5,
                  color: AppTheme.textSecondary,
                ),
              ),

              const Spacer(flex: 2),

              // Features summary
              _featureChip(Icons.grass, 'Crop Recommendation'),
              _featureChip(Icons.science, 'Fertilizer Plan'),
              _featureChip(Icons.loop, 'Rotation Strategy'),
              _featureChip(Icons.attach_money, 'Profit Estimation'),
              const SizedBox(height: 32),

              // Primary CTA
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Reset any old session state
                    context.read<CropPlanProvider>().reset();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const PipelineScreen()),
                    );
                  },
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Start Smart Crop Planning'),
                ),
              ),

              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _featureChip(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.secondary),
          const SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.sourceSans3(
              fontSize: 15,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
