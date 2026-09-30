import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/app_colors.dart';
import '../../../shared/widgets/zc_widgets.dart';
import '../../../features/shared/models/shipment.dart';
import '../../../features/shared/models/enums.dart';
import '../../../features/shared/data/mock_data.dart';
import '../../../features/shared/services/pricing_service.dart';
import '../controllers/new_shipment_controller.dart';
import '../../../routes/app_routes.dart';
import 'shipment_detail_screen.dart';
import 'dart:async';
import '../../../features/shared/services/places_service.dart';
import 'map_picker_screen.dart';

class NewShipmentScreen extends StatefulWidget {
  const NewShipmentScreen({super.key});

  @override
  State<NewShipmentScreen> createState() => _NewShipmentScreenState();
}

class _NewShipmentScreenState extends State<NewShipmentScreen> {
  late NewShipmentController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.put(NewShipmentController());
    _ctrl.reset();
  }

  @override
  void dispose() {
    super.dispose();
  }

  static const List<String> _stepTitles = [
    'Locations',
    'Parcel Details',
    'Recipient',
    'Review & Pay',
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final step = _ctrl.step.value;
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(_stepTitles[step]),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () {
              if (step == 0) {
                Get.back();
              } else {
                _ctrl.goBack();
              }
            },
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(6),
            child: LinearProgressIndicator(
              value: (step + 1) / NewShipmentController.totalSteps,
              backgroundColor: AppColors.divider,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
              minHeight: 4,
            ),
          ),
        ),
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: KeyedSubtree(
            key: ValueKey(step),
            child: _buildStep(step),
          ),
        ),
        bottomNavigationBar: _buildBottomBar(step),
      );
    });
  }

  Widget _buildStep(int step) {
    switch (step) {
      case 0:
        return _LocationStep(ctrl: _ctrl);
      case 1:
        return _ParcelStep(ctrl: _ctrl);
      case 2:
        return _RecipientStep(ctrl: _ctrl);
      case 3:
        return _ReviewStep(ctrl: _ctrl);
      default:
        return const SizedBox();
    }
  }

  Widget _buildBottomBar(int step) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        child: Obx(() {
          final canNext = _ctrl.canGoNext;
          if (step == 3) {
            return ZCButton(
              label: 'Confirm Shipment',
              onPressed: canNext ? _submit : null,
              isLoading: _ctrl.isSubmitting.value,
              icon: Icons.check_circle_outline_rounded,
            );
          }
          return ZCButton(
            label: 'Continue',
            onPressed: canNext ? _ctrl.goNext : null,
            icon: Icons.arrow_forward_rounded,
          );
        }),
      ),
    );
  }

  Future<void> _submit() async {
    final shipment = await _ctrl.submit();
    if (shipment != null) {
      Get.off(() => _SuccessScreen(shipment: shipment));
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 1: Locations
// ─────────────────────────────────────────────────────────────────────────────
class _LocationStep extends StatelessWidget {
  const _LocationStep({required this.ctrl});
  final NewShipmentController ctrl;

  void _pickLocation(BuildContext context, bool isPickup) async {
    final title = isPickup ? 'Select Pickup Location' : 'Select Destination';
    final currentLoc = isPickup ? ctrl.pickup.value : ctrl.destination.value;

    final loc = await Get.to<AppLocation>(() => MapPickerScreen(
          title: title,
          initial: currentLoc,
        ));
    if (loc != null) {
      if (isPickup)
        ctrl.pickup.value = loc;
      else
        ctrl.destination.value = loc;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Where from & to?',
            style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 6),
        Text('Select pickup and delivery locations',
            style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 24),

        // Demo notice
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: AppColors.lightGreen,
              borderRadius: BorderRadius.circular(10)),
          child: Row(children: [
            const Icon(Icons.info_outline_rounded,
                size: 16, color: AppColors.darkGreen),
            const SizedBox(width: 8),
            Expanded(
                child: Text(
                    'Accurate location data will be used to estimate pricing and routing.',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.darkGreen))),
          ]),
        ),
        const SizedBox(height: 20),

        Obx(() => _LocationCard(
              label: 'Pickup Location',
              location: ctrl.pickup.value,
              icon: Icons.radio_button_checked,
              color: AppColors.primaryGreen,
              onTap: () => _pickLocation(context, true),
            )),
        const SizedBox(height: 12),

        // Swap button
        Center(
          child: Obx(() {
            final hasLocations =
                ctrl.pickup.value != null && ctrl.destination.value != null;
            return IconButton(
              onPressed: hasLocations
                  ? () {
                      final tmp = ctrl.pickup.value;
                      ctrl.pickup.value = ctrl.destination.value;
                      ctrl.destination.value = tmp;
                    }
                  : null,
              icon: const Icon(Icons.swap_vert_rounded, size: 28),
              color: hasLocations ? AppColors.primaryGreen : AppColors.divider,
              style: IconButton.styleFrom(
                backgroundColor: AppColors.white,
                side: const BorderSide(color: AppColors.divider),
              ),
            );
          }),
        ),
        const SizedBox(height: 12),

        Obx(() => _LocationCard(
              label: 'Destination',
              location: ctrl.destination.value,
              icon: Icons.location_on_rounded,
              color: AppColors.error,
              onTap: () => _pickLocation(context, false),
            )),
      ],
    );
  }
}

