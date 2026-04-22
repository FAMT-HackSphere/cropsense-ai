import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.historyTitle,
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('recommendations')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text(l10n.somethingWentWrong));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return Center(
              child: Text(
                l10n.noHistoryMsg,
                style: GoogleFonts.sourceSans3(
                  color: AppTheme.textSecondary,
                  fontSize: 16,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final date = data['timestamp'] != null 
                  ? (data['timestamp'] as Timestamp).toDate()
                  : DateTime.now();
              
              final crop = (data['crop'] ?? 'Unknown Crop').toString().toUpperCase();
              final strategy = data['farming_strategy'] ?? 'N/A';
              final reasoning = data['scientific_reasoning'] ?? 'Explanation not saved.';
              final rot = data['rotation_result'] ?? {};

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ExpansionTile(
                  title: Text(
                    crop,
                    style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: AppTheme.primary),
                  ),
                  subtitle: Text('Strategy: $strategy | ${date.toLocal().toString().split(' ')[0]}'),
                  childrenPadding: const EdgeInsets.all(16),
                  children: [
                    _reportSection('Soil Context', _mapToString(data['soil_data'] ?? {})),
                    const Divider(),
                    _reportSection('Strategy Specific Reasoning', reasoning.toString().replaceAll('**', '')),
                    const Divider(),
                    if (rot.isNotEmpty)
                       _reportSection('Rotation Suggestion', '${rot['recommended_next_crop']}\n${rot['benefit']}'),
                    const Divider(),
                    _reportSection('Economic Projection', 
                      'Revenue: ₹${data['economic_result']?['revenue'] ?? "N/A"}\n'
                      'Net Profit: ₹${data['economic_result']?['profit'] ?? "N/A"}'
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            FirebaseFirestore.instance.collection('recommendations').doc(docs[index].id).delete();
                          },
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          label: const Text('Delete', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _mapToString(Map<String, dynamic> map) {
    if (map.isEmpty) return 'No soil data recorded.';
    return map.entries.map((e) => "${e.key.toUpperCase()}: ${e.value}").join(", ");
  }

  Widget _reportSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.secondary)),
        const SizedBox(height: 4),
        Text(content, style: const TextStyle(fontSize: 14)),
        const SizedBox(height: 12),
      ],
    );
  }
}
