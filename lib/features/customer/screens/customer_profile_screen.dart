import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/app_colors.dart';
import '../../../shared/widgets/zc_widgets.dart';
import '../../../features/auth/controllers/auth_controller.dart';
import '../../../routes/app_routes.dart';

class CustomerProfileScreen extends StatelessWidget {
  const CustomerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
          title: const Text('Profile'), automaticallyImplyLeading: false),
      body: Obx(() {
        final user = auth.currentUser.value;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Avatar card
            ZCCard(
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.lightGreen,
                      borderRadius: BorderRadius.circular(18),
                      border:
                          Border.all(color: AppColors.primaryGreen, width: 2),
                    ),
                    child: const Icon(Icons.person_rounded,
                        size: 32, color: AppColors.primaryGreen),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user?.name ?? 'Customer',
                            style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 2),
                        Text(user?.email ?? '',
                            style: Theme.of(context).textTheme.bodySmall),
                        Text(user?.phone ?? '',
                            style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined,
                        size: 20, color: AppColors.primaryGreen),
                    onPressed: () => _showEditProfile(context, auth),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),
            _SectionTitle('Account'),
            _MenuTile(
                icon: Icons.location_on_outlined,
                title: 'Saved Addresses',
                onTap: () => _showSavedAddresses(context)),
            _MenuTile(
                icon: Icons.notifications_outlined,
                title: 'Notification Preferences',
                onTap: () => _showNotifications(context)),

            const SizedBox(height: 8),
            _SectionTitle('Support'),
            _MenuTile(
                icon: Icons.help_outline_rounded,
                title: 'Help & Support',
                onTap: () => _showHelp(context)),
            _MenuTile(
                icon: Icons.info_outline_rounded,
                title: 'About ZConnect',
                onTap: () => _showAbout(context)),

            const SizedBox(height: 24),
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
            const SizedBox(height: 24),
          ],
        );
      }),
    );
  }

  void _showEditProfile(BuildContext context, AuthController auth) {
    final nameCtrl = TextEditingController(text: auth.currentUser.value?.name);
    final phoneCtrl =
        TextEditingController(text: auth.currentUser.value?.phone);
    final addressCtrl =
        TextEditingController(text: auth.currentUser.value?.address);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Edit Profile', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 20),
            ZCTextField(
                label: 'Full Name',
                controller: nameCtrl,
                prefixIcon: const Icon(Icons.person_outline_rounded)),
            const SizedBox(height: 14),
            ZCTextField(
                label: 'Phone',
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                prefixIcon: const Icon(Icons.phone_outlined)),
            const SizedBox(height: 14),
            ZCTextField(
                label: 'Address',
                controller: addressCtrl,
                prefixIcon: const Icon(Icons.location_on_outlined)),
            const SizedBox(height: 20),
            ZCButton(
              label: 'Save Changes',
              onPressed: () {
                auth.updateProfile(
                  name: nameCtrl.text.trim(),
                  phone: phoneCtrl.text.trim(),
                  address: addressCtrl.text.trim(),
                );
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSavedAddresses(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Saved Addresses',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Obx(() {
              final user = Get.find<AuthController>().currentUser.value;
              if (user?.address != null && user!.address!.isNotEmpty) {
                return _addressTile(
                    context, Icons.home_rounded, 'Home', user.address!);
              }
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text('No saved addresses yet',
                      style: TextStyle(color: AppColors.warmGrey)),
                ),
              );
            }),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _showEditProfile(context, Get.find<AuthController>());
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Address'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _addressTile(
      BuildContext context, IconData icon, String label, String address) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
            color: AppColors.lightGreen,
            borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: AppColors.primaryGreen, size: 20),
      ),
      title: Text(label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      subtitle: Text(address, style: const TextStyle(fontSize: 12)),
    );
  }

  void _showNotifications(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Notification Preferences'),
        content: const Text(
            'Notification settings will be configurable in a future update.\n\nCurrently all notifications are enabled by default.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text('OK'))
        ],
      ),
    );
  }

  void _showHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Help & Support'),
        content: const Text(
            '📞 +263 77 000 0000\n📧 support@zconnect.app\n\nSupport hours: Mon–Fri, 8am–6pm'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'))
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'ZConnect',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
            color: AppColors.primaryGreen,
            borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.local_shipping_rounded,
            color: AppColors.white, size: 28),
      ),
      children: const [
        Text('ZConnect is a modern parcel delivery and logistics app.'),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6, top: 4),
      child: Text(title,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.warmGrey,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8)),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile(
      {required this.icon,
      required this.title,
      required this.onTap,
      this.trailing});
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Widget? trailing;

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
          trailing: trailing ??
              const Icon(Icons.chevron_right_rounded,
                  size: 18, color: AppColors.warmGrey),
          onTap: onTap,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}
