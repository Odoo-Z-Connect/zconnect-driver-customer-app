import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/app_colors.dart';
import '../../../shared/widgets/zc_widgets.dart';
import '../../../features/shared/services/shipment_repository.dart';
import 'shipment_detail_screen.dart';

class CustomerTrackScreen extends StatefulWidget {
  const CustomerTrackScreen({super.key});

  @override
  State<CustomerTrackScreen> createState() => _CustomerTrackScreenState();
}

class _CustomerTrackScreenState extends State<CustomerTrackScreen> {
  final _ctrl = TextEditingController();
  bool _searched = false;
  dynamic _result; // Shipment or null

  void _track() {
    final repo = Get.find<ShipmentRepository>();
    final q = _ctrl.text.trim();
    if (q.isEmpty) return;
    setState(() {
      _searched = true;
      _result = repo.findByTracking(q);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
          title: const Text('Track Parcel'), automaticallyImplyLeading: false),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Enter Tracking Number',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            Text('Enter your ZConnect tracking number (e.g. ZC-284710)',
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      hintText: 'ZC-XXXXXX',
                      prefixIcon: Icon(Icons.radar_rounded,
                          color: AppColors.primaryGreen),
                    ),
                    onSubmitted: (_) => _track(),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _track,
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Track'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Demo hint
            Wrap(
              spacing: 8,
              children: ['ZC-284710', 'ZC-193045', 'ZC-502819']
                  .map((n) => ActionChip(
                        label: Text(n, style: const TextStyle(fontSize: 11)),
                        onPressed: () {
                          _ctrl.text = n;
                          _track();
                        },
                        backgroundColor: AppColors.lightGreen,
                        side: BorderSide.none,
                      ))
                  .toList(),
            ),
            const SizedBox(height: 24),
            if (_searched) ...[
              if (_result == null)
                EmptyState(
                  icon: Icons.search_off_rounded,
                  title: 'Not found',
                  subtitle:
                      'No shipment with tracking number "${_ctrl.text.trim()}"',
                )
              else
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Result',
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 12),
                        ZCCard(
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                  color: AppColors.lightGreen,
                                  borderRadius: BorderRadius.circular(12)),
                              child: const Icon(Icons.inventory_2_rounded,
                                  color: AppColors.primaryGreen),
                            ),
                            title: Text(_result.trackingNumber,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700)),
                            subtitle: Text(
                                '${_result.pickup?.name ?? "?"} → ${_result.destination?.name ?? "?"}'),
                            trailing: StatusChip(status: _result.status),
                            onTap: () => Get.to(() =>
                                ShipmentDetailScreen(shipmentId: _result.id)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ZCButton(
                          label: 'View Full Details',
                          onPressed: () => Get.to(() =>
                              ShipmentDetailScreen(shipmentId: _result.id)),
                        ),
                      ],
                    ),
                  ),
                ),
            ] else
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.radar_rounded,
                          size: 64,
                          color: AppColors.primaryGreen.withValues(alpha: 0.3)),
                      const SizedBox(height: 16),
                      Text('Enter a tracking number above',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: AppColors.warmGrey)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
