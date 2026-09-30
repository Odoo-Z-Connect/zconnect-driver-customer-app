import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';

/// Displays the ZConnect logo with optional tagline.
/// Reused on splash, welcome, and auth screens.
class ZConnectLogo extends StatelessWidget {
  const ZConnectLogo(
      {super.key,
      this.size = 64,
      this.showTagline = false,
      this.light = false});
  final double size;
  final bool showTagline;
  final bool light;

  @override
  Widget build(BuildContext context) {
    final textColor = light ? AppColors.white : AppColors.darkGrey;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo mark
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(size * 0.28),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(size * 0.28),
            child: Image.asset(
              'assets/images/zconnect_ecosystem.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'ZConnect',
          style: TextStyle(
            fontSize: size * 0.48,
            fontWeight: FontWeight.w800,
            color: textColor,
            letterSpacing: -0.5,
          ),
        ),
        if (showTagline) ...[
          const SizedBox(height: 4),
          Text(
            'Deliver with confidence',
            style: TextStyle(
                fontSize: 13,
                color: textColor.withValues(alpha: 0.65),
                fontWeight: FontWeight.w400),
          ),
        ],
      ],
    );
  }
}
