import 'enums.dart';

/// Represents a physical location (pickup or destination).
/// In this prototype all locations are mock data.
class AppLocation {
  final String id;
  final String name;
  final String address;
  final String city;

  const AppLocation({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
  });

  String get fullAddress => '$name, $address, $city';

  factory AppLocation.fromJson(Map<String, dynamic> json) {
    final addr = json['address']?.toString() ?? '';
    final n =
        json['contact_name']?.toString() ?? json['name']?.toString() ?? '';
    return AppLocation(
      id: json['id']?.toString() ?? '',
      name: n.isNotEmpty ? n : (addr.isNotEmpty ? addr : '-'),
      address: addr,
      city: json['city']?.toString() ?? '',
    );
  }

  @override
  String toString() => fullAddress;
}

/// One step in the visual delivery timeline.
class TimelineEvent {
  final String title;
  final String description;
  final DateTime? time;
  final bool isCompleted;
  final bool isActive;

  const TimelineEvent({
    required this.title,
    required this.description,
    this.time,
    this.isCompleted = false,
    this.isActive = false,
  });
}

/// Full shipment model — all fields optional where not yet captured
/// so the object can be built incrementally during the request flow.
class Shipment {
  final String id; // UUID
  final String trackingNumber; // ZC-XXXXXX
  final ShipmentStatus status;

  final AppLocation? pickup;
  final AppLocation? destination;

  final String senderName;
  final String senderPhone;
  final String recipientName;
  final String recipientPhone;

  final ParcelCategory? parcelCategory;
  final double? weightKg;
  final VehicleType? vehicleType;
  final String? specialInstructions;

  final double estimatedPrice;
  final PaymentMethod paymentMethod;

  final DateTime createdAt;
  final DateTime? estimatedDelivery;

  final String? driverId;
  final String? driverName;
  final String? driverPhone;
  final String? driverVehiclePlate;

  // Driver-side: injected from assignment object during fetchShipments
  final String? assignmentId;
  final String? assignmentState;

  const Shipment({
    required this.id,
    required this.trackingNumber,
    required this.status,
    this.pickup,
    this.destination,
    this.senderName = '',
    this.senderPhone = '',
    this.recipientName = '',
    this.recipientPhone = '',
    this.parcelCategory,
    this.weightKg,
    this.vehicleType,
    this.specialInstructions,
    this.estimatedPrice = 0,
    this.paymentMethod = PaymentMethod.payOnDelivery,
    required this.createdAt,
    this.estimatedDelivery,
    this.driverId,
    this.driverName,
    this.driverPhone,
    this.driverVehiclePlate,
    this.assignmentId,
    this.assignmentState,
  });

  Shipment copyWith({
    String? id,
    String? trackingNumber,
    ShipmentStatus? status,
    AppLocation? pickup,
    AppLocation? destination,
    String? senderName,
    String? senderPhone,
    String? recipientName,
    String? recipientPhone,
    ParcelCategory? parcelCategory,
    double? weightKg,
    VehicleType? vehicleType,
    String? specialInstructions,
    double? estimatedPrice,
    PaymentMethod? paymentMethod,
    DateTime? createdAt,
    DateTime? estimatedDelivery,
    String? driverId,
    String? driverName,
    String? driverPhone,
    String? driverVehiclePlate,
    String? assignmentId,
    String? assignmentState,
  }) {
    return Shipment(
      id: id ?? this.id,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      status: status ?? this.status,
      pickup: pickup ?? this.pickup,
      destination: destination ?? this.destination,
      senderName: senderName ?? this.senderName,
      senderPhone: senderPhone ?? this.senderPhone,
      recipientName: recipientName ?? this.recipientName,
      recipientPhone: recipientPhone ?? this.recipientPhone,
      parcelCategory: parcelCategory ?? this.parcelCategory,
      weightKg: weightKg ?? this.weightKg,
      vehicleType: vehicleType ?? this.vehicleType,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      estimatedPrice: estimatedPrice ?? this.estimatedPrice,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      createdAt: createdAt ?? this.createdAt,
      estimatedDelivery: estimatedDelivery ?? this.estimatedDelivery,
      driverId: driverId ?? this.driverId,
      driverName: driverName ?? this.driverName,
      driverPhone: driverPhone ?? this.driverPhone,
      driverVehiclePlate: driverVehiclePlate ?? this.driverVehiclePlate,
      assignmentId: assignmentId ?? this.assignmentId,
      assignmentState: assignmentState ?? this.assignmentState,
    );
  }

