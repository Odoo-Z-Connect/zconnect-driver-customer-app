import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/app_colors.dart';
import '../../../shared/widgets/zc_widgets.dart';
import '../../../features/shared/services/shipment_repository.dart';
import '../../../features/shared/models/shipment.dart';
import '../../../features/shared/models/enums.dart';
import '../../../routes/app_routes.dart';
import 'shipment_detail_screen.dart';

class CustomerShipmentsScreen extends StatefulWidget {
  const CustomerShipmentsScreen({super.key});

  @override
  State<CustomerShipmentsScreen> createState() =>
      _CustomerShipmentsScreenState();
}

class _CustomerShipmentsScreenState extends State<CustomerShipmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  static const _tabs = [
    'All',
    'Pending',
    'In Transit',
    'Delivered',
    'Cancelled'
  ];
  static const _tabStatuses = <ShipmentStatus?>[
    null,
    ShipmentStatus.pending,
    ShipmentStatus.inTransit,
    ShipmentStatus.delivered,
    ShipmentStatus.cancelled,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Shipment> _filtered(ShipmentRepository repo, ShipmentStatus? status) {
    if (_searchQuery.isNotEmpty) return repo.search(_searchQuery);
    return repo.getByStatus(status);
  }

  @override
  Widget build(BuildContext context) {
    final repo = Get.find<ShipmentRepository>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Shipments'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            color: AppColors.primaryGreen,
            onPressed: () => Get.toNamed(AppRoutes.newShipment),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(44),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: AppColors.primaryGreen,
            labelColor: AppColors.primaryGreen,
            unselectedLabelColor: AppColors.warmGrey,
            labelStyle:
                const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            tabs: _tabs.map((t) => Tab(text: t)).toList(),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search by tracking no. or destination…',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: List.generate(_tabs.length, (i) {
                return Obx(() {
                  final list = _filtered(repo, _tabStatuses[i]);
                  if (list.isEmpty) {
                    return EmptyState(
                      icon: Icons.inventory_2_outlined,
                      title: 'No shipments',
                      subtitle: 'Nothing matches this filter',
                      action: i == 0 ? 'Send a parcel' : null,
                      onAction: i == 0
                          ? () => Get.toNamed(AppRoutes.newShipment)
                          : null,
                    );
                  }
                  return ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    itemCount: list.length,
                    itemBuilder: (_, idx) =>
                        _ShipmentListCard(shipment: list[idx]),
                  );
                });
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShipmentListCard extends StatelessWidget {
  const _ShipmentListCard({required this.shipment});
  final Shipment shipment;

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('d MMM');
    return ZCCard(
      child: InkWell(
        onTap: () =>
            Get.to(() => ShipmentDetailScreen(shipmentId: shipment.id)),
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
                  Row(
                    children: [
                      Text(shipment.trackingNumber,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700)),
                      const Spacer(),
                      StatusChip(status: shipment.status, fontSize: 10),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${shipment.pickup?.name ?? "?"} → ${shipment.destination?.name ?? "?"}',
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${shipment.parcelCategory?.label ?? "Parcel"} · ${df.format(shipment.createdAt)} · USD ${shipment.estimatedPrice.toStringAsFixed(2)}',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.warmGrey),
                  ),
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