class _LocationCard extends StatelessWidget {
  const _LocationCard(
      {required this.label,
      required this.location,
      required this.icon,
      required this.color,
      required this.onTap});
  final String label;
  final AppLocation? location;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: location != null
                ? color.withValues(alpha: 0.5)
                : AppColors.divider,
            width: location != null ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.warmGrey)),
                  const SizedBox(height: 2),
                  Text(
                    location?.fullAddress ?? 'Tap to select',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: location != null
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: location != null
                              ? AppColors.darkGrey
                              : AppColors.warmGrey,
                        ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.warmGrey),
          ],
        ),
      ),
    );
  }
}

class _LocationPicker extends StatefulWidget {
  const _LocationPicker({required this.title});
  final String title;

  @override
  State<_LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<_LocationPicker> {
  final PlacesService _placesService = PlacesService();
  String _query = '';
  List<AppLocation> _results = [];
  bool _isLoading = false;
  Timer? _debounce;

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.isEmpty) {
        setState(() {
          _results = [];
          _isLoading = false;
        });
        return;
      }

      setState(() => _isLoading = true);
      final results = await _placesService.searchPlaces(query);
      setState(() {
        _results = results;
        _isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                            color: AppColors.divider,
                            borderRadius: BorderRadius.circular(2))),
                  ),
                  const SizedBox(height: 16),
                  Text(widget.title,
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text('Search for a location or address',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.warmGrey)),
                  const SizedBox(height: 12),
                  TextField(
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: 'Search location…',
                      prefixIcon: Icon(Icons.search_rounded),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    ),
                    onChanged: _onSearchChanged,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            if (_isLoading)
              const Expanded(
                  child: Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primaryGreen)))
            else
              Expanded(
                child: _results.isEmpty
                    ? const Center(child: Text('No locations found'))
                    : ListView.builder(
                        controller: scrollCtrl,
                        itemCount: _results.length,
                        itemBuilder: (_, i) {
                          final loc = _results[i];
                          return ListTile(
                            leading: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                  color: AppColors.lightGreen,
                                  borderRadius: BorderRadius.circular(10)),
                              child: const Icon(Icons.location_on_rounded,
                                  color: AppColors.primaryGreen, size: 20),
                            ),
                            title: Text(loc.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 14)),
                            subtitle: Text(
                                '${loc.address}${loc.city.isNotEmpty ? ', ' + loc.city : ''}',
                                style: const TextStyle(fontSize: 12)),
                            onTap: () async {
                              // show loading overlay while fetching details if needed
                              final details =
                                  await _placesService.getPlaceDetails(loc);
                              Navigator.pop(context, details ?? loc);
                            },
                          );
                        },
                      ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 2: Parcel details
