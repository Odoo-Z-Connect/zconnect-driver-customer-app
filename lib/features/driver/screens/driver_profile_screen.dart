import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/app_colors.dart';
import '../../../shared/widgets/zc_widgets.dart';
import '../../../features/auth/controllers/auth_controller.dart';
import '../../../features/shared/models/enums.dart';
import '../../../routes/app_routes.dart';

class DriverProfileScreen extends StatelessWidget {
  const DriverProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        final user = auth.currentUser.value;
        final isOnline = user?.availability == DriverAvailability.online;

        return CustomScrollView(
          slivers: [
            // ── Header ────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(28),
                      bottomRight: Radius.circular(28)),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                    child: Column(
                      children: [
                        // App bar row
                        Row(
                          children: [
                            const Text('Profile',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.darkGrey)),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined,
                                  size: 20, color: AppColors.primaryGreen),
                              onPressed: () => _showEditProfile(context, auth),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Avatar + name card
                        Row(
                          children: [
                            // ZConnect icon as avatar
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: AppColors.lightGreen,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: AppColors.primaryGreen, width: 2),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(18),
                                child: Image.asset(
                                  'assets/images/zconnect_ecosystem.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user?.name ?? '—',
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.darkGrey),
                                  ),
                                  if ((user?.email ?? '').isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(user!.email,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.warmGrey)),
                                  ],
                                  if ((user?.phone ?? '').isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(user!.phone,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.warmGrey)),
                                  ],
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      // Online status badge
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: isOnline
                                              ? AppColors.lightGreen
                                              : const Color(0xFFEEEEEE),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              width: 7,
                                              height: 7,
                                              decoration: BoxDecoration(
                                                color: isOnline
                                                    ? AppColors.primaryGreen
                                                    : AppColors.warmGrey,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              isOnline ? 'Online' : 'Offline',
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: isOnline
                                                      ? AppColors.primaryGreen
                                                      : AppColors.warmGrey),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if ((user?.driverCode ?? '')
                                          .isNotEmpty) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF0F0F0),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            user!.driverCode!,
                                            style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.darkGrey),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Availability toggle ─────────────────────────────
                    ZCCard(
                        child: Row(children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                            color: isOnline
                                ? AppColors.lightGreen
                                : AppColors.lightGrey,
                            borderRadius: BorderRadius.circular(12)),
                        child: Icon(
                          isOnline
                              ? Icons.wifi_rounded
                              : Icons.wifi_off_rounded,
                          size: 22,
                          color: isOnline
                              ? AppColors.primaryGreen
                              : AppColors.warmGrey,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            const Text('Availability',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 14)),
                            Text(
                                isOnline
                                    ? 'You are online and visible to dispatchers'
                                    : 'Go online to receive new jobs',
                                style: const TextStyle(
                                    fontSize: 12, color: AppColors.warmGrey)),
                          ])),
                      Switch(
                        value: isOnline,
                        onChanged: (_) => auth.toggleAvailability(),
                        activeColor: AppColors.primaryGreen,
                      ),
                    ])),
                    // ── Contact & Address ──────────────────────────────
                    _SectionTitle('Contact & Address'),
                    ZCCard(
                      child: Column(
                        children: [
                          _DetailRow(
                            icon: Icons.phone_outlined,
                            label: 'Phone',
                            value: user != null && user.phone.isNotEmpty
                                ? user.phone
                                : '—',
                          ),
                          _DetailRow(
                            icon: Icons.email_outlined,
                            label: 'Email',
                            value: user != null && user.email.isNotEmpty
                                ? user.email
                                : '—',
                          ),
                          _DetailRow(
                            icon: Icons.location_on_outlined,
                            label: 'Address',
                            value: (user?.address ?? '').isNotEmpty
                                ? user!.address!
                                : '—',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Driver details ─────────────────────────────────
                    if (user != null && user.isDriver) ...[
                      _SectionTitle('Driver Details'),
                      ZCCard(
                        child: Column(
                          children: [
                            _DetailRow(
                              icon: Icons.badge_outlined,
                              label: 'Driver Code',
                              value: user.driverCode?.isNotEmpty == true
                                  ? user.driverCode!
                                  : '—',
                            ),
                            _DetailRow(
                              icon: Icons.verified_user_outlined,
                              label: 'Verification',
                              value:
                                  _formatVerification(user.verificationStatus),
                              valueColor:
                                  _verificationColor(user.verificationStatus),
                            ),
                            if ((user.nationalId ?? '').isNotEmpty)
                              _DetailRow(
                                icon: Icons.credit_card_outlined,
                                label: 'National ID',
                                value: user.nationalId!,
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // ── Licence ────────────────────────────────────────
                    if (user != null &&
                        ((user.licenceClass ?? '').isNotEmpty ||
                            (user.licenceNumber ?? '').isNotEmpty)) ...[
                      _SectionTitle('Licence'),
                      ZCCard(
                        child: Column(
                          children: [
                            if ((user.licenceClass ?? '').isNotEmpty)
                              _DetailRow(
                                icon: Icons.drive_eta_outlined,
                                label: 'Class',
                                value: user.licenceClass!,
                              ),
                            if ((user.licenceNumber ?? '').isNotEmpty)
                              _DetailRow(
                                icon: Icons.numbers_outlined,
                                label: 'Licence No.',
                                value: user.licenceNumber!,
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // ── Vehicle ────────────────────────────────────────
                    if ((user?.vehiclePlate ?? '').isNotEmpty ||
                        (user?.vehicleType ?? '').isNotEmpty) ...[
                      _SectionTitle('Assigned Vehicle'),
                      ZCCard(
                        child: Column(
                          children: [
                            if ((user?.vehicleType ?? '').isNotEmpty)
                              _DetailRow(
                                icon: Icons.local_shipping_outlined,
                                label: 'Vehicle',
                                value: user!.vehicleType!,
                              ),
                            if ((user?.vehiclePlate ?? '').isNotEmpty)
                              _DetailRow(
                                icon: Icons.pin_outlined,
                                label: 'Plate',
                                value: user!.vehiclePlate!,
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // ── Support ────────────────────────────────────────
                    _SectionTitle('Support'),
                    _MenuTile(
                        icon: Icons.help_outline_rounded,
                        title: 'Help & Support',
                        onTap: () => _showHelp(context)),
                    _MenuTile(
                        icon: Icons.info_outline_rounded,
                        title: 'About ZConnect',
                        onTap: () => _showAbout(context)),

                    const SizedBox(height: 20),
                    ZCButton(
                      label: 'Sign Out',
                      outlined: true,
                      color: AppColors.error,
                      textColor: AppColors.error,
                      onPressed: () {
                        auth.signOut();
                        Get.offAllNamed(AppRoutes.welcome);
                      },
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  String _formatVerification(String? s) {
    switch (s) {
      case 'verified':
        return 'Verified ✓';
      case 'pending':
        return 'Pending Review';
      case 'rejected':
        return 'Rejected';
      default:
        return 'Unverified';
    }
  }

  Color _verificationColor(String? s) {
    switch (s) {
      case 'verified':
        return AppColors.primaryGreen;
      case 'pending':
        return AppColors.statusPendingText;
      case 'rejected':
        return AppColors.error;
      default:
        return AppColors.warmGrey;
    }
  }

  void _showEditProfile(BuildContext context, AuthController auth) {
    final nameCtrl = TextEditingController(text: auth.currentUser.value?.name);
    final phoneCtrl =
        TextEditingController(text: auth.currentUser.value?.phone);
    final addressCtrl =
        TextEditingController(text: auth.currentUser.value?.address ?? '');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 24, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Edit Profile',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person_outline)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneCtrl,
              decoration: const InputDecoration(
                  labelText: 'Phone', prefixIcon: Icon(Icons.phone_outlined)),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: addressCtrl,
              decoration: const InputDecoration(
                  labelText: 'Address',
                  prefixIcon: Icon(Icons.location_on_outlined)),
            ),
            const SizedBox(height: 24),
            ZCButton(
              label: 'Save Changes',
              onPressed: () async {
                await auth.updateProfile(
                    name: nameCtrl.text.trim(),
                    phone: phoneCtrl.text.trim(),
                    address: addressCtrl.text.trim().isNotEmpty
                        ? addressCtrl.text.trim()
                        : null);
                Navigator.of(ctx).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Help & Support'),
        content: const Text(
            'For support, contact us at support@zconnect.co.zw or call +263 77 123 4567.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text('OK'))
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('About ZConnect'),
        content: const Text(
            'ZConnect is Zimbabwe\'s premier logistics and delivery platform. Version 1.0.0'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text('OK'))
        ],
      ),
    );
  }
}

// ── Supporting widgets ─────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 2),
      child: Text(title,
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.warmGrey,
              letterSpacing: 0.6)),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                color: AppColors.lightGrey,
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 18, color: AppColors.darkGrey),
          ),
          const SizedBox(width: 12),
          Text(label,
              style: const TextStyle(fontSize: 13, color: AppColors.warmGrey)),
          const Spacer(),
          Text(value,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? AppColors.darkGrey)),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile(
      {required this.icon, required this.title, required this.onTap});
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ZCCard(
      margin: const EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          leading: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
                color: AppColors.lightGrey,
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 20, color: AppColors.darkGrey),
          ),
          title: Text(title,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w500)),
          trailing: const Icon(Icons.chevron_right_rounded,
              size: 18, color: AppColors.warmGrey),
          onTap: onTap,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}
