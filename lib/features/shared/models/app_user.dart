import 'enums.dart';

/// App user — customer or driver.
class AppUser {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? address;
  final UserRole role;
  final String? avatarUrl;

  // Driver-specific fields
  final String? vehicleType;
  final String? vehiclePlate;
  final DriverAvailability availability;
  final String? driverCode;
  final String? licenceClass;
  final String? licenceNumber;
  final String? nationalId;
  final String? verificationStatus;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.address,
    required this.role,
    this.avatarUrl,
    this.vehicleType,
    this.vehiclePlate,
    this.availability = DriverAvailability.offline,
    this.driverCode,
    this.licenceClass,
    this.licenceNumber,
    this.nationalId,
    this.verificationStatus,
  });

  bool get isDriver => role == UserRole.driver;

  AppUser copyWith({
    String? name,
    String? email,
    String? phone,
    String? address,
    DriverAvailability? availability,
    String? vehicleType,
    String? vehiclePlate,
    String? driverCode,
    String? licenceClass,
    String? licenceNumber,
    String? nationalId,
    String? verificationStatus,
  }) {
    return AppUser(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      role: role,
      avatarUrl: avatarUrl,
      vehicleType: vehicleType ?? this.vehicleType,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      availability: availability ?? this.availability,
      driverCode: driverCode ?? this.driverCode,
      licenceClass: licenceClass ?? this.licenceClass,
      licenceNumber: licenceNumber ?? this.licenceNumber,
      nationalId: nationalId ?? this.nationalId,
      verificationStatus: verificationStatus ?? this.verificationStatus,
    );
  }
}