// ─────────────────────────────────────────────────────────────────────────────
class _ParcelStep extends StatefulWidget {
  const _ParcelStep({required this.ctrl});
  final NewShipmentController ctrl;

  @override
  State<_ParcelStep> createState() => _ParcelStepState();
}

class _ParcelStepState extends State<_ParcelStep> {
  final _instructCtrl = TextEditingController();

  static const _weightOptions = [0.1, 0.5, 1.0, 2.0, 5.0, 10.0, 15.0, 30.0];
  static const _categories = ParcelCategory.values;
  static const _vehicles = VehicleType.values;

  @override
  void dispose() {
    _instructCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Parcel Details',
            style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 6),
        Text('Describe your parcel',
            style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 24),

        // Category
        Text('Parcel Category', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        Obx(() => Column(
              children: _categories.map((cat) {
                final selected = widget.ctrl.parcelCategory.value == cat;
                return GestureDetector(
                  onTap: () => widget.ctrl.parcelCategory.value = cat,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.lightGreen : AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: selected
                              ? AppColors.primaryGreen
                              : AppColors.divider,
                          width: selected ? 1.8 : 1),
                    ),
                    child: Row(
                      children: [
                        Icon(_categoryIcon(cat),
                            color: selected
                                ? AppColors.primaryGreen
                                : AppColors.warmGrey,
                            size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(cat.label,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: selected
                                            ? AppColors.primaryGreen
                                            : AppColors.darkGrey)),
                                Text(cat.description,
                                    style:
                                        Theme.of(context).textTheme.bodySmall),
                              ]),
                        ),
                        if (selected)
                          const Icon(Icons.check_circle_rounded,
                              color: AppColors.primaryGreen, size: 20),
                      ],
                    ),
                  ),
                );
              }).toList(),
            )),

        const SizedBox(height: 20),

        // Weight
        Text('Weight (kg)', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        Obx(() => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _weightOptions.map((w) {
                final selected = (widget.ctrl.weightKg.value - w).abs() < 0.001;
                return ChoiceChip(
                  label: Text(
                      '${w < 1 ? w.toStringAsFixed(1) : w.toStringAsFixed(0)} kg'),
                  selected: selected,
                  selectedColor: AppColors.lightGreen,
                  onSelected: (_) => widget.ctrl.weightKg.value = w,
                  side: selected
                      ? const BorderSide(color: AppColors.primaryGreen)
                      : null,
                );
              }).toList(),
            )),

        const SizedBox(height: 20),

        // Vehicle
        Text('Vehicle Type', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        Obx(() => Row(
              children: _vehicles.map((v) {
                final selected = widget.ctrl.vehicleType.value == v;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => widget.ctrl.vehicleType.value = v,
                    child: Container(
                      margin:
                          EdgeInsets.only(right: v != _vehicles.last ? 10 : 0),
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 8),
                      decoration: BoxDecoration(
                        color:
                            selected ? AppColors.lightGreen : AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: selected
                                ? AppColors.primaryGreen
                                : AppColors.divider,
                            width: selected ? 1.8 : 1),
                      ),
                      child: Column(
                        children: [
                          Icon(_vehicleIcon(v),
                              color: selected
                                  ? AppColors.primaryGreen
                                  : AppColors.warmGrey,
                              size: 26),
                          const SizedBox(height: 6),
                          Text(v.label,
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: selected
                                      ? AppColors.primaryGreen
                                      : AppColors.darkGrey)),
                          const SizedBox(height: 2),
                          Text('×${v.priceMultiplier.toStringAsFixed(1)}',
                              style: const TextStyle(
                                  fontSize: 10, color: AppColors.warmGrey)),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            )),

        const SizedBox(height: 20),

        // Special instructions
        ZCTextField(
          label: 'Special Instructions (optional)',
          hint: 'e.g. Handle with care, call before delivery…',
          controller: _instructCtrl,
          maxLines: 3,
          onChanged: (v) => widget.ctrl.specialInstructions.value = v,
        ),

        const SizedBox(height: 8),
      ],
    );
  }

  IconData _categoryIcon(ParcelCategory cat) {
    switch (cat) {
      case ParcelCategory.documents:
        return Icons.description_rounded;
      case ParcelCategory.smallParcel:
        return Icons.all_inbox_rounded;
      case ParcelCategory.mediumParcel:
        return Icons.inventory_rounded;
      case ParcelCategory.largeParcel:
        return Icons.move_to_inbox_rounded;
      case ParcelCategory.fragile:
        return Icons.broken_image_rounded;
    }
  }

  IconData _vehicleIcon(VehicleType v) {
    switch (v) {
      case VehicleType.motorbike:
        return Icons.two_wheeler_rounded;
      case VehicleType.car:
        return Icons.directions_car_rounded;
      case VehicleType.van:
        return Icons.local_shipping_rounded;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 3: Recipient
// ─────────────────────────────────────────────────────────────────────────────
class _RecipientStep extends StatefulWidget {
  const _RecipientStep({required this.ctrl});
  final NewShipmentController ctrl;

  @override
  State<_RecipientStep> createState() => _RecipientStepState();
}

class _RecipientStepState extends State<_RecipientStep> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameCtrl.text = widget.ctrl.recipientName.value;
    _phoneCtrl.text = widget.ctrl.recipientPhone.value;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Recipient Details',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 6),
          Text('Who will receive this parcel?',
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 24),
          ZCTextField(
            label: 'Recipient Name',
            hint: 'Full name',
            controller: _nameCtrl,
            prefixIcon: const Icon(Icons.person_outline_rounded),
            onChanged: (v) => widget.ctrl.recipientName.value = v,
            validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 16),
          ZCTextField(
            label: 'Recipient Phone',
            hint: '+263 77 000 0000',
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            prefixIcon: const Icon(Icons.phone_outlined),
            onChanged: (v) => widget.ctrl.recipientPhone.value = v,
            validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 4: Review & Pay
// ─────────────────────────────────────────────────────────────────────────────
class _ReviewStep extends StatelessWidget {
  const _ReviewStep({required this.ctrl});
  final NewShipmentController ctrl;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final estimate = ctrl.priceEstimate;
      return ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Review & Pay',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 6),
          Text('Confirm your shipment details',
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 20),

          // Route
          ZCCard(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _reviewHeader(context, 'Route', Icons.alt_route_rounded),
              const SizedBox(height: 10),
              InfoRow(
                  label: 'Pickup',
                  value: ctrl.pickup.value?.fullAddress ?? '-'),
              InfoRow(
                  label: 'Destination',
                  value: ctrl.destination.value?.fullAddress ?? '-'),
            ]),
          ),

          // Parcel
          ZCCard(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _reviewHeader(context, 'Parcel', Icons.inventory_2_rounded),
              const SizedBox(height: 10),
              InfoRow(
                  label: 'Category',
                  value: ctrl.parcelCategory.value?.label ?? '-'),
              InfoRow(
                  label: 'Weight',
                  value: '${ctrl.weightKg.value.toStringAsFixed(1)} kg'),
              InfoRow(
                  label: 'Vehicle',
                  value: ctrl.vehicleType.value?.label ?? '-'),
              if (ctrl.specialInstructions.value.isNotEmpty)
                InfoRow(
                    label: 'Instructions',
                    value: ctrl.specialInstructions.value),
            ]),
          ),

          // Recipient
          ZCCard(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _reviewHeader(context, 'Recipient', Icons.person_rounded),
              const SizedBox(height: 10),
              InfoRow(label: 'Name', value: ctrl.recipientName.value),
              InfoRow(label: 'Phone', value: ctrl.recipientPhone.value),
            ]),
          ),

          // Price estimate
          if (estimate != null)
            ZCCard(
              color: AppColors.lightGreen,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Icon(Icons.calculate_rounded,
                          color: AppColors.primaryGreen, size: 18),
                      const SizedBox(width: 8),
                      Text('Price Estimate',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(color: AppColors.primaryGreen)),
                    ]),
                    const SizedBox(height: 4),
                    Text('Price is estimated based on the details provided.',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppColors.darkGreen)),
                    const SizedBox(height: 12),
                    InfoRow(
                        label: 'Base fee',
                        value: 'USD ${estimate.baseFee.toStringAsFixed(2)}'),
                    InfoRow(
                        label:
                            'Weight (${ctrl.weightKg.value.toStringAsFixed(1)} kg)',
                        value: 'USD ${estimate.weightFee.toStringAsFixed(2)}'),
                    InfoRow(
                        label:
                            'Distance (~${estimate.estimatedDistanceKm.toStringAsFixed(0)} km)',
                        value:
                            'USD ${estimate.distanceFee.toStringAsFixed(2)}'),
                    InfoRow(
                        label:
                            'Vehicle ×${estimate.vehicleMultiplier.toStringAsFixed(1)}',
                        value: ''),
                    if (estimate.fragileSurcharge > 0)
                      InfoRow(
                          label: 'Fragile (+15%)',
                          value:
                              'USD ${estimate.fragileSurcharge.toStringAsFixed(2)}'),
                    const Divider(height: 16),
                    Row(children: [
                      Text('Estimated Total',
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 14)),
                      const Spacer(),
                      Text('USD ${estimate.total.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                              color: AppColors.primaryGreen)),
                    ]),
                  ]),
            ),

          // Payment method
          ZCCard(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _reviewHeader(context, 'Payment Method', Icons.payment_rounded),
              const SizedBox(height: 12),
              ...PaymentMethod.values.map((pm) => RadioListTile<PaymentMethod>(
                    title: Text(pm.label,
                        style: const TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 14)),
                    value: pm,
                    groupValue: ctrl.paymentMethod.value,
                    onChanged: (v) => ctrl.paymentMethod.value = v!,
                    activeColor: AppColors.primaryGreen,
                    contentPadding: EdgeInsets.zero,
                  )),
              if (ctrl.paymentMethod.value == PaymentMethod.payNow)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: AppColors.statusPending,
                      borderRadius: BorderRadius.circular(8)),
                  child: Text(
                      'Payment integration will be added in a future update. No real charge will occur.',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.statusPendingText)),
                ),
            ]),
          ),

          const SizedBox(height: 8),
        ],
      );
    });
  }

  Widget _reviewHeader(BuildContext context, String title, IconData icon) {
    return Row(children: [
      Icon(icon, size: 18, color: AppColors.primaryGreen),
      const SizedBox(width: 8),
      Text(title, style: Theme.of(context).textTheme.titleMedium),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SUCCESS SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class _SuccessScreen extends StatelessWidget {
  const _SuccessScreen({required this.shipment});
  final Shipment shipment;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: const BoxDecoration(
                    color: AppColors.lightGreen, shape: BoxShape.circle),
                child: const Icon(Icons.check_circle_rounded,
                    size: 52, color: AppColors.primaryGreen),
              ),
              const SizedBox(height: 28),
              Text('Shipment Created!',
                  style: Theme.of(context).textTheme.displaySmall,
                  textAlign: TextAlign.center),
              const SizedBox(height: 12),
              Text('Your parcel request has been submitted successfully.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.warmGrey),
                  textAlign: TextAlign.center),
              const SizedBox(height: 32),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: AppColors.primaryGreen.withValues(alpha: 0.3)),
                ),
                child: Column(children: [
                  Text('Tracking Number',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.warmGrey)),
                  const SizedBox(height: 6),
                  Text(shipment.trackingNumber,
                      style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryGreen,
                          letterSpacing: 2)),
                ]),
              ),
              const SizedBox(height: 36),
              ZCButton(
                label: 'View Shipment Details',
                onPressed: () {
                  Get.offAll(
                      () => ShipmentDetailScreen(shipmentId: shipment.id));
                },
                icon: Icons.visibility_rounded,
              ),
              const SizedBox(height: 14),
              ZCButton(
                label: 'Back to Home',
                outlined: true,
                onPressed: () => Get.offAllNamed(AppRoutes.customerShell),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
