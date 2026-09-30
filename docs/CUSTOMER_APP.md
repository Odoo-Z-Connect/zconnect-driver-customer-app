# Customer App

The Customer experience in the ZConnect app allows users to manage their parcel delivery needs from start to finish.

## Key Screens
1. **Customer Home (`customer_home_screen.dart`)**: Dashboard showing shipment summaries (Pending, In Transit, Delivered) and recent activity.
2. **New Shipment Flow (`new_shipment_screen.dart`)**: 
   - Step 1: Location picking using the `MapPickerScreen` (OpenStreetMap integration).
   - Step 2: Parcel details (Category, Weight, Vehicle Type).
   - Step 3: Review and Payment selection.
3. **Shipment Tracking (`customer_track_screen.dart`)**: Timeline view showing the current status of an active shipment.

## Location Picking
The app utilizes `flutter_map` and `latlong2` to provide an interactive map for dropping pins. Reverse geocoding is performed via the OpenStreetMap Nominatim API to convert coordinates into readable street addresses.

## Mock Behavior
Currently, when a customer submits a new shipment, the data is pushed to a local mock repository (`ShipmentRepository.addShipment`) rather than hitting a live payment gateway or backend server.
