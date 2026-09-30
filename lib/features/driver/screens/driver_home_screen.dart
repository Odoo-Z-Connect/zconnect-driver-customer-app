import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/app_colors.dart';
import '../../../shared/widgets/zc_widgets.dart';
import '../../../features/auth/controllers/auth_controller.dart';
import '../../../features/shared/services/shipment_repository.dart';
import '../../../features/shared/models/shipment.dart';
import '../../../features/shared/models/enums.dart';
import 'driver_job_detail_screen.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});
  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  void _showJobNotifications(BuildContext context, ShipmentRepository repo,
      List<Shipment> offeredJobs) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(builder: (ctx, setS) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: offeredJobs.isEmpty ? 0.3 : 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.2,
          builder: (_, scrollController) => Column(children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(children: [
                Text('New Job Offers',
                    style: Theme.of(context).textTheme.titleLarge),
                const Spacer(),
                if (offeredJobs.isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20)),
                    child: Text('${offeredJobs.length} pending',
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.error,
                            fontWeight: FontWeight.w600)),
                  ),
              ]),
            ),
            const SizedBox(height: 12),
            if (offeredJobs.isEmpty)
              Expanded(
                child: Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.notifications_none_rounded,
                        size: 48, color: Colors.grey[300]),
                    const SizedBox(height: 12),
                    Text('No pending job offers',
                        style: TextStyle(color: Colors.grey[500])),
                  ]),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: offeredJobs.length,
                  itemBuilder: (_, i) {
                    final job = offeredJobs[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                      color: AppColors.lightGreen,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: const Icon(Icons.inventory_2_rounded,
                                      color: AppColors.primaryGreen, size: 18),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(job.trackingNumber,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 14)),
                                        Text(
                                            '${job.parcelCategory?.label ?? "Parcel"} · ${job.weightKg?.toStringAsFixed(1) ?? "-"} kg',
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: AppColors.warmGrey)),
                                      ]),
                                ),
                                Text(
                                  'USD ${job.estimatedPrice.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primaryGreen),
                                ),
                              ]),
                              const SizedBox(height: 10),
                              Row(children: [
                                const Icon(Icons.radio_button_checked,
                                    size: 12, color: AppColors.primaryGreen),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    job.pickup?.address ??
                                        job.pickup?.name ??
                                        '-',
                                    style: const TextStyle(fontSize: 11),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ]),
                              const SizedBox(height: 2),
                              Row(children: [
                                const Icon(Icons.location_on_rounded,
                                    size: 12, color: AppColors.error),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    job.destination?.address ??
                                        job.destination?.name ??
                                        '-',
                                    style: const TextStyle(fontSize: 11),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ]),
                              const SizedBox(height: 12),
                              Row(children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () async {
                                      Navigator.pop(ctx);
                                      await repo.rejectAssignment(
                                          job.assignmentId!,
                                          'Not available right now');
                                      Get.snackbar('Job Declined',
                                          'You declined ${job.trackingNumber}',
                                          snackPosition: SnackPosition.BOTTOM,
                                          backgroundColor: Colors.red[50]);
                                    },
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.error,
                                      side: const BorderSide(
                                          color: AppColors.error),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                    ),
                                    child: const Text('Decline'),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      Navigator.pop(ctx);
                                      await repo.acceptAssignment(
                                          job.assignmentId!, job.id);
                                      Get.snackbar('Job Accepted',
                                          'You accepted ${job.trackingNumber}',
                                          snackPosition: SnackPosition.BOTTOM,
                                          backgroundColor: Colors.green[50]);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryGreen,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                    ),
                                    child: const Text('Accept'),
                                  ),
                                ),
                              ]),
                            ]),
                      ),
                    );
                  },
                ),
              ),
          ]),
        );
      }),
    );
  }

  @override
  void initState() {
    super.initState();
    // Always refresh jobs when screen is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<ShipmentRepository>().fetchShipments();
    });
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
          onRefresh: () => repo.fetchShipments(),
          child: CustomScrollView(
            slivers: [
              // ── Header ──────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                                color: AppColors.lightGreen,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                    color: AppColors.primaryGreen, width: 1.5)),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                'assets/images/zconnect_ecosystem.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Obx(() {
                              final user = auth.currentUser.value;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_greeting(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                              color: AppColors.warmGrey)),
                                  Text(user?.name ?? 'Driver',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium,
                                      overflow: TextOverflow.ellipsis),
                                ],
                              );
                            }),
                          ),
                          // Availability toggle
                          Obx(() {
                            final user = auth.currentUser.value;
                            final isOnline =
                                user?.availability == DriverAvailability.online;
                            return GestureDetector(
                              onTap: () => auth.toggleAvailability(),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isOnline
                                      ? AppColors.lightGreen
                                      : AppColors.lightGrey,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: isOnline
                                          ? AppColors.primaryGreen
                                          : AppColors.divider),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: isOnline
                                            ? AppColors.primaryGreen
                                            : AppColors.warmGrey,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(isOnline ? 'Online' : 'Offline',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: isOnline
                                                ? AppColors.primaryGreen
                                                : AppColors.warmGrey)),
                                  ],
                                ),
                              ),
                            );
                          }),
                          const SizedBox(width: 12),
                          Obx(() {
                            final offered = repo.driverJobs
                                .where((s) => s.assignmentState == 'offered')
                                .toList();
                            final count = offered.length;
                            return GestureDetector(
                              onTap: () =>
                                  _showJobNotifications(context, repo, offered),
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.lightGrey,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    const Icon(Icons.notifications_none_rounded,
                                        color: AppColors.darkGrey),
                                    if (count > 0)
                                      Positioned(
                                        top: 6,
                                        right: 6,
                                        child: Container(
                                          padding: const EdgeInsets.all(3),
                                          decoration: const BoxDecoration(
                                            color: AppColors.error,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Text(
                                            '$count',
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // ── Stats ──────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Obx(() {
                    final jobs = repo.driverJobs;
                    // Count by assignmentState (what server returns)
                    final offered = jobs
                        .where((s) => s.assignmentState == 'offered')
                        .length;
                    final accepted = jobs
                        .where((s) => s.assignmentState == 'accepted')
                        .length;
                    final done = jobs
                        .where((s) => s.assignmentState == 'completed')
                        .length;
                    return GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.15,
                      children: [
                        StatCard(
                            label: 'Assigned Jobs',
                            value: '${jobs.length}',
                            icon: Icons.work_rounded,
                            color: AppColors.primaryGreen,
                            iconBg: AppColors.lightGreen),
                        StatCard(
                            label: 'Pending Pickup',
                            value: '$offered',
                            icon: Icons.schedule_rounded,
                            color: AppColors.statusPendingText,
                            iconBg: AppColors.statusPending),
                        StatCard(
                            label: 'Active Deliveries',
                            value: '$accepted',
                            icon: Icons.local_shipping_rounded,
                            color: AppColors.statusInTransitText,
                            iconBg: AppColors.statusInTransit),
                        StatCard(
                            label: 'Completed',
                            value: '$done',
                            icon: Icons.check_circle_rounded,
                            color: AppColors.statusDeliveredText,
                            iconBg: AppColors.statusDelivered),
                      ],
                    );
                  }),
                ),
              ),

              // ── Active Jobs ─────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                  child: SectionHeader(title: 'Assigned Jobs'),
                ),
              ),

              Obx(() {
                final active = repo.driverJobs
                    .where((s) =>
                        s.status != ShipmentStatus.delivered &&
                        s.status != ShipmentStatus.cancelled)
                    .toList();
                if (active.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: EmptyState(
                        icon: Icons.work_off_rounded,
                        title: 'No active jobs',
                        subtitle:
                            'New job requests will appear here when you\'re online',
                      ),
                    ),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _DriverJobCard(shipment: active[i]),
                    ),
                    childCount: active.length,
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

class _DriverJobCard extends StatelessWidget {
  const _DriverJobCard({required this.shipment});
  final Shipment shipment;

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('d MMM, HH:mm');
    return ZCCard(
      child: InkWell(
        onTap: () =>
            Get.to(() => DriverJobDetailScreen(shipmentId: shipment.id)),
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
                          '${shipment.parcelCategory?.label ?? "Parcel"} · ${shipment.vehicleType?.label ?? "-"}',
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                StatusChip(status: shipment.status, fontSize: 10),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),
            Row(children: [
              const Icon(Icons.radio_button_checked,
                  size: 13, color: AppColors.primaryGreen),
              const SizedBox(width: 4),
              Expanded(
                  child: Text(shipment.pickup?.name ?? '-',
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis)),
              const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(Icons.arrow_forward_rounded,
                      size: 13, color: AppColors.warmGrey)),
              const Icon(Icons.location_on_rounded,
                  size: 13, color: AppColors.error),
              const SizedBox(width: 4),
              Expanded(
                  child: Text(shipment.destination?.name ?? '-',
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis)),
            ]),
            const SizedBox(height: 6),
            Row(children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 12, color: AppColors.warmGrey),
              const SizedBox(width: 4),
              Text(df.format(shipment.createdAt),
                  style: Theme.of(context).textTheme.bodySmall),
              const Spacer(),
              Text('USD ${shipment.estimatedPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryGreen)),
            ]),
          ],
        ),
      ),
    );
  }
}
