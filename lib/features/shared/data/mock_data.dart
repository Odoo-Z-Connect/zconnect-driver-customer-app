import '../models/shipment.dart';
import '../models/enums.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// MOCK LOCATIONS
/// All locations are demo data. Replace with a real geocoding/maps service.
/// ─────────────────────────────────────────────────────────────────────────────
class MockLocations {
  const MockLocations._();

  static const List<AppLocation> all = [
    AppLocation(
        id: 'loc_001',
        name: 'City Centre',
        address: '1 Main Street',
        city: 'Harare'),
    AppLocation(
        id: 'loc_002',
        name: 'Avondale Shopping Centre',
        address: '22 King George Road',
        city: 'Harare'),
    AppLocation(
        id: 'loc_003',
        name: 'Borrowdale Village',
        address: '45 Borrowdale Road',
        city: 'Harare'),
    AppLocation(
        id: 'loc_004',
        name: 'Eastgate Mall',
        address: '2nd Street Extension',
        city: 'Harare'),
    AppLocation(
        id: 'loc_005',
        name: 'Sam Levy\'s Village',
        address: 'Borrowdale Road',
        city: 'Harare'),
    AppLocation(
        id: 'loc_006',
        name: 'Msasa Industrial',
        address: '12 Kelvin Road',
        city: 'Harare'),
    AppLocation(
        id: 'loc_007',
        name: 'Chitungwiza Centre',
        address: 'St. Mary\'s Road',
        city: 'Chitungwiza'),
    AppLocation(
        id: 'loc_008',
        name: 'Belvedere',
        address: '5 Churchill Avenue',
        city: 'Harare'),
    AppLocation(
        id: 'loc_009',
        name: 'Milton Park',
        address: '18 Montagu Road',
        city: 'Harare'),
    AppLocation(
        id: 'loc_010',
        name: 'Greendale Post Office',
        address: '78 Greendale Avenue',
        city: 'Harare'),
    AppLocation(
        id: 'loc_011',
        name: 'Bulawayo City Hall',
        address: 'Fife Street',
        city: 'Bulawayo'),
    AppLocation(
        id: 'loc_012',
        name: 'Bulawayo Railway Station',
        address: 'Lobengula Street',
        city: 'Bulawayo'),
  ];
}

/// ─────────────────────────────────────────────────────────────────────────────
/// MOCK SHIPMENTS
/// Centralised sample data used across customer and driver screens.
/// Replace the list contents (or swap this class) to connect a real API.
/// ─────────────────────────────────────────────────────────────────────────────
class MockShipments {
  const MockShipments._();

