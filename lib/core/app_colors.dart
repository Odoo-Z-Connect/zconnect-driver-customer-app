import 'package:flutter/material.dart';

/// ZConnect brand color palette.
/// Use these constants everywhere — do not hard-code hex values elsewhere.
class AppColors {
  const AppColors._();

  // ── Primary brand ────────────────────────────────────────────────────────
  static const Color lightGreen = Color(0xFFE0EBE6);
  static const Color primaryGreen = Color(0xFF3DB64C);
  static const Color darkGreen = Color(0xFF289131);

  // ── Neutrals ─────────────────────────────────────────────────────────────
  static const Color darkGrey = Color(0xFF424243);
  static const Color warmGrey = Color(0xFFBBB09A);
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF8F9FA);
  static const Color divider = Color(0xFFEEEEEE);

  // ── Status colours ────────────────────────────────────────────────────────
  static const Color statusPending = Color(0xFFFFF3CD);
  static const Color statusPendingText = Color(0xFF856404);
  static const Color statusInTransit = Color(0xFFCCE5FF);
  static const Color statusInTransitText = Color(0xFF004085);
  static const Color statusDelivered = Color(0xFFD4EDDA);
  static const Color statusDeliveredText = Color(0xFF155724);
  static const Color statusCancelled = Color(0xFFF8D7DA);
  static const Color statusCancelledText = Color(0xFF721C24);
  static const Color statusAssigned = Color(0xFFE2D9F3);
  static const Color statusAssignedText = Color(0xFF5A2D82);

  // ── Error / warning ───────────────────────────────────────────────────────
  static const Color error = Color(0xFFDC3545);
  static const Color warning = Color(0xFFFFC107);
  static const Color success = Color(0xFF28A745);

  // Convenience
  static const Color shadow = Color(0x12000000);
}
