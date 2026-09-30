import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../features/shared/models/shipment.dart';
import '../../../features/shared/models/enums.dart';
import '../../../features/shared/services/pricing_service.dart';
import '../../../features/shared/services/shipment_repository.dart';
import '../../../features/auth/controllers/auth_controller.dart';

/// Controller for the multi-step new-shipment flow.
/// Holds all form state, calculates price, and submits the shipment.
class NewShipmentController extends GetxController {
  // Step index
  final RxInt step = 0.obs;
  static const int totalSteps = 4;

  // ── Step 1: Locations ────────────────────────────────────────────────────
  final Rxn<AppLocation> pickup = Rxn<AppLocation>();
  final Rxn<AppLocation> destination = Rxn<AppLocation>();

  // ── Step 2: Parcel details ───────────────────────────────────────────────
  final Rxn<ParcelCategory> parcelCategory = Rxn<ParcelCategory>();
  final RxDouble weightKg = 1.0.obs;
  final Rxn<VehicleType> vehicleType = Rxn<VehicleType>();
  final RxString specialInstructions = ''.obs;

  // ── Step 3: Contact details ──────────────────────────────────────────────
  final RxString recipientName = ''.obs;
  final RxString recipientPhone = ''.obs;

  // ── Step 4: Payment ──────────────────────────────────────────────────────
  final Rx<PaymentMethod> paymentMethod = PaymentMethod.payOnDelivery.obs;

  // ── Price estimate (computed) ────────────────────────────────────────────
  PriceEstimate? get priceEstimate {
    if (parcelCategory.value == null || vehicleType.value == null) return null;
    return PricingService.calculate(
      category: parcelCategory.value!,
      weightKg: weightKg.value,
      vehicle: vehicleType.value!,
    );
  }

  // ── Submission ───────────────────────────────────────────────────────────
  final RxBool isSubmitting = false.obs;
  Rxn<Shipment> createdShipment = Rxn<Shipment>();

  bool get canGoNext {
    switch (step.value) {
      case 0:
        return pickup.value != null && destination.value != null;
      case 1:
        return parcelCategory.value != null && vehicleType.value != null;
      case 2:
        return recipientName.value.trim().isNotEmpty &&
            recipientPhone.value.trim().isNotEmpty;
      case 3:
        return true;
      default:
        return false;
    }
  }

  void goNext() {
    if (step.value < totalSteps - 1) step.value++;
  }

  void goBack() {
    if (step.value > 0) step.value--;
  }

  Future<Shipment?> submit() async {
    isSubmitting.value = true;

    final auth = Get.find<AuthController>();
    final repo = Get.find<ShipmentRepository>();
    final user = auth.currentUser.value;

    final estimate = priceEstimate;

    Shipment? shipment = await repo.createShipment(
      pickup: pickup.value!,
      destination: destination.value!,
      senderName: user?.name ?? 'Customer',
      senderPhone: user?.phone ?? '',
      recipientName: recipientName.value.trim(),
      recipientPhone: recipientPhone.value.trim(),
      parcelCategory: parcelCategory.value!,
      weightKg: weightKg.value,
      vehicleType: vehicleType.value!,
      estimatedPrice: estimate?.total ?? 0,
      paymentMethod: paymentMethod.value,
      specialInstructions:
          specialInstructions.value.isEmpty ? null : specialInstructions.value,
    );

    if (shipment != null && shipment.status == ShipmentStatus.pending) {
      // Execute full state machine flow since UI currently does this all at once
      final quoted = await repo.quoteShipment(shipment.id);
      if (quoted != null) {
        final prepared = await repo.preparePayment(quoted.id);
        if (prepared != null) {
          final confirmed = await repo.confirmPayment(prepared.id);
          if (confirmed != null) {
            shipment = confirmed;
          }
        }
      }
    }

    createdShipment.value = shipment;
    isSubmitting.value = false;
    return shipment;
  }

  void reset() {
    step.value = 0;
    pickup.value = null;
    destination.value = null;
    parcelCategory.value = null;
    weightKg.value = 1.0;
    vehicleType.value = null;
    specialInstructions.value = '';
    recipientName.value = '';
    recipientPhone.value = '';
    paymentMethod.value = PaymentMethod.payOnDelivery;
    createdShipment.value = null;
  }
}