  static final List<Shipment> seed = [
    Shipment(
      id: 'ship_001',
      trackingNumber: 'ZC-284710',
      status: ShipmentStatus.delivered,
      pickup: MockLocations.all[0],
      destination: MockLocations.all[2],
      senderName: 'Tendai Moyo',
      senderPhone: '+263 77 123 4567',
      recipientName: 'Farai Dube',
      recipientPhone: '+263 71 987 6543',
      parcelCategory: ParcelCategory.smallParcel,
      weightKg: 1.5,
      vehicleType: VehicleType.motorbike,
      estimatedPrice: 8.50,
      paymentMethod: PaymentMethod.payNow,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      estimatedDelivery: DateTime.now().subtract(const Duration(days: 4)),
      driverId: 'drv_001',
      driverName: 'Chidi Okafor',
      driverPhone: '+263 73 555 1234',
      driverVehiclePlate: 'AAA 1234',
    ),
    Shipment(
      id: 'ship_002',
      trackingNumber: 'ZC-193045',
      status: ShipmentStatus.inTransit,
      pickup: MockLocations.all[3],
      destination: MockLocations.all[6],
      senderName: 'Tendai Moyo',
      senderPhone: '+263 77 123 4567',
      recipientName: 'Grace Ncube',
      recipientPhone: '+263 78 222 3333',
      parcelCategory: ParcelCategory.documents,
      weightKg: 0.3,
      vehicleType: VehicleType.motorbike,
      estimatedPrice: 5.00,
      paymentMethod: PaymentMethod.payOnDelivery,
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      estimatedDelivery: DateTime.now().add(const Duration(hours: 3)),
      driverId: 'drv_002',
      driverName: 'Simba Chikwanda',
      driverPhone: '+263 77 777 8888',
      driverVehiclePlate: 'BBB 5678',
    ),
    Shipment(
      id: 'ship_003',
      trackingNumber: 'ZC-502819',
      status: ShipmentStatus.pending,
      pickup: MockLocations.all[4],
      destination: MockLocations.all[10],
      senderName: 'Tendai Moyo',
      senderPhone: '+263 77 123 4567',
      recipientName: 'Abel Sithole',
      recipientPhone: '+263 71 444 5555',
      parcelCategory: ParcelCategory.mediumParcel,
      weightKg: 5.0,
      vehicleType: VehicleType.car,
      estimatedPrice: 22.50,
      paymentMethod: PaymentMethod.payNow,
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      estimatedDelivery: DateTime.now().add(const Duration(hours: 5)),
    ),
    Shipment(
      id: 'ship_004',
      trackingNumber: 'ZC-671432',
      status: ShipmentStatus.assigned,
      pickup: MockLocations.all[8],
      destination: MockLocations.all[5],
      senderName: 'Tendai Moyo',
      senderPhone: '+263 77 123 4567',
      recipientName: 'Nyasha Banda',
      recipientPhone: '+263 73 666 7777',
      parcelCategory: ParcelCategory.fragile,
      weightKg: 2.8,
      vehicleType: VehicleType.car,
      estimatedPrice: 18.00,
      paymentMethod: PaymentMethod.payOnDelivery,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      estimatedDelivery:
          DateTime.now().add(const Duration(hours: 1, minutes: 30)),
      driverId: 'drv_001',
      driverName: 'Chidi Okafor',
      driverPhone: '+263 73 555 1234',
      driverVehiclePlate: 'AAA 1234',
    ),
    Shipment(
      id: 'ship_005',
      trackingNumber: 'ZC-304857',
      status: ShipmentStatus.delivered,
      pickup: MockLocations.all[1],
      destination: MockLocations.all[9],
      senderName: 'Tendai Moyo',
      senderPhone: '+263 77 123 4567',
      recipientName: 'Rumbidzai Mhike',
      recipientPhone: '+263 78 111 2222',
      parcelCategory: ParcelCategory.largeParcel,
      weightKg: 15.0,
      vehicleType: VehicleType.van,
      estimatedPrice: 65.00,
      paymentMethod: PaymentMethod.payNow,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      estimatedDelivery: DateTime.now().subtract(const Duration(days: 9)),
      driverId: 'drv_003',
      driverName: 'Takunda Mupfumi',
      driverPhone: '+263 77 333 4444',
      driverVehiclePlate: 'CCC 9012',
    ),
    Shipment(
      id: 'ship_006',
      trackingNumber: 'ZC-812305',
      status: ShipmentStatus.cancelled,
      pickup: MockLocations.all[7],
      destination: MockLocations.all[11],
      senderName: 'Tendai Moyo',
      senderPhone: '+263 77 123 4567',
      recipientName: 'Munyaradzi Choto',
      recipientPhone: '+263 71 999 0000',
      parcelCategory: ParcelCategory.documents,
      weightKg: 0.1,
      vehicleType: VehicleType.motorbike,
      estimatedPrice: 12.00,
      paymentMethod: PaymentMethod.payOnDelivery,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];
}

/// ─────────────────────────────────────────────────────────────────────────────
/// MOCK DRIVER JOBS
/// Jobs visible to the demo driver account.
/// ─────────────────────────────────────────────────────────────────────────────
class MockDriverJobs {
  const MockDriverJobs._();

  // IDs of shipments that are assigned to demo driver 'drv_001'
  static const List<String> assignedToDriver1 = [
    'ship_002',
    'ship_004',
  ];
}
