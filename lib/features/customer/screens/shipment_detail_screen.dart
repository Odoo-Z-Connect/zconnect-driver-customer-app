import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/app_colors.dart';
import '../../../shared/widgets/zc_widgets.dart';
import '../../../features/shared/services/shipment_repository.dart';
import '../../../features/shared/models/shipment.dart';
import '../../../features/shared/models/enums.dart';

class ShipmentDetailScreen extends StatelessWidget {
  const ShipmentDetailScreen({super.key, required this.shipmentId});
  final String shipmentId;

  @override
  Widget build(BuildContext context) {
    final repo = Get.find<ShipmentRepository>();
    return Obx(() {
      final shipment =
          repo.shipments.firstWhereOrNull((s) => s.id == shipmentId);
      if (shipment == null) {
        return Scaffold(
          appBar: AppBar(title: const Text('Shipment Details')),
          body: const EmptyState(
              icon: Icons.search_off_rounded, title: 'Shipment not found'),
        );
      }
      return _ShipmentDetailView(shipment: shipment);
    });
  }
}

class _ShipmentDetailView extends StatelessWidget {
  const _ShipmentDetailView({required this.shipment});
  final Shipment shipment;

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('d MMM yyyy, HH:mm');
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(shipment.trackingNumber),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Get.back(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: StatusChip(status: shipment.status),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Timeline
          ZCCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tracking Timeline',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 16),
                ...List.generate(shipment.timeline.length, (i) {
                  final event = shipment.timeline[i];
                  final isLast = i == shipment.timeline.length - 1;
                  return _TimelineItem(event: event, isLast: isLast);
                }),
              ],
            ),
          ),

          // Route
          ZCCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Route', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                _locationTile(context, 'Pickup', shipment.pickup,
                    AppColors.primaryGreen, Icons.radio_button_checked),
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child:
                      Container(width: 2, height: 24, color: AppColors.divider),
                ),
                _locationTile(context, 'Destination', shipment.destination,
                    AppColors.error, Icons.location_on_rounded),
                const SizedBox(height: 12),
                // Map placeholder
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.lightGreen,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.primaryGreen.withValues(alpha: 0.3)),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.map_rounded,
                            size: 36, color: AppColors.primaryGreen),
                        const SizedBox(height: 6),
                        Text('Map view (demo placeholder)',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.darkGreen)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Parcel info
          ZCCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Parcel Information',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                InfoRow(
                    label: 'Category',
                    value: shipment.parcelCategory?.label ?? '-'),
                InfoRow(
                    label: 'Weight',
                    value: shipment.weightKg != null
                        ? '${shipment.weightKg!.toStringAsFixed(1)} kg'
                        : '-'),
                InfoRow(
                    label: 'Vehicle',
                    value: shipment.vehicleType?.label ?? '-'),
                if (shipment.specialInstructions != null &&
                    shipment.specialInstructions!.isNotEmpty)
                  InfoRow(
                      label: 'Instructions',
                      value: shipment.specialInstructions!),
              ],
            ),
          ),

          // Contact info
          ZCCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Contact Details',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                InfoRow(label: 'Sender', value: shipment.senderName),
                InfoRow(label: 'Sender Phone', value: shipment.senderPhone),
                InfoRow(label: 'Recipient', value: shipment.recipientName),
                InfoRow(
                    label: 'Recipient Phone', value: shipment.recipientPhone),
              ],
            ),
          ),

          // Driver info (if assigned)
          if (shipment.driverName != null)
            ZCCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Driver',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                            color: AppColors.lightGreen,
                            borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.drive_eta_rounded,
                            color: AppColors.primaryGreen, size: 26),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(shipment.driverName!,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w700)),
                            Text(shipment.driverPhone ?? '-',
                                style: Theme.of(context).textTheme.bodySmall),
                            if (shipment.driverVehiclePlate != null)
                              Text('Plate: ${shipment.driverVehiclePlate}',
                                  style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // Payment
          ZCCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Payment', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                InfoRow(label: 'Method', value: shipment.paymentMethod.label),
                InfoRow(
                  label: 'Estimated Price',
                  value: '',
                  valueWidget: Text(
                    'USD ${shipment.estimatedPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryGreen),
                  ),
                ),
                InfoRow(label: 'Created', value: df.format(shipment.createdAt)),
                if (shipment.estimatedDelivery != null)
                  InfoRow(
                      label: 'Est. Delivery',
                      value: df.format(shipment.estimatedDelivery!)),
              ],
            ),
          ),

          // Support
          ZCCard(
            color: AppColors.lightGreen,
            child: Material(
              color: Colors.transparent,
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                      color: AppColors.primaryGreen,
                      borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.support_agent_rounded,
                      color: AppColors.white, size: 22),
                ),
                title: const Text('Need help?',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Contact ZConnect support',
                    style: TextStyle(fontSize: 12)),
                trailing: const Icon(Icons.chevron_right_rounded,
                    color: AppColors.primaryGreen),
                onTap: () => _showSupportDialog(context),
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _locationTile(BuildContext context, String type, AppLocation? loc,
      Color color, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(type,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.warmGrey)),
              Text(loc?.fullAddress ?? 'Not specified',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }

  void _showSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Support'),
        content: const Text(
            'Support chat and call features will be available in a future update.\n\nDemo mode — no real support is connected.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({required this.event, required this.isLast});
  final TimelineEvent event;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('d MMM, HH:mm');
    Color dotColor;
    if (event.isActive) {
      dotColor = AppColors.primaryGreen;
    } else if (event.isCompleted) {
      dotColor = AppColors.darkGreen;
    } else {
      dotColor = AppColors.divider;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: event.isCompleted || event.isActive
                    ? dotColor
                    : AppColors.white,
                shape: BoxShape.circle,
                border: Border.all(color: dotColor, width: 2),
              ),
              child: event.isCompleted
                  ? const Icon(Icons.check_rounded,
                      size: 10, color: AppColors.white)
                  : event.isActive
                      ? null
                      : null,
            ),
            if (!isLast)
              Container(width: 2, height: 48, color: AppColors.divider),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        event.isActive ? FontWeight.w700 : FontWeight.w500,
                    color: event.isActive
                        ? AppColors.primaryGreen
                        : (event.isCompleted
                            ? AppColors.darkGrey
                            : AppColors.warmGrey),
                  ),
                ),
                const SizedBox(height: 2),
                Text(event.description,
                    style: Theme.of(context).textTheme.bodySmall),
                if (event.time != null) ...[
                  const SizedBox(height: 2),
                  Text(df.format(event.time!),
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(color: AppColors.warmGrey)),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
