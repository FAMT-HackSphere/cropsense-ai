import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

class ErrorDialog extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorDialog({
    super.key,
    required this.message,
    this.onRetry,
  });

  static Future<void> show(BuildContext context, String message, {VoidCallback? onRetry}) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ErrorDialog(message: message, onRetry: onRetry),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 28),
          const SizedBox(width: 12),
          Text(
            "Something went wrong",
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
      content: Text(
        message,
        style: GoogleFonts.sourceSans3(
          fontSize: 16,
          color: Colors.black87,
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            "Close",
            style: GoogleFonts.sourceSans3(
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (onRetry != null)
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onRetry!();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Retry"),
          ),
      ],
    );
  }
}
