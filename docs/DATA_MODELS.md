# Data Models

The core data structures are defined in `lib/features/shared/models/`.

## `Shipment`
Represents a parcel delivery job from creation to completion.
- `id` (String)
- `trackingNumber` (String)
- `status` (`ShipmentStatus` enum)
- `pickup` and `destination` (`AppLocation`)
- `parcelCategory` (`ParcelCategory` enum)
- `vehicleType` (`VehicleType` enum)
- `weightKg` (double)

The model includes custom JSON parsing logic (`fromJson`) that maps Odoo's raw string states (e.g., `'draft'`, `'assigned'`, `'en_route_pickup'`) to the internal `ShipmentStatus` enum.

## `AppLocation`
Represents a geographical point and its street address.
- `id` (String, usually "lat,lng")
- `name` (String, e.g., "123 Main St")
- `address` (String)
- `city` (String)

## `TimelineEvent`
Generated dynamically by the `Shipment.timeline` getter to drive the visual progress UI.
