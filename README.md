# Papaya Maturity Classification Mobile App

A cross-platform Flutter application for classifying and assessing Papaya fruit maturity stages (*Carica papaya*) through live camera capture and gallery upload, backed by optical color analysis and Firebase Realtime Database.

---

## 🌟 Key Features

- **4 Papaya Maturity Stages**:
  - **Stage 1 • Unripe** (Mature Green): Firm, crisp texture; ideal for cooking and pickling.
  - **Stage 2 • Ripening** (Turning / Breaker): Distinct yellow patches (16%–75%); breaker stage for transport.
  - **Stage 3 • Ripe** (Fully Ripe): Deep orange, juicy and sweet (>76% yellow); ready-to-eat fresh.
  - **Stage 4 • Overripe** (Senescent): Soft amber with dark freckles; best for purees, smoothies, and baking.

- **Computer Vision & Optical Color Classifier**:
  - Cross-platform image processing using in-engine pixel analysis (`dart:ui`) and TFLite support.
  - Generates confidence distributions across all 4 maturity phases.

- **Live Camera & Photo Upload**:
  - Instant live camera scanning and gallery selection with automatic fallbacks for Web/Desktop.
  - Cross-platform in-memory byte streaming without platform-specific filesystem blockers.

- **Interactive Analytics & History**:
  - Real-time cloud sync with Firebase Realtime Database.
  - Frequency charts and 7-day scan trend graphs (`fl_chart`).

- **Interactive Information & Guides**:
  - Botanical details, texture profiles, and harvesting guidelines for each maturity phase.
  - Cultivation region interactive maps (`flutter_map`).

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (>= 3.3.0)
- [Dart SDK](https://dart.dev/get-dart)
- Android Studio / VS Code / Chrome Browser

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/codebreaker43/CSC-Mobile-app.git
   cd CSC-Mobile-app
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the application**:
   - On Chrome (Web):
     ```bash
     flutter run -d chrome
     ```
   - On Android:
     ```bash
     flutter run -d android
     ```
   - On Windows:
     ```bash
     flutter run -d windows
     ```

---

## 📱 Tech Stack
- **Framework**: [Flutter](https://flutter.dev) (Dart)
- **Database**: [Firebase Realtime Database](https://firebase.google.com/products/realtime-database)
- **Charts & Maps**: `fl_chart`, `flutter_map`, `latlong2`
- **Animations & UI**: `animate_do`, `cupertino_icons`
- **Media**: `image_picker`, `screenshot`, `share_plus`

---

## 📄 License
This project is developed for academic and agricultural maturity evaluation purposes.