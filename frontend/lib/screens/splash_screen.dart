import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../l10n/generated/app_localizations.dart';
import '../services/api_service.dart';
import '../theme.dart';
import '../utils/error_handler.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String _status = 'Connecting to server...';
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _checkBackend();
  }

  Future<void> _checkBackend() async {
    setState(() {
      _status = 'Connecting to server...';
      _hasError = false;
    });

    try {
      // Phase 3 & 9: Implement 10s Fail-Safe Timer
      final connected = await Future.any([
        ApiService.checkHealth(),
        Future.delayed(const Duration(seconds: 10)).then((_) => false),
      ]);

      if (!mounted) return;

      if (connected) {
        Navigator.pushReplacementNamed(context, "/home");
      } else {
        setState(() {
          _status = ErrorHandler.getReadableError("Unable to connect to server.");
          _hasError = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _status = ErrorHandler.getReadableError(e);
          _hasError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo Icon
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.eco_rounded,
                size: 72,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'CropSense AI',
              style: GoogleFonts.montserrat(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.smartCropPlanningSystem,
              style: GoogleFonts.sourceSans3(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 48),
            if (!_hasError)
              const CircularProgressIndicator(color: Colors.white),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                _status,
                textAlign: TextAlign.center,
                style: GoogleFonts.sourceSans3(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (_hasError) ...[
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _checkBackend,
                icon: const Icon(Icons.refresh, color: AppTheme.primary),
                label: Text(
                  l10n.retry,
                  style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  minimumSize: const Size(180, 52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
