import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/app_colors.dart';
import '../../../shared/widgets/zc_widgets.dart';
import '../../../features/auth/controllers/auth_controller.dart';
import '../../../features/shared/services/shipment_repository.dart';
import '../../../features/shared/models/shipment.dart';
import '../../../features/shared/models/enums.dart';
import '../../../routes/app_routes.dart';
import 'shipment_detail_screen.dart';

class CustomerHomeScreen extends StatelessWidget {
  const CustomerHomeScreen({super.key});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final repo = Get.find<ShipmentRepository>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primaryGreen,
          onRefresh: () async =>
              await Future.delayed(const Duration(milliseconds: 600)),
          child: CustomScrollView(
            slivers: [
              // ── Header ──────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Obx(() {
                              final user = auth.currentUser.value;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_greeting(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                              color: AppColors.warmGrey)),
                                  const SizedBox(height: 2),
                                  Text(
                                    user?.name ?? 'Customer',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineLarge,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              );
                            }),
                          ),
                          const SizedBox(width: 12),
                          // Notification
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                                color: AppColors.lightGrey,
                                borderRadius: BorderRadius.circular(12)),
                            child: IconButton(
                              icon: const Icon(Icons.notifications_outlined,
                                  size: 22),
                              onPressed: () {},
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Avatar
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: AppColors.lightGreen,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: AppColors.primaryGreen, width: 1.5),
                            ),
                            child: const Icon(Icons.person_rounded,
                                color: AppColors.primaryGreen, size: 22),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // CTA
                      GestureDetector(
                        onTap: () => Get.toNamed(AppRoutes.newShipment),
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.primaryGreen,
                                AppColors.darkGreen
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Send a Parcel',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineLarge
                                            ?.copyWith(color: AppColors.white)),
                                    const SizedBox(height: 4),
                                    Text('Request a shipment in minutes',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                                color: AppColors.white
                                                    .withValues(alpha: 0.8))),
                                  ],
                                ),
                              ),
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                    color:
                                        AppColors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(14)),
                                child: const Icon(Icons.add_rounded,
                                    color: AppColors.white, size: 28),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Stats ────────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Obx(() {
                    return GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.15,
                      children: [
                        StatCard(
                          label: 'Total Shipments',
                          value: '${repo.totalShipments}',
                          icon: Icons.inventory_2_rounded,
                          color: AppColors.primaryGreen,
                          iconBg: AppColors.lightGreen,
                        ),
                        StatCard(
                          label: 'In Transit',
                          value: '${repo.inTransitCount}',
                          icon: Icons.local_shipping_rounded,
                          color: const Color(0xFF004085),
                          iconBg: AppColors.statusInTransit,
                        ),
                        StatCard(
                          label: 'Delivered',
                          value: '${repo.deliveredCount}',
                          icon: Icons.check_circle_rounded,
                          color: const Color(0xFF155724),
                          iconBg: AppColors.statusDelivered,
                        ),
                        StatCard(
                          label: 'Pending',
                          value: '${repo.pendingCount}',
                          icon: Icons.schedule_rounded,
                          color: const Color(0xFF856404),
                          iconBg: AppColors.statusPending,
                        ),
                      ],
                    );
                  }),
                ),
              ),

              // ── Recent shipments ─────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                  child: SectionHeader(
                    title: 'Recent Shipments',
                    action: 'See all',
                    onAction: () {
                      // The shell's tab controller is in CustomerShell — navigate there
                      // by replacing with the shell and jumping to tab 1
                      Get.toNamed(AppRoutes.customerShipments);
                    },
                  ),
                ),
              ),

              Obx(() {
                final recent = repo.shipments.take(4).toList();
                if (recent.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: EmptyState(
                        icon: Icons.inventory_2_outlined,
                        title: 'No shipments yet',
                        subtitle: 'Your shipments will appear here',
                        action: 'Send a parcel',
                        onAction: () => Get.toNamed(AppRoutes.newShipment),
                      ),
                    ),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _ShipmentCard(shipment: recent[i]),
                    ),
                    childCount: recent.length,
                  ),
                );
              }),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShipmentCard extends StatelessWidget {
  const _ShipmentCard({required this.shipment});
  final Shipment shipment;

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('d MMM yyyy');
    return ZCCard(
      child: InkWell(
        onTap: () =>
            Get.to(() => ShipmentDetailScreen(shipmentId: shipment.id)),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                      color: AppColors.lightGreen,
                      borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.inventory_2_rounded,
                      color: AppColors.primaryGreen, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(shipment.trackingNumber,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700)),
                      Text(
                        '${shipment.parcelCategory?.label ?? "Parcel"} · ${shipment.weightKg?.toStringAsFixed(1) ?? "-"} kg',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                StatusChip(status: shipment.status),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            _routeRow(context),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 13, color: AppColors.warmGrey),
                const SizedBox(width: 4),
                Text(df.format(shipment.createdAt),
                    style: Theme.of(context).textTheme.bodySmall),
                const Spacer(),
                Text(
                  'USD ${shipment.estimatedPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryGreen),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _routeRow(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.radio_button_checked,
            size: 14, color: AppColors.primaryGreen),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            shipment.pickup?.name ?? 'Pickup location',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.darkGrey),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Icon(Icons.arrow_forward_rounded,
              size: 14, color: AppColors.warmGrey),
        ),
        const Icon(Icons.location_on_rounded, size: 14, color: AppColors.error),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            shipment.destination?.name ?? 'Destination',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.darkGrey),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
