# WhereShot - AI-Powered Photo Location Detection

WhereShot is a minimal, cross-platform mobile application that uses OpenAI's O3 model to detect the location where a photo was taken.

## Features

- **Photo Analysis**: Upload or capture a photo and get its location detected using AI
- **Location Results**: View the detected location name and coordinates (when available)
- **Map View**: See the detected location on an interactive map
- **History**: Save and browse your detection history
- **Credit System**: Pay-per-detection with a credit system
- **In-App Purchases**: Buy credit packs through RevenueCat

## Tech Stack

- **Flutter**: Cross-platform UI framework
- **Riverpod**: State management with code generation
- **GoRouter**: Navigation and routing
- **Firebase**: Backend services (Firestore, Storage)
- **OpenAI O3**: Image analysis API
- **RevenueCat**: In-app purchase management
- **Google Maps**: Map visualization

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Firebase project
- OpenAI API key
- RevenueCat account
- Google Maps API key

### Setup

1. Clone the repository:
```bash
git clone https://github.com/yourusername/whereshot.git
cd whereshot
```

2. Install dependencies:
```bash
flutter pub get
```

3. Generate the necessary files:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

4. Configure Firebase:
```bash
flutterfire configure
```

5. Create a `.env` file in the project root with your API keys:
```
OPENAI_API_KEY=your_openai_api_key
REVENUECAT_API_KEY=your_revenuecat_api_key
GOOGLE_MAPS_API_KEY=your_google_maps_api_key
```

6. Run the app:
```bash
flutter run
```

## Architecture

The app follows a clean architecture approach with:

- **Models**: Data classes for the app
- **Providers**: Riverpod state management
- **Services**: Business logic and API interactions
- **Widgets**: Reusable UI components
- **Screens**: Main app screens

## Credit System

- Each location detection costs 1 credit
- Credits can be purchased in packs:
  - 5 Credits - $1.99
  - 15 Credits - $4.49
  - 50 Credits - $11.99

## License

This project is licensed under the MIT License - see the LICENSE file for details.
