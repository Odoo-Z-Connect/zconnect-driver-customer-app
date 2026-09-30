# API and Integration

ZConnect relies on an Odoo backend for dispatch, pricing, and job assignment.

## Current Status
- Authentication: Connected to Odoo via `/web/session/authenticate`.
- Fetch Shipments: Calls `/api/v1/shipments/list`.
- Accept Assignment: Calls `/api/v1/driver/assignments/{id}/accept`.
- Update Status: Calls `/api/v1/shipments/{id}/status`.

**Important**: Because the backend may be offline or unstable during development, `ShipmentRepository` uses an `ApiHelper` that catches network errors and gracefully falls back to local `mock_data.dart`.

## Planned Integrations
| Feature | Endpoint | Status |
|---|---|---|
| Create Shipment | `/api/v1/shipments/create` | Mocked locally |
| Fetch Pricing | `/api/v1/pricing/estimate` | Mocked locally |
| Live GPS Update | `/api/v1/driver/location` | Planned |
| Payment Gateway | Third-party provider | Planned |
