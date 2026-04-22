import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../l10n/generated/app_localizations.dart';
import '../providers/crop_plan_provider.dart';
import '../theme.dart';
import '../widgets/result_card.dart';
import '../widgets/primary_button.dart';

class CropResultScreen extends StatefulWidget {
  final VoidCallback onReset;

  const CropResultScreen({super.key, required this.onReset});

  @override
  State<CropResultScreen> createState() => _CropResultScreenState();
}

class _CropResultScreenState extends State<CropResultScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _saveToHistory(CropPlanProvider provider) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final data = {
        'timestamp': FieldValue.serverTimestamp(),
        'crop': provider.cropResult?['recommended_crop'] ?? provider.cropResult?['crop'],
        'farming_strategy': provider.farmingStrategy,
        'land_area': provider.landArea,
        'soil_data': provider.soilInput,
        'crop_result': provider.cropResult,
        'fertilizer_result': provider.fertilizerResult,
        'economic_result': provider.economicResult,
        'rotation_result': provider.rotationResult,
        'scientific_reasoning': provider.cropResult?['scientific_explanation'],
      };
      await FirebaseFirestore.instance.collection('recommendations').add(data);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saved to Crop History successfully!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Failed to save: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<CropPlanProvider>();
    final crop = provider.cropResult;
    
    // Header Data
    final cropName = crop?['recommended_crop'] ?? crop?['crop'] ?? 'Unknown';
    final suitability = crop?['suitability'] ?? 'High'; // Mocking since field unspecified
    final confidence = crop?['confidence_score'] ?? '95%';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.resultsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: widget.onReset,
            tooltip: l10n.startOver,
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.all(20),
            color: AppTheme.primary.withOpacity(0.05),
            child: Column(
              children: [
                Text(
                  cropName.toString().toUpperCase(),
                  style: GoogleFonts.montserrat(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _badge('${l10n.confidence}: $confidence', Colors.blue),
                    const SizedBox(width: 8),
                    _badge('${l10n.suitability}: $suitability', Colors.green),
                  ],
                ),
              ],
            ),
          ),
          
          // Tab Bar
          TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: AppTheme.primary,
            unselectedLabelColor: AppTheme.textSecondary,
            indicatorColor: AppTheme.primary,
            tabs: [
              Tab(text: l10n.tabExplanation),
              Tab(text: l10n.tabFertilizer),
              Tab(text: l10n.tabEconomics),
              Tab(text: l10n.tabRotation),
            ],
          ),
          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _ExplanationTab(provider: provider),
                _FertilizerTab(provider: provider),
                _EconomicTab(provider: provider),
                _RotationTab(provider: provider),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: PrimaryButton(
            label: l10n.saveToHistory,
            icon: Icons.save,
            onPressed: () => _saveToHistory(provider),
          ),
        ),
      ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: GoogleFonts.sourceSans3(color: color, fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }
}

// ── Tab 1: Explanation ──────────────────────────────────────
class _ExplanationTab extends StatefulWidget {
  final CropPlanProvider provider;
  const _ExplanationTab({required this.provider});

  @override
  State<_ExplanationTab> createState() => _ExplanationTabState();
}

class _ExplanationTabState extends State<_ExplanationTab> {
  bool _fetched = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetch());
  }

  Future<void> _fetch() async {
    // Explanation is bundled with cropResult, no separate fetch
    if (mounted) setState(() => _fetched = true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (widget.provider.isLoading && !_fetched) {
      return const Center(child: CircularProgressIndicator());
    }
    
    final result = widget.provider.cropResult;
    if (result == null) return const Center(child: Text('Explanation data not available.'));

    final strategyData = result['strategy_data'] ?? {};
    final mode = strategyData['strategy'] ?? 'Seasonal Farming';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.scientificReasoning,
            style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          if (mode == 'Seasonal Farming') ...[
            _buildSeasonalView(strategyData['recommendations'] ?? []),
          ] else if (mode == 'Orchard Farming' || mode == 'Mixed Farming') ...[
            _buildOrchardView(strategyData),
          ],
          
          const SizedBox(height: 24),
          Text(
            'Technical Analysis',
            style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppTheme.secondary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Text(
              result['scientific_explanation']?.toString().replaceAll('**', '') ?? 'Selected based on optimal agricultural models.',
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeasonalView(List recommendations) {
    if (recommendations.isEmpty) return const Text("No seasonal crops found.");
    
    return Column(
      children: recommendations.map((item) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primary)),
                    _badge('${item['probability']}% Match', Colors.blue),
                  ],
                ),
                const Divider(),
                _infoRow(Icons.timer, 'Duration', item['duration']),
                _infoRow(Icons.water_drop, 'Water', item['water_requirement']),
                _infoRow(Icons.grain, 'Seed Rate', item['seed_rate']),
                _infoRow(Icons.calendar_today, 'Suitable Season', item['season']),
                if (item['companion_crops'] != null && (item['companion_crops'] as List).isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text('Companion: ${(item['companion_crops'] as List).join(", ")}', style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.green)),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildOrchardView(Map strategyData) {
    final isMixed = strategyData['strategy'] == 'Mixed Farming';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          color: AppTheme.primary.withOpacity(0.05),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Primary Orchard: ${strategyData['primary_crop']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                const SizedBox(height: 12),
                _infoRow(Icons.settings_overscan, 'Tree Spacing', strategyData['spacing']),
                _infoRow(Icons.summarize, 'Plants / Acre', strategyData['plants_per_acre'].toString()),
                _infoRow(Icons.park, 'Total Saplings', strategyData['total_plants'].toString()),
                _infoRow(Icons.payments, 'Initial Cost', strategyData['initial_investment']),
                _infoRow(Icons.hourglass_bottom, 'Life Span', strategyData['lifespan']),
              ],
            ),
          ),
        ),
        if (isMixed) ...[
          const SizedBox(height: 16),
          Text('Intercropping Plan', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.green.withOpacity(0.3))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(strategyData['intercropping_status'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                const SizedBox(height: 4),
                Text('Recommended: ${(strategyData['recommended_intercrops'] as List).join(", ")}'),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
        const Text('Production Timeline', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        ...(strategyData['yield_timeline'] as List).map((t) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              const Icon(Icons.check_circle_outline, size: 16, color: Colors.blue),
              const SizedBox(width: 8),
              Text('Year ${t['year']}: '),
              Text(t['yield_percent'], style: const TextStyle(fontWeight: FontWeight.bold)),
              const Text(' production'),
            ],
          ),
        )).toList(),
      ],
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppTheme.textSecondary),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(color: AppTheme.textSecondary)),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}

