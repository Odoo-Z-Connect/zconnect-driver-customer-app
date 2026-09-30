# ZConnect Mobile Application

Welcome to the ZConnect Mobile App repository! This Flutter application serves two primary user roles in the ZConnect parcel delivery and logistics platform: **Customers** and **Drivers**.

## Overview
- **Customer App**: Allows users to sign up, book new parcel shipments (including location pin-drop), view shipment histories, and track current deliveries.
- **Driver App**: Enables delivery personnel to view available or assigned jobs, manage delivery statuses (Pickup, In Transit, Delivered), and navigate to destinations via Google Maps.

## Implementation Status
Currently, the app consists of a fully functional UI and state-management structure.
- **Customer Workflow**: Location picking using OpenStreetMap, shipment creation, tracking history, and form validation are implemented.
- **Driver Workflow**: Job assignment lists, detailed job views, timeline tracking, and Maps integration are implemented.
- **Backend Integration**: Most backend connections to the ZConnect dispatch service (Odoo-based) are mocked or partially integrated. See [API and Integration](docs/API_AND_INTEGRATION.md) for details.

## Technology Stack
- **Framework**: Flutter (Dart)
- **State Management**: GetX
- **Mapping**: `flutter_map`, `geolocator`, OpenStreetMap Nominatim
- **Network**: `dio`, `http`

## Documentation Map
Detailed documentation can be found in the `docs/` directory:

1. [Architecture](docs/ARCHITECTURE.md) - App structure and state management.
2. [Platform Overview](docs/PLATFORM_OVERVIEW.md) - How this app fits into the ZConnect platform.
3. [Customer App](docs/CUSTOMER_APP.md) - Customer-specific flows.
4. [Driver App](docs/DRIVER_APP.md) - Driver-specific flows.
5. [API & Integration](docs/API_AND_INTEGRATION.md) - Backend connectivity and mocks.
6. [Data Models](docs/DATA_MODELS.md) - Core app models.
7. [Setup & Development](docs/SETUP_AND_DEVELOPMENT.md) - Installation and run instructions.
8. [Git Workflow](docs/GIT_WORKFLOW.md) - Branching strategy and code promotion.
9. [Security](docs/SECURITY.md) - Secrets and ignore policies.
10. [Testing](docs/TESTING.md) - Static analysis, formatting, and tests.
11. [Known Issues & Roadmap](docs/KNOWN_ISSUES_AND_ROADMAP.md) - Current limitations and planned features.

## Getting Started
Please see the [Setup & Development](docs/SETUP_AND_DEVELOPMENT.md) guide for prerequisites and instructions on how to run the app locally.

## Contributing
Refer to [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on code style, branch naming, and pull requests.

## Changelog
See [CHANGELOG.md](CHANGELOG.md) for recent updates.
