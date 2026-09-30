import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../../../core/app_colors.dart';
import '../../../shared/widgets/zc_widgets.dart';
import '../../../features/shared/services/shipment_repository.dart';
import '../../../features/shared/models/shipment.dart';
import '../../../features/shared/models/enums.dart';

class DriverJobDetailScreen extends StatelessWidget {
  const DriverJobDetailScreen({super.key, required this.shipmentId});
  final String shipmentId;

  @override
  Widget build(BuildContext context) {
    final repo = Get.find<ShipmentRepository>();
    return Obx(() {
      final shipment =
          repo.driverJobs.firstWhereOrNull((s) => s.id == shipmentId);
      if (shipment == null) {
        return Scaffold(
          appBar: AppBar(title: const Text('Job Details')),
          body: const EmptyState(
              icon: Icons.search_off_rounded, title: 'Job not found'),
        );
      }
      return _JobDetailView(shipment: shipment, repo: repo);
    });
  }
}

class _JobDetailView extends StatelessWidget {
  const _JobDetailView({required this.shipment, required this.repo});
  final Shipment shipment;
  final ShipmentRepository repo;

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
                Text('Delivery Progress',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 16),
                ...List.generate(shipment.timeline.length, (i) {
                  final event = shipment.timeline[i];
                  final isLast = i == shipment.timeline.length - 1;
                  return _TLItem(event: event, isLast: isLast);
                }),
              ],
            ),
          ),

          // Route
          ZCCard(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Route', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.radio_button_checked,
                    color: AppColors.primaryGreen, size: 18),
                const SizedBox(width: 8),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text('Pickup',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppColors.warmGrey)),
                      Text(shipment.pickup?.fullAddress ?? '-',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600)),
                    ])),
              ]),
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child:
                    Container(width: 2, height: 20, color: AppColors.divider),
              ),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.location_on_rounded,
                    color: AppColors.error, size: 18),
                const SizedBox(width: 8),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text('Destination',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppColors.warmGrey)),
                      Text(shipment.destination?.fullAddress ?? '-',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600)),
                    ])),
              ]),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    // Combine pickup and destination for Google Maps directions
                    final origin =
                        Uri.encodeComponent(shipment.pickup?.fullAddress ?? '');
                    final dest = Uri.encodeComponent(
                        shipment.destination?.fullAddress ?? '');
                    // We can use the Maps directions API format
                    final url = Uri.parse(
                        'https://www.google.com/maps/dir/?api=1&origin=$origin&destination=$dest');
                    try {
                      final launched = await launchUrl(url,
                          mode: LaunchMode.externalApplication);
                      if (!launched)
                        throw Exception('Could not launch Google Maps');
                    } catch (e) {
                      Get.snackbar(
                          'Error', 'Could not open Google Maps navigation.',
                          backgroundColor: AppColors.error,
                          colorText: Colors.white);
                    }
                  },
                  icon: const Icon(Icons.navigation_rounded,
                      size: 18, color: Colors.white),
                  label: const Text('Start Navigation',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ]),
          ),

          // Parcel info
          ZCCard(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Parcel Details',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              InfoRow(
                  label: 'Category',
                  value: shipment.parcelCategory?.label ?? '-'),
              InfoRow(
                  label: 'Weight',
                  value: '${shipment.weightKg?.toStringAsFixed(1) ?? "-"} kg'),
              InfoRow(
                  label: 'Vehicle', value: shipment.vehicleType?.label ?? '-'),
              InfoRow(label: 'Payment', value: shipment.paymentMethod.label),
              InfoRow(
                  label: 'Est. Price',
                  value: 'USD ${shipment.estimatedPrice.toStringAsFixed(2)}'),
              if (shipment.specialInstructions != null &&
                  shipment.specialInstructions!.isNotEmpty)
                InfoRow(
                    label: 'Instructions',
                    value: shipment.specialInstructions!),
            ]),
          ),

          // Customer contact
          ZCCard(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Customer & Recipient',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              InfoRow(
                  label: 'Sender',
                  value: shipment.senderName.isNotEmpty
                      ? shipment.senderName
                      : 'N/A'),
              InfoRow(
                  label: 'Sender Phone',
                  value: shipment.senderPhone.isNotEmpty
                      ? shipment.senderPhone
                      : 'N/A'),
              InfoRow(label: 'Recipient', value: shipment.recipientName),
              InfoRow(label: 'Recipient Phone', value: shipment.recipientPhone),
              InfoRow(label: 'Created', value: df.format(shipment.createdAt)),
            ]),
          ),

          // Actions
          _ActionPanel(shipment: shipment, repo: repo),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _ActionPanel extends StatelessWidget {
  const _ActionPanel({required this.shipment, required this.repo});
  final Shipment shipment;
  final ShipmentRepository repo;

  @override
  Widget build(BuildContext context) {
    final nextAction = _nextAction(shipment.status);
    if (nextAction == null) return const SizedBox();

    return ZCCard(
      color: AppColors.lightGreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Actions',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: AppColors.primaryGreen)),
          const SizedBox(height: 12),
          Text(nextAction.hint,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.darkGreen)),
          const SizedBox(height: 12),
          ZCButton(
            label: nextAction.label,
            icon: nextAction.icon,
            onPressed: () => _confirm(context, nextAction),
          ),
        ],
      ),
    );
  }

  _DriverAction? _nextAction(ShipmentStatus status) {
    switch (status) {
      case ShipmentStatus.pending:
        return _DriverAction(
          label: 'Accept Job',
          icon: Icons.check_circle_outline_rounded,
          hint: 'Tap to accept this delivery job.',
          next: ShipmentStatus.assigned,
        );
      case ShipmentStatus.assigned:
        return _DriverAction(
          label: 'Arrived at Pickup',
          icon: Icons.location_on_rounded,
          hint: 'Confirm you have arrived at the pickup location.',
          next: ShipmentStatus.pickedUp,
        );
      case ShipmentStatus.pickedUp:
        return _DriverAction(
          label: 'Start Delivery',
          icon: Icons.local_shipping_rounded,
          hint: 'Confirm parcel has been collected and you are on your way.',
          next: ShipmentStatus.inTransit,
        );
      case ShipmentStatus.inTransit:
        return _DriverAction(
          label: 'Mark as Delivered',
          icon: Icons.check_circle_rounded,
          hint: 'Confirm you have delivered the parcel to the recipient.',
          next: ShipmentStatus.delivered,
        );
      default:
        return null;
    }
  }

  void _confirm(BuildContext context, _DriverAction action) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(action.label),
        content: Text('${action.hint}'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (action.next == ShipmentStatus.delivered) {
                repo.submitPod(
                  shipment.id,
                  recipientName: shipment.recipientName,
                  recipientPhone: shipment.recipientPhone,
                  deliveryNotes: 'Delivered by driver via app',
                );
              } else {
                repo.updateShipmentStatus(shipment.id, action.next);
              }
              Get.snackbar(
                'Updated',
                'Status changed to ${action.next.label}',
                backgroundColor: AppColors.lightGreen,
                colorText: AppColors.darkGreen,
                snackPosition: SnackPosition.BOTTOM,
                margin: const EdgeInsets.all(16),
                borderRadius: 12,
              );
            },
            style: ElevatedButton.styleFrom(
                minimumSize: Size.zero,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}

class _DriverAction {
  final String label;
  final IconData icon;
  final String hint;
  final ShipmentStatus next;
  const _DriverAction(
      {required this.label,
      required this.icon,
      required this.hint,
      required this.next});
}

class _TLItem extends StatelessWidget {
  const _TLItem({required this.event, required this.isLast});
  final TimelineEvent event;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    Color dotColor = event.isActive
        ? AppColors.primaryGreen
        : (event.isCompleted ? AppColors.darkGreen : AppColors.divider);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(children: [
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
                : null,
          ),
          if (!isLast)
            Container(width: 2, height: 44, color: AppColors.divider),
        ]),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
              Text(event.description,
                  style: Theme.of(context).textTheme.bodySmall),
            ]),
          ),
        ),
      ],
    );
  }
}