// ── Tab 2: Fertilizer ──────────────────────────────────────
class _FertilizerTab extends StatefulWidget {
  final CropPlanProvider provider;
  const _FertilizerTab({required this.provider});

  @override
  State<_FertilizerTab> createState() => _FertilizerTabState();
}

class _FertilizerTabState extends State<_FertilizerTab> {
  bool _fetched = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetch());
  }

  Future<void> _fetch() async {
    await widget.provider.fetchFertilizer();
    if (mounted) setState(() => _fetched = true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (widget.provider.isLoading && !_fetched) {
      return const Center(child: CircularProgressIndicator());
    }

    final result = widget.provider.fertilizerResult;
    final hectares = widget.provider.landArea * 0.4047;
    final fertPerHa = double.tryParse(result?['quantity']?.toString() ?? '0') ?? 0.0;
    final total = fertPerHa * hectares;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          ResultCard(icon: Icons.science, title: 'Recommended Fertilizer', value: result?['recommended_fertilizer'] ?? '—', highlight: true),
          ResultCard(icon: Icons.eco, title: 'Eco-Friendly Option', value: result?['eco_friendly_option'] ?? '—'),
          ResultCard(icon: Icons.scale, title: l10n.perHectare, value: '${fertPerHa} kg/ha'),
          ResultCard(icon: Icons.shopping_cart, title: l10n.totalRequired, value: '${total.toStringAsFixed(2)} kg (for ${widget.provider.landArea} acres)', valueColor: AppTheme.secondary),
        ],
      ),
    );
  }
}

// ── Tab 3: Economic ─────────────────────────────────────────
class _EconomicTab extends StatefulWidget {
  final CropPlanProvider provider;
  const _EconomicTab({required this.provider});

  @override
  State<_EconomicTab> createState() => _EconomicTabState();
}

class _EconomicTabState extends State<_EconomicTab> {
  final _costCtrl = TextEditingController(text: '2000');
  final _priceCtrl = TextEditingController(text: '20');
  bool _fetched = false;

  Future<void> _calc() async {
    await widget.provider.fetchEconomic(
      seedCost: double.tryParse(_costCtrl.text) ?? 500,
      fertilizerCost: 500, // simplified for ui design
      laborCost: 1000,
      irrigationCost: 0,
      marketPrice: double.tryParse(_priceCtrl.text) ?? 20,
    );
    if (mounted) setState(() => _fetched = true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final result = widget.provider.economicResult;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _costCtrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: l10n.estCultivationCost, prefixIcon: const Icon(Icons.currency_rupee)),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _priceCtrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: l10n.marketPricePerTon, prefixIcon: const Icon(Icons.currency_rupee)),
          ),
          const SizedBox(height: 16),
          PrimaryButton(label: l10n.calculateProfit, onPressed: _calc, isLoading: widget.provider.isLoading),
          const SizedBox(height: 24),
          if (_fetched && result != null) ...[
            ResultCard(icon: Icons.receipt_long, title: l10n.totalCost, value: '₹ ${result['total_cost'] ?? "—"}'),
            ResultCard(icon: Icons.trending_up, title: l10n.revenue, value: '₹ ${result['revenue'] ?? "—"}'),
            ResultCard(icon: Icons.savings, title: l10n.netProfit, value: '₹ ${result['profit'] ?? "—"}', highlight: true),
          ],
        ],
      ),
    );
  }
}

// ── Tab 4: Rotation ─────────────────────────────────────────
class _RotationTab extends StatefulWidget {
  final CropPlanProvider provider;
  const _RotationTab({required this.provider});

  @override
  State<_RotationTab> createState() => _RotationTabState();
}

class _RotationTabState extends State<_RotationTab> {
  bool _fetched = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetch());
  }

  Future<void> _fetch() async {
    await widget.provider.fetchRotation(widget.provider.season);
    if (mounted) setState(() => _fetched = true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (widget.provider.isLoading && !_fetched) {
      return const Center(child: CircularProgressIndicator());
    }
    
    final result = widget.provider.rotationResult;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          ResultCard(icon: Icons.loop, title: l10n.nextBestCrop, value: result?['recommended_next_crop'] ?? '—', highlight: true),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.benefit, style: GoogleFonts.sourceSans3(color: AppTheme.textSecondary)),
                Text(result?['benefit'] ?? 'Improves soil health', style: GoogleFonts.sourceSans3(fontSize: 16)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
