# Setup and Development

## Prerequisites
- Flutter SDK (>= 3.0.0)
- Dart SDK
- Android Studio / Xcode for emulators and building

## Installation

1. Clone the repository:
   ```bash
   git clone <repo-url>
   cd zconnect-driver-customer-app
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Configure the environment:
   Copy `.env.example` to `.env` and fill in any required variables.

## Running the App
To run on a connected device or emulator:
```bash
flutter run
```

If testing the Odoo backend on an Android emulator via localhost, remember to port forward:
```bash
adb reverse tcp:8070 tcp:8070
```