  factory Shipment.fromJson(Map<String, dynamic> json) {
    ShipmentStatus parseStatus(String? s) {
      switch (s) {
        case 'draft':
        case 'quoted':
        case 'awaiting_payment':
        case 'confirmed':
          return ShipmentStatus.pending;
        case 'assigned':
          return ShipmentStatus.assigned;
        case 'en_route_pickup':
        case 'picked_up':
          return ShipmentStatus.pickedUp;
        case 'in_transit':
        case 'near_delivery':
          return ShipmentStatus.inTransit;
        case 'delivered':
          return ShipmentStatus.delivered;
        default:
          return ShipmentStatus.pending;
      }
    }

    ParcelCategory parseCategory(String? c) {
      switch (c) {
        case 'document':
          return ParcelCategory.documents;
        case 'parcel':
          return ParcelCategory.smallParcel;
        case 'freight':
          return ParcelCategory.largeParcel;
        case 'fragile':
          return ParcelCategory.fragile;
        default:
          return ParcelCategory.smallParcel;
      }
    }

    VehicleType parseVehicle(String? v) {
      switch (v) {
        case 'motorcycle':
          return VehicleType.motorbike;
        case 'van':
          return VehicleType.van;
        case 'pickup':
        case 'sedan':
        default:
          return VehicleType.car;
      }
    }

    String parseString(dynamic val, [String? key, String? subKey]) {
      if (val is List && val.isNotEmpty) return val[1].toString();
      if (val is Map) {
        if (key != null) {
          final subVal = val[key];
          if (subKey != null && subVal is Map) {
            return subVal[subKey]?.toString() ?? '';
          }
          return subVal?.toString() ?? '';
        }
      }
      return val?.toString() ?? '';
    }

    AppLocation? parseLocation(dynamic val) {
      if (val == null) return null;
      if (val is Map) return AppLocation.fromJson(val as Map<String, dynamic>);
      if (val is List && val.isNotEmpty)
        return AppLocation(
            id: val[0].toString(),
            name: val.length > 1 ? val[1].toString() : '',
            address: '',
            city: '');
      return null;
    }

    ShipmentStatus parsedStatus = parseStatus(json['state']);
    if (json['assignment_state'] == 'accepted' &&
        parsedStatus == ShipmentStatus.pending) {
      parsedStatus = ShipmentStatus.assigned;
    }

    return Shipment(
      id: json['id']?.toString() ?? '',
      trackingNumber: json['name'] ?? json['tracking_number'] ?? '',
      status: parsedStatus,
      pickup: parseLocation(json['pickup']),
      destination: parseLocation(json['delivery']),
      senderName: parseString(json['customer'], 'name'),
      senderPhone: parseString(json['customer'], 'phone'),
      recipientName: parseString(json['delivery'], 'contact_name'),
      recipientPhone: parseString(json['delivery'], 'contact_phone'),
      parcelCategory: parseCategory(
          parseString(json['cargo'], 'category').isEmpty
              ? json['shipment_category']?.toString()
              : parseString(json['cargo'], 'category')),
      weightKg: (double.tryParse(parseString(json['cargo'], 'weight_kg')) ??
          double.tryParse(json['weight_kg']?.toString() ?? '0') ??
          0),
      vehicleType: parseVehicle(
          parseString(json['cargo'], 'vehicle_category_required').isEmpty
              ? json['vehicle_category']?.toString()
              : parseString(json['cargo'], 'vehicle_category_required')),
      specialInstructions: parseString(json['cargo'], 'special_instructions'),
      estimatedPrice:
          (double.tryParse(parseString(json['pricing'], 'total_amount')) ??
              double.tryParse(json['total_amount']?.toString() ?? '0') ??
              0),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      driverName: parseString(json['driver'], 'name'),
      driverPhone: parseString(json['driver'], 'phone'),
      driverVehiclePlate:
          parseString(json['driver'], 'primary_vehicle', 'license_plate'),
      assignmentId: json['assignment_id']?.toString(),
      assignmentState: json['assignment_state']?.toString(),
    );
  }

  List<TimelineEvent> get timeline {
    final events = <TimelineEvent>[];
    final statuses = [
      ShipmentStatus.pending,
      ShipmentStatus.assigned,
      ShipmentStatus.pickedUp,
      ShipmentStatus.inTransit,
      ShipmentStatus.delivered,
    ];

    if (status == ShipmentStatus.cancelled) {
      return [
        TimelineEvent(
          title: 'Request Received',
          description: 'Your shipment was requested',
          time: createdAt,
          isCompleted: true,
        ),
        TimelineEvent(
          title: 'Cancelled',
          description: 'Shipment was cancelled',
          isCompleted: true,
          isActive: true,
        ),
      ];
    }

    final currentIndex = statuses.indexOf(status);
    for (int i = 0; i < statuses.length; i++) {
      final s = statuses[i];
      events.add(TimelineEvent(
        title: _timelineTitle(s),
        description: _timelineDesc(s),
        time: i == 0 ? createdAt : null,
        isCompleted: i < currentIndex,
        isActive: i == currentIndex,
      ));
    }
    return events;
  }

  String _timelineTitle(ShipmentStatus s) {
    switch (s) {
      case ShipmentStatus.pending:
        return 'Request Received';
      case ShipmentStatus.assigned:
        return 'Driver Assigned';
      case ShipmentStatus.pickedUp:
        return 'Parcel Picked Up';
      case ShipmentStatus.inTransit:
        return 'In Transit';
      case ShipmentStatus.delivered:
        return 'Delivered';
      default:
        return s.label;
    }
  }

  String _timelineDesc(ShipmentStatus s) {
    switch (s) {
      case ShipmentStatus.pending:
        return 'Waiting for a driver to accept';
      case ShipmentStatus.assigned:
        return 'A driver is on the way to pick up your parcel';
      case ShipmentStatus.pickedUp:
        return 'Driver has collected your parcel';
      case ShipmentStatus.inTransit:
        return 'Your parcel is on its way to the destination';
      case ShipmentStatus.delivered:
        return 'Parcel delivered successfully';
      default:
        return '';
    }
  }
}
