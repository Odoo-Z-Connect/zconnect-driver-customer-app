/// Shipment status — drives UI chips, timeline, and filter tabs.
enum ShipmentStatus {
  pending,
  assigned,
  pickedUp,
  inTransit,
  delivered,
  cancelled;

  String get label {
    switch (this) {
      case ShipmentStatus.pending:
        return 'Pending';
      case ShipmentStatus.assigned:
        return 'Driver Assigned';
      case ShipmentStatus.pickedUp:
        return 'Picked Up';
      case ShipmentStatus.inTransit:
        return 'In Transit';
      case ShipmentStatus.delivered:
        return 'Delivered';
      case ShipmentStatus.cancelled:
        return 'Cancelled';
    }
  }
}

/// Parcel category determines base pricing weight.
enum ParcelCategory {
  documents,
  smallParcel,
  mediumParcel,
  largeParcel,
  fragile;

  String get label {
    switch (this) {
      case ParcelCategory.documents:
        return 'Documents';
      case ParcelCategory.smallParcel:
        return 'Small Parcel';
      case ParcelCategory.mediumParcel:
        return 'Medium Parcel';
      case ParcelCategory.largeParcel:
        return 'Large Parcel';
      case ParcelCategory.fragile:
        return 'Fragile';
    }
  }

  String get description {
    switch (this) {
      case ParcelCategory.documents:
        return 'Letters, contracts, certificates';
      case ParcelCategory.smallParcel:
        return 'Up to 2 kg, shoe-box size';
      case ParcelCategory.mediumParcel:
        return 'Up to 10 kg, suitcase size';
      case ParcelCategory.largeParcel:
        return 'Up to 30 kg, large box';
      case ParcelCategory.fragile:
        return 'Glassware, electronics, art';
    }
  }

  String get iconPath => 'assets/images/logo.png'; // placeholder
}

/// Vehicle type — affects pricing multiplier.
enum VehicleType {
  motorbike,
  car,
  van;

  String get label {
    switch (this) {
      case VehicleType.motorbike:
        return 'Motorbike';
      case VehicleType.car:
        return 'Car';
      case VehicleType.van:
        return 'Van';
    }
  }

  String get description {
    switch (this) {
      case VehicleType.motorbike:
        return 'Fast, ideal for small items';
      case VehicleType.car:
        return 'Comfortable, medium parcels';
      case VehicleType.van:
        return 'Large parcels, bulk shipments';
    }
  }

  double get priceMultiplier {
    switch (this) {
      case VehicleType.motorbike:
        return 1.0;
      case VehicleType.car:
        return 1.6;
      case VehicleType.van:
        return 2.5;
    }
  }
}

/// Payment method — UI state only in this prototype.
enum PaymentMethod {
  payNow,
  payOnDelivery;

  String get label {
    switch (this) {
      case PaymentMethod.payNow:
        return 'Pay Now';
      case PaymentMethod.payOnDelivery:
        return 'Pay on Delivery';
    }
  }
}

/// User role — determines which shell the user sees after sign-in.
enum UserRole { customer, driver }

/// Availability toggle for drivers.
enum DriverAvailability { online, offline }
