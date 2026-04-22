import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme.dart';
import 'package:provider/provider.dart';
import '../providers/crop_plan_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/unit_provider.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = context.watch<LocaleProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.more,
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _buildSectionHeader(l10n.preferences),
          Consumer<UnitProvider>(
            builder: (context, units, _) => _buildListTile(
              icon: Icons.square_foot,
              title: 'Unit Selection',
              subtitle: '${units.getAreaLabel(units.areaUnit)} / ${units.getTempLabel(units.tempUnit)}',
              onTap: () => _showUnitDialog(context, units),
            ),
          ),
          _buildListTile(
            icon: Icons.language,
            title: l10n.language,
            subtitle: _getLanguageName(localeProvider.locale),
            onTap: () => _showLanguageDialog(context, localeProvider),
          ),
          const Divider(),
          _buildSectionHeader(l10n.appInfo),
          _buildListTile(
            icon: Icons.info_outline,
            title: 'About App',
            onTap: () {},
          ),
          _buildListTile(
            icon: Icons.help_outline,
            title: 'Help Guide',
            onTap: () {},
          ),
          _buildListTile(
            icon: Icons.data_usage,
            title: 'Data Sources',
            onTap: () {},
          ),
          const Divider(),
          _buildSectionHeader(l10n.actions),
          _buildListTile(
            icon: Icons.restart_alt,
            title: l10n.resetData,
            onTap: () {
              context.read<CropPlanProvider>().reset();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.resetData)),
              );
            },
            textColor: Colors.red,
            iconColor: Colors.red,
          ),
        ],
      ),
    );
  }

  String _getLanguageName(Locale locale) {
    if (locale.languageCode == 'hi' && locale.countryCode == 'HR') return 'हरियाणवी (Haryanvi)';
    switch (locale.languageCode) {
      case 'hi': return 'हिंदी (Hindi)';
      case 'mr': return 'मराठी (Marathi)';
      default: return 'English';
    }
  }

  void _showLanguageDialog(BuildContext context, LocaleProvider localeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _languageOption(context, localeProvider, const Locale('en'), 'English'),
            _languageOption(context, localeProvider, const Locale('hi'), 'हिंदी (Hindi)'),
            _languageOption(context, localeProvider, const Locale('mr'), 'मराठी (Marathi)'),
            _languageOption(context, localeProvider, const Locale('hi', 'HR'), 'हरियाणवी (Haryanvi)'),
          ],
        ),
      ),
    );
  }

  Widget _languageOption(BuildContext context, LocaleProvider provider, Locale locale, String name) {
    final isSelected = provider.locale == locale || 
                      (provider.locale.languageCode == locale.languageCode && provider.locale.countryCode == locale.countryCode);
    
    return ListTile(
      title: Text(name),
      trailing: isSelected ? const Icon(Icons.check, color: AppTheme.primary) : null,
      onTap: () {
        provider.setLocale(locale);
        Navigator.pop(context);
      },
    );
  }

  void _showUnitDialog(BuildContext context, UnitProvider units) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unit Settings'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Area Unit', style: TextStyle(fontWeight: FontWeight.bold)),
              _unitOption(context, units.areaUnit == AreaUnit.acre, 'Acres', () => units.setAreaUnit(AreaUnit.acre)),
              _unitOption(context, units.areaUnit == AreaUnit.hectare, 'Hectares', () => units.setAreaUnit(AreaUnit.hectare)),
              _unitOption(context, units.areaUnit == AreaUnit.sqm, 'Square Meters', () => units.setAreaUnit(AreaUnit.sqm)),
              const Divider(),
              const Text('Temperature Unit', style: TextStyle(fontWeight: FontWeight.bold)),
              _unitOption(context, units.tempUnit == TempUnit.celsius, 'Celsius (°C)', () => units.setTempUnit(TempUnit.celsius)),
              _unitOption(context, units.tempUnit == TempUnit.fahrenheit, 'Fahrenheit (°F)', () => units.setTempUnit(TempUnit.fahrenheit)),
              const Divider(),
              const Text('Rainfall Unit', style: TextStyle(fontWeight: FontWeight.bold)),
              _unitOption(context, units.rainUnit == RainUnit.mm, 'Millimeters (mm)', () => units.setRainUnit(RainUnit.mm)),
              _unitOption(context, units.rainUnit == RainUnit.inch, 'Inches (in)', () => units.setRainUnit(RainUnit.inch)),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  Widget _unitOption(BuildContext context, bool isSelected, String name, VoidCallback onTap) {
    return ListTile(
      dense: true,
      title: Text(name),
      trailing: isSelected ? const Icon(Icons.check, color: AppTheme.primary) : null,
      onTap: () {
        onTap();
        Navigator.pop(context);
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: GoogleFonts.montserrat(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppTheme.primary,
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? AppTheme.secondary),
      title: Text(
        title,
        style: GoogleFonts.sourceSans3(
          fontSize: 16,
          color: textColor ?? AppTheme.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: GoogleFonts.sourceSans3(
                color: AppTheme.textSecondary,
              ),
            )
          : null,
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}
