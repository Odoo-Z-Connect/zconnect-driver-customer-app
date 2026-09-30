import 'dart:convert';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../../../core/api_client.dart';
import '../models/shipment.dart';
import '../models/enums.dart';
import '../data/mock_data.dart';
import '../../auth/controllers/auth_controller.dart';

class ShipmentRepository extends GetxController {
  final RxList<Shipment> shipments = <Shipment>[].obs;
  final RxList<Shipment> driverJobs = <Shipment>[].obs;

  @override
  void onInit() {
    super.onInit();

    // Listen to auth changes
    ever(Get.find<AuthController>().currentUser, (user) {
      if (user != null) {
        fetchShipments();
      }
    });

    // Also fetch immediately if already logged in
    if (Get.find<AuthController>().currentUser.value != null) {
      fetchShipments();
    }
  }

  Future<void> fetchShipments() async {
    try {
      final isDriver = Get.find<AuthController>().isDriver;
      final endpoint = isDriver ? '/driver/assignments' : '/shipments';

      final res = await ApiClient().dio.get(endpoint);
      print(
          'fetchShipments: endpoint=$endpoint status=${res.statusCode} isDriver=$isDriver');

      dynamic responseData = res.data;
      if (responseData is String) {
        try {
          responseData = jsonDecode(responseData);
        } catch (e) {
          print('fetchShipments: failed to decode string response');
          return;
        }
      }

      if (res.statusCode == 200 &&
          responseData is Map &&
          responseData['success'] == true) {
        final rawList = responseData['data'] as List;
        print('fetchShipments: rawList length=${rawList.length}');
        final list = rawList.map((e) {
          try {
            // Driver assignments have shipment nested under 'shipment' key
            if (isDriver && e['shipment'] != null && e['shipment'] is Map) {
              final shipmentJson =
                  Map<String, dynamic>.from(e['shipment'] as Map);
              // Inject assignment ID and state so we can call accept/reject
              shipmentJson['assignment_id'] = e['id']?.toString() ?? '';
              shipmentJson['assignment_state'] = e['state'] ?? 'offered';
              return Shipment.fromJson(shipmentJson);
            }
            return Shipment.fromJson(e as Map<String, dynamic>);
          } catch (err, stack) {
            print('Error parsing shipment: $err\n$stack');
            rethrow;
          }
        }).toList();

        print('fetchShipments: parsed list length=${list.length}');
        if (isDriver) {
          driverJobs.assignAll(list);
          print(
              'fetchShipments: assigned to driverJobs, new length=${driverJobs.length}');
        } else {
          shipments.assignAll(list);
        }
      }
    } catch (e, stack) {
      print('Error fetching shipments: $e\n$stack');
    }
  }

  // ── Customer operations ──────────────────────────────────────────────────

  Future<Shipment?> createShipment({
    required AppLocation pickup,
    required AppLocation destination,
    required String senderName,
    required String senderPhone,
    required String recipientName,
    required String recipientPhone,
    required ParcelCategory parcelCategory,
    required double weightKg,
    required VehicleType vehicleType,
    required double estimatedPrice,
    required PaymentMethod paymentMethod,
    String? specialInstructions,
  }) async {
    try {
      String catCode = 'parcel';
      switch (parcelCategory) {
        case ParcelCategory.documents:
          catCode = 'document';
          break;
        case ParcelCategory.smallParcel:
        case ParcelCategory.mediumParcel:
          catCode = 'parcel';
          break;
        case ParcelCategory.largeParcel:
          catCode = 'freight';
          break;
        case ParcelCategory.fragile:
          catCode = 'fragile';
          break;
      }

      String vehCode = 'motorcycle';
      switch (vehicleType) {
        case VehicleType.motorbike:
          vehCode = 'motorcycle';
          break;
        case VehicleType.car:
          vehCode = 'sedan';
          break;
        case VehicleType.van:
          vehCode = 'van';
          break;
      }

      final res = await ApiClient().dio.post('/shipments', data: {
        "pickup_address": pickup.fullAddress,
        "pickup_contact_name": senderName,
        "pickup_contact_phone": senderPhone,
        "delivery_address": destination.fullAddress,
        "delivery_contact_name": recipientName,
        "delivery_contact_phone": recipientPhone,
        "shipment_category": catCode,
        "vehicle_category": vehCode,
        "special_instructions": specialInstructions ?? "",
        "weight_kg": weightKg > 0 ? weightKg : 1.0,
        "distance_km": 10.0, // Calculated or default distance
      });

      if (res.statusCode == 200 && res.data['success'] == true) {
        final shipment = Shipment.fromJson(res.data['data'] ?? res.data);
        shipments.insert(0, shipment);
        return shipment;
      }
    } catch (e) {
      print('Error creating shipment: $e');
    }

    return null;
  }

  Future<Shipment?> quoteShipment(String id) async {
    try {
      final res = await ApiClient().dio.post('/shipments/$id/quote');
      if (res.statusCode == 200 && res.data['success'] == true) {
        final shipment = Shipment.fromJson(res.data['data']);
        _updateLocalShipment(shipment);
        return shipment;
      }
    } catch (e) {
      print('Error quoting shipment: $e');
    }
    return null;
  }

