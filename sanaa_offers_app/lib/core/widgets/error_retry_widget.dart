import 'package:flutter/material.dart';

/// Elegant error screen — shown instead of raw error codes.
/// Usage: ErrorRetryWidget(message: '...', onRetry: controller.loadOffers)
class ErrorRetryWidget extends StatelessWidget {
  const ErrorRetryWidget({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  static const Color primaryRed = Color(0xFFB3241C);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Soft icon container
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0F0),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: primaryRed.withValues(alpha: 0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                size: 46,
                color: primaryRed,
              ),
            ),
            const SizedBox(height: 24),

            // Friendly Arabic title
            const Text(
              'عذراً، حدثت مشكلة!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),

            // Subtitle — always a user-friendly Arabic message
            Text(
              _friendlyMessage(message),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 32),

            // Retry button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 20),
                label: const Text(
                  'إعادة المحاولة',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryRed,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Maps any raw error string to a short, friendly Arabic message.
  String _friendlyMessage(String raw) {
    if (raw.contains('SocketException') ||
        raw.contains('timeout') ||
        raw.contains('TimeoutException') ||
        raw.contains('network') ||
        raw.contains('connection')) {
      return 'يرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى.';
    }
    if (raw.contains('404')) {
      return 'لم يتم العثور على البيانات المطلوبة، يرجى المحاولة لاحقاً.';
    }
    if (raw.contains('500') || raw.contains('server')) {
      return 'الخادم غير متاح مؤقتاً، يرجى المحاولة بعد قليل.';
    }
    // Fallback — show a clean default message, never raw codes
    return 'يرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى.';
  }
}
