import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/app_colors.dart';
import '../../../shared/widgets/zconnect_logo.dart';
import '../../../routes/app_routes.dart';
import '../../../features/shared/models/enums.dart';

/// Welcome / onboarding screen.
/// Explains the app and lets user choose a role.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
                minHeight: size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const SizedBox(height: 100),
                  const ZConnectLogo(size: 64, light: false),
                  const SizedBox(height: 40),
                  Text(
                    'Logistics,\nSimplified',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        height: 1.2,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkGrey),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Premium parcel delivery and driver management at your fingertips.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: AppColors.warmGrey, height: 1.5),
                  ),
                  const SizedBox(height: 60),
                  // Role selection
                  _RoleCard(
                    icon: Icons.person_rounded,
                    title: 'Continue as Customer',
                    subtitle: 'Send parcels, track deliveries',
                    onTap: () => Get.toNamed(AppRoutes.signIn,
                        arguments: UserRole.customer),
                  ),
                  const SizedBox(height: 14),
                  _RoleCard(
                    icon: Icons.drive_eta_rounded,
                    title: 'Continue as Driver',
                    subtitle: 'Accept jobs, manage deliveries',
                    outlined: true,
                    onTap: () => Get.toNamed(AppRoutes.signIn,
                        arguments: UserRole.driver),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _featureIcon(IconData icon) {
    return Container(
      width: 36,
      height: 36,
      decoration:
          const BoxDecoration(color: AppColors.white, shape: BoxShape.circle),
      child: Icon(icon, size: 20, color: AppColors.primaryGreen),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.outlined = false,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final bg = outlined ? Colors.white : AppColors.primaryGreen;
    final fg = outlined ? AppColors.primaryGreen : Colors.white;
    final border = outlined
        ? Border.all(
            color: AppColors.primaryGreen.withValues(alpha: 0.3), width: 1.5)
        : null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
            border: border,
            boxShadow: outlined
                ? null
                : [
                    BoxShadow(
                      color: AppColors.primaryGreen.withValues(alpha: 0.25),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ]),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: outlined
                    ? AppColors.primaryGreen.withValues(alpha: 0.15)
                    : Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: fg, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: fg)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 12, color: fg.withValues(alpha: 0.9))),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: fg.withValues(alpha: 0.5)),
          ],
        ),
      ),
    );
  }
}
