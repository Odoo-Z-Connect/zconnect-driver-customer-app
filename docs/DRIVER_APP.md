# Driver App

The Driver experience focuses on efficiency, allowing delivery personnel to manage their assigned jobs.

## Key Screens
1. **Driver Jobs List (`driver_jobs_screen.dart`)**: A tabbed interface separating Active Jobs from History.
2. **Job Details (`driver_job_detail_screen.dart`)**: Shows full routing details, parcel info, and contact numbers.
3. **Driver Profile (`driver_profile_screen.dart`)**: Displays driver stats, vehicle details, and availability toggle.

## Core Features
- **Job Status Management**: Drivers can transition a job through various states:
  - `Accept`
  - `Mark as Picked Up`
  - `Mark as Delivered`
- **Navigation**: Drivers can launch the native Google Maps app pre-filled with the pickup or destination coordinates via the `url_launcher` package.

## Mock Behavior
Currently, driver job updates hit a mock repository (`ShipmentRepository`). If the Odoo backend is reachable, it uses actual API calls, but otherwise falls back to local state updates. Real GPS tracking of the driver is not yet implemented.