  Future<Shipment?> preparePayment(String id) async {
    try {
      final res = await ApiClient().dio.post('/shipments/$id/prepare_payment');
      if (res.statusCode == 200 && res.data['success'] == true) {
        final shipment = Shipment.fromJson(res.data['data']);
        _updateLocalShipment(shipment);
        return shipment;
      }
    } catch (e) {
      print('Error preparing payment: $e');
    }
    return null;
  }

  Future<Shipment?> confirmPayment(String id) async {
    try {
      final res = await ApiClient().dio.post('/shipments/$id/confirm');
      if (res.statusCode == 200 && res.data['success'] == true) {
        final shipment = Shipment.fromJson(res.data['data']);
        _updateLocalShipment(shipment);
        return shipment;
      }
    } catch (e) {
      print('Error confirming payment: $e');
    }
    return null;
  }

  void _updateLocalShipment(Shipment shipment) {
    final index = shipments.indexWhere((s) => s.id == shipment.id);
    if (index != -1) {
      shipments[index] = shipment;
      shipments.refresh();
    }
    final driverIndex = driverJobs.indexWhere((s) => s.id == shipment.id);
    if (driverIndex != -1) {
      driverJobs[driverIndex] = shipment;
      driverJobs.refresh();
    }
  }

  Shipment? findByTracking(String trackingNumber) {
    try {
      return shipments.firstWhere(
        (s) => s.trackingNumber.toLowerCase() == trackingNumber.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  List<Shipment> getByStatus(ShipmentStatus? status) {
    if (status == null) return List.unmodifiable(shipments);
    return shipments.where((s) => s.status == status).toList();
  }

  List<Shipment> search(String query) {
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return List.unmodifiable(shipments);
    return shipments.where((s) {
      return s.trackingNumber.toLowerCase().contains(q) ||
          (s.destination?.name.toLowerCase().contains(q) ?? false) ||
          (s.destination?.city.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  Future<void> acceptAssignment(String assignmentId, String shipmentId) async {
    try {
      final res =
          await ApiClient().dio.post('/assignments/$assignmentId/accept');
      if (res.statusCode == 200) {
        // Refresh from backend to get accurate state
        await fetchShipments();
      }
    } catch (e) {
      print('Error accepting assignment: $e');
    }
  }

  Future<void> rejectAssignment(String assignmentId, String reason) async {
    try {
      await ApiClient().dio.post('/assignments/$assignmentId/reject', data: {
        'reason': reason,
      });
      fetchShipments(); // refresh list
    } catch (e) {
      print('Error rejecting assignment: $e');
    }
  }

  Future<void> updateShipmentStatus(
      String shipmentId, ShipmentStatus newStatus) async {
    final index = shipments.indexWhere((s) => s.id == shipmentId);
    if (index == -1) return;

    try {
      String statusStr = 'assigned';
      if (newStatus == ShipmentStatus.pickedUp) statusStr = 'picked_up';
      if (newStatus == ShipmentStatus.inTransit) statusStr = 'in_transit';
      if (newStatus == ShipmentStatus.delivered) statusStr = 'delivered';

      await ApiClient()
          .dio
          .post('/shipments/$shipmentId/status', data: {'status': statusStr});
    } catch (e) {
      print('Error updating status: $e');
    }

    // Update local state regardless
    if (index != -1) {
      shipments[index] = shipments[index].copyWith(status: newStatus);
      shipments.refresh();
    }
    final driverIdx = driverJobs.indexWhere((s) => s.id == shipmentId);
    if (driverIdx != -1) {
      driverJobs[driverIdx] = driverJobs[driverIdx].copyWith(status: newStatus);
      driverJobs.refresh();
    }
  }

  Future<void> submitPod(
    String shipmentId, {
    required String recipientName,
    required String recipientPhone,
    required String deliveryNotes,
  }) async {
    try {
      await ApiClient().dio.post('/shipments/$shipmentId/pod', data: {
        'recipient_name': recipientName,
        'recipient_phone': recipientPhone,
        'delivery_notes': deliveryNotes,
        'latitude': 0.0,
        'longitude': 0.0,
      });
      updateShipmentStatus(shipmentId, ShipmentStatus.delivered);
    } catch (e) {
      print('Error submitting POD: $e');
    }
  }

  // ── Stats for dashboard ──────────────────────────────────────────────────

  List<Shipment> get activeList =>
      Get.find<AuthController>().isDriver ? driverJobs : shipments;

  int get totalShipments => activeList.length;
  int get inTransitCount => activeList
      .where((s) =>
          s.status == ShipmentStatus.inTransit ||
          s.status == ShipmentStatus.pickedUp)
      .length;
  int get deliveredCount =>
      activeList.where((s) => s.status == ShipmentStatus.delivered).length;
  int get pendingCount => activeList
      .where((s) =>
          s.status == ShipmentStatus.pending ||
          s.status == ShipmentStatus.assigned)
      .length;
}
