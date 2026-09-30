/// ─────────────────────────────────────────────────────────────────────────────
/// PRICING SERVICE
///
/// All formulas are intentionally transparent and isolated here so a backend
/// developer can replace this file with real API calls later.
///
/// Formula (demo):
///   base = categoryBase + weightKg * perKgRate
///   distance factor = mockDistance * perKmRate
///   total = (base + distanceFactor) * vehicle.priceMultiplier
///   fragile surcharge = +15% if ParcelCategory.fragile
///
/// Prices are in USD for demo purposes only.
/// ─────────────────────────────────────────────────────────────────────────────
library;

import '../models/enums.dart';

class PricingService {
  const PricingService._();

  // ── Rates (demo only) ────────────────────────────────────────────────────
  static const double _perKgRate = 0.80; // USD per kg
  static const double _perKmRate = 0.50; // USD per km (mock distance)
  static const double _fragileSurcharge = 0.15; // 15% surcharge

  static const Map<ParcelCategory, double> _categoryBase = {
    ParcelCategory.documents: 3.00,
    ParcelCategory.smallParcel: 5.00,
    ParcelCategory.mediumParcel: 8.00,
    ParcelCategory.largeParcel: 15.00,
    ParcelCategory.fragile: 10.00,
  };

  // Mock distances between origin / destination pairs (km).
  // In a real app, use a directions API or straight-line calculation.
  static const double _estimatedDistance = 12.0;

  /// Calculates a demo price estimate.
  /// Returns the breakdown and total.
  static PriceEstimate calculate({
    required ParcelCategory category,
    required double weightKg,
    required VehicleType vehicle,
  }) {
    final base = _categoryBase[category] ?? 5.00;
    final weightCost = weightKg * _perKgRate;
    final distanceCost = _estimatedDistance * _perKmRate;
    double subtotal =
        (base + weightCost + distanceCost) * vehicle.priceMultiplier;

    double fragileSurchargeAmount = 0;
    if (category == ParcelCategory.fragile) {
      fragileSurchargeAmount = subtotal * _fragileSurcharge;
      subtotal += fragileSurchargeAmount;
    }

    return PriceEstimate(
      baseFee: base,
      weightFee: weightCost,
      distanceFee: distanceCost,
      vehicleMultiplier: vehicle.priceMultiplier,
      fragileSurcharge: fragileSurchargeAmount,
      total: subtotal,
      estimatedDistanceKm: _estimatedDistance,
    );
  }
}

class PriceEstimate {
  final double baseFee;
  final double weightFee;
  final double distanceFee;
  final double vehicleMultiplier;
  final double fragileSurcharge;
  final double total;
  final double estimatedDistanceKm;

  const PriceEstimate({
    required this.baseFee,
    required this.weightFee,
    required this.distanceFee,
    required this.vehicleMultiplier,
    required this.fragileSurcharge,
    required this.total,
    required this.estimatedDistanceKm,
  });
}
