import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/crop_plan_provider.dart';
import '../theme.dart';
import '../widgets/step_indicator.dart';
import '../widgets/result_card.dart';
import '../widgets/primary_button.dart';
import '../widgets/loading_overlay.dart';
import 'final_report_screen.dart';

class EconomicScreen extends StatefulWidget {
  final VoidCallback onNext;

  const EconomicScreen({super.key, required this.onNext});

  @override
  State<EconomicScreen> createState() => _EconomicScreenState();
}

class _EconomicScreenState extends State<EconomicScreen> {
  final _seedCostCtrl = TextEditingController(text: '500');
  final _fertCostCtrl = TextEditingController(text: '300');
  final _laborCostCtrl = TextEditingController(text: '1000');
  final _irrigCostCtrl = TextEditingController(text: '200');
  final _marketPriceCtrl = TextEditingController(text: '20');

  bool _fetched = false;

  Future<void> _fetch() async {
    final provider = context.read<CropPlanProvider>();
    await provider.fetchEconomic(
      seedCost: double.tryParse(_seedCostCtrl.text) ?? 0,
      fertilizerCost: double.tryParse(_fertCostCtrl.text) ?? 0,
      laborCost: double.tryParse(_laborCostCtrl.text) ?? 0,
      irrigationCost: double.tryParse(_irrigCostCtrl.text) ?? 0,
      marketPrice: double.tryParse(_marketPriceCtrl.text) ?? 0,
    );
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
  void dispose() {
    _seedCostCtrl.dispose();
    _fertCostCtrl.dispose();
    _laborCostCtrl.dispose();
    _irrigCostCtrl.dispose();
    _marketPriceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CropPlanProvider>();
    final result = provider.economicResult;

    return Scaffold(
      appBar: AppBar(title: const Text('Economic Estimation')),
      body: LoadingOverlay(
        isLoading: provider.isLoading,
        message: 'Estimating profit...',
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const StepIndicator(currentStep: 6),
              const SizedBox(height: 8),

              // Info chip
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.secondary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Yield: ${provider.cropResult?['expected_yield'] ?? '—'} tons/ha  •  Crop: ${provider.recommendedCrop}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 16),

              _costField('Seed Cost (₹)', _seedCostCtrl),
              _costField('Fertilizer Cost (₹)', _fertCostCtrl),
              _costField('Labor Cost (₹)', _laborCostCtrl),
              _costField('Irrigation Cost (₹)', _irrigCostCtrl),
              _costField('Market Price per ton (₹)', _marketPriceCtrl),
              const SizedBox(height: 16),

              if (!_fetched)
                PrimaryButton(
                  label: 'Calculate Profit',
                  icon: Icons.calculate,
                  isLoading: provider.isLoading,
                  onPressed: _fetch,
                ),

              if (_fetched && result != null) ...[
                const SizedBox(height: 8),
                ResultCard(
                  icon: Icons.receipt_long,
                  title: 'Total Cost',
                  value: '₹ ${_fmt(result['total_cost'])}',
                ),
                ResultCard(
                  icon: Icons.trending_up,
                  title: 'Revenue',
                  value: '₹ ${_fmt(result['revenue'])}',
                  valueColor: AppTheme.secondary,
                ),
                ResultCard(
                  icon: Icons.savings,
                  title: 'Predicted Profit',
                  value: '₹ ${_fmt(result['predicted_profit'])}',
                  highlight: true,
                  valueColor: AppTheme.primary,
                ),
                ResultCard(
                  icon: Icons.percent,
                  title: 'Return on Investment',
                  value: '${_fmt(result['roi'])} %',
                  highlight: true,
                  valueColor: AppTheme.accent,
                ),
                const SizedBox(height: 28),
                PrimaryButton(
                  label: 'View Final Smart Report',
                  icon: Icons.description,
                  onPressed: widget.onNext,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _costField(String label, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.currency_rupee, size: 18),
        ),
        style: GoogleFonts.robotoMono(fontSize: 15),
        onChanged: (_) {
          if (_fetched) setState(() => _fetched = false);
        },
      ),
    );
  }

  String _fmt(dynamic v) {
    if (v == null) return '—';
    final n = double.tryParse(v.toString());
    if (n == null) return v.toString();
    return n.toStringAsFixed(2);
  }
}
