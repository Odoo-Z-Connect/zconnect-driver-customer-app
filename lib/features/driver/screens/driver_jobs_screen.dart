import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/app_colors.dart';
import '../../../shared/widgets/zc_widgets.dart';
import '../../../features/shared/services/shipment_repository.dart';
import '../../../features/shared/models/shipment.dart';
import '../../../features/shared/models/enums.dart';
import 'driver_job_detail_screen.dart';

/// Active job list tab
class DriverJobsScreen extends StatelessWidget {
  const DriverJobsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = Get.find<ShipmentRepository>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
          title: const Text('My Jobs'), automaticallyImplyLeading: false),
      body: Obx(() {
        final jobs = repo.driverJobs
            .where((s) =>
                s.status != ShipmentStatus.delivered &&
                s.status != ShipmentStatus.cancelled)
            .toList();
        if (jobs.isEmpty) {
          return const EmptyState(
            icon: Icons.work_off_rounded,
            title: 'No active jobs',
            subtitle: 'Jobs assigned to you will appear here',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: jobs.length,
          itemBuilder: (_, i) => _JobCard(shipment: jobs[i]),
        );
      }),
    );
  }
}

/// History tab
class DriverJobsHistoryScreen extends StatelessWidget {
  const DriverJobsHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = Get.find<ShipmentRepository>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
          title: const Text('History'), automaticallyImplyLeading: false),
      body: Obx(() {
        final list =
            repo.driverJobs.isNotEmpty ? repo.driverJobs : repo.shipments;
        final done = list
            .where((s) =>
                s.status == ShipmentStatus.delivered ||
                s.status == ShipmentStatus.cancelled)
            .toList();
        if (done.isEmpty) {
          return const EmptyState(
              icon: Icons.history_rounded,
              title: 'No completed deliveries yet');
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: done.length,
          itemBuilder: (_, i) => _JobCard(shipment: done[i]),
        );
      }),
    );
  }
}

class _JobCard extends StatelessWidget {
  const _JobCard({required this.shipment});
  final Shipment shipment;

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('d MMM');
    return ZCCard(
      child: InkWell(
        onTap: () =>
            Get.to(() => DriverJobDetailScreen(shipmentId: shipment.id)),
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                  color: AppColors.lightGreen,
                  borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.inventory_2_rounded,
                  color: AppColors.primaryGreen, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text(shipment.trackingNumber,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    const Spacer(),
                    StatusChip(status: shipment.status, fontSize: 10),
                  ]),
                  const SizedBox(height: 4),
                  Text(
                      '${shipment.pickup?.name ?? "?"} → ${shipment.destination?.name ?? "?"}',
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(
                      '${shipment.parcelCategory?.label ?? "Parcel"} · ${df.format(shipment.createdAt)} · USD ${shipment.estimatedPrice.toStringAsFixed(2)}',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.warmGrey)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, color: AppColors.warmGrey),
          ],
        ),
      ),
    );
  }
}
