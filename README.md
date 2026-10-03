# Intario AI — AI-Powered Interior Design & Real-Time AR Platform

<p align="center">
  <img src="assets/images/logo.png" alt="Intario AI Logo" width="120" height="120" />
</p>

<p align="center">
  <strong>Next-Generation Interior & Exterior Architecture Powered by Generative Vision & Spatial Computing</strong>
</p>

<p align="center">
  <a href="#-key-features"><img src="https://img.shields.io/badge/Flutter-3.24+-02569B?logo=flutter&logoColor=white" alt="Flutter" /></a>
  <a href="#-key-features"><img src="https://img.shields.io/badge/Dart-3.5+-0175C2?logo=dart&logoColor=white" alt="Dart" /></a>
  <a href="#-unity-ar-modules"><img src="https://img.shields.io/badge/Unity-6%20%2F%202022.3-000000?logo=unity&logoColor=white" alt="Unity" /></a>
  <a href="#-unity-ar-modules"><img src="https://img.shields.io/badge/Google-ARCore-4285F4?logo=google&logoColor=white" alt="Google ARCore" /></a>
  <a href="#-ai-engine"><img src="https://img.shields.io/badge/AI%20Engine-Decor8%20AI-6C5CE7" alt="Decor8 AI Engine" /></a>
  <a href="#-state-management"><img src="https://img.shields.io/badge/State-Riverpod%202.x-0553B1" alt="Riverpod" /></a>
  <a href="#-cloud-backend"><img src="https://img.shields.io/badge/Backend-Firebase-FFCA28?logo=firebase&logoColor=black" alt="Firebase" /></a>
  <a href="#license"><img src="https://img.shields.io/badge/License-MIT-green.svg" alt="License: MIT" /></a>
</p>

---

## 📌 Executive Summary

**Intario AI** is a state-of-the-art mobile application that bridges generative artificial intelligence and native spatial computing to democratize interior and exterior architectural styling. 

Built with **Flutter** and integrated with **Unity AR** via native Android channels, Intario AI enables homeowners, designers, and real estate professionals to photograph actual physical rooms and instantly generate photorealistic redesigns across **50 interior design styles**, visualize exterior landscaping across **31 garden styles**, and interactively test materials, wall decor, and furniture in real physical space at **true 1:1 metric scale**.

---

## 🚀 Key Features

### 🧠 Generative AI Pipeline (Powered by Decor8 AI Engine)
* **Room Redesign**: Re-render fully furnished spaces into 50+ contemporary and historic styles while preserving core architectural lines.
* **Virtual Staging**: Turn empty, unfurnished rooms into fully furnished, photorealistic living spaces.
* **Style Transfer**: Upload a reference design photo or moodboard to adapt colors, materials, and textures onto your room.
* **Custom Prompt Synthesis**: Use natural language prompts (with guidance scale and inference step tuning) for bespoke styling.
* **Kitchen & Bathroom Remodel**: Specialized structural remodeling for cabinetry, tilework, vanities, and fixtures.
* **Wall Paint & Cabinet Color Visualizer**: Realistic wall and kitchen cabinet repainting using exact HEX codes or branded swatches.
* **Exterior Landscaping**: Front yard, backyard, and side yard redesign across 31 curated landscaping styles.
* **Seasonal & Thematic Styling**: 7 seasonal themes (e.g., Christmas, Halloween, Autumn, Spring) for holiday transformations.
* **Interactive Before/After Comparison**: Real-time interactive split slider widget for instant transformation inspection.

### 👓 Real-Time AR Spatial Computing (Powered by Unity & Google ARCore)
* **AR Wall Color Visualizer**:
  * Point-based procedural 3D wall mesh generation (`WallMeshGenerator.cs`).
  * Real-time wallpaper texture mapping, reticle aiming, and surface area/perimeter measurement.
* **AR Wall Decor Visualizer**:
  * Vertical plane detection for hanging artwork, framed city maps, paintings, and wall lamps.
  * 6-DOF touch manipulation (translation, surface-snapped rotation, and scale).
* **AR Furniture Visualizer**:
  * Horizontal ground-plane tracking for 3D furniture models (classic living sets, dining sets, coffee tables, accent chairs, luxury sofas).
  * 1:1 true-scale physical dimension rendering, 360° rotational control, collision-aware placement, and elevation anchoring.

---

## 📊 Verified System Capabilities

| Capability Domain | Verified Count | Scope & Details |
| :--- | :---: | :--- |
| **Architectural Room Types** | **31** | Living Room, Bedroom, Dining Room, Kitchen, Home Office, Balcony, Sunroom, etc. |
| **Interior Design Styles** | **50** | Modern, Minimalist, Japandi, Scandinavian, Industrial, Mid-Century, Bohemian, etc. |
| **Curated Color Palettes** | **20** | Professional 4-color harmonious swatches with hex mapping |
| **Landscaping & Garden Styles**| **31** | Japanese Zen, English Cottage, Mediterranean, Modern Minimalist, Desert Xeriscape, etc. |
| **Seasonal & Holiday Themes** | **7** | Christmas, Autumn/Fall Season, Spring, Summer, Winter, Halloween, Lunar New Year |
| **Core AI Generation Modes** | **12** | Redesign, Staging, Style Transfer, Custom Prompt, Remodel, Color, Landscaping, Themes |
| **Interactive AR Modules** | **3** | Procedural Wall Color, 6-DOF Wall Decor, 1:1 Metric Furniture Placement |

---

## 🏗️ System Architecture

```
┌────────────────────────────────────────────────────────────────────────┐
│                        USER MOBILE DEVICE                              │
│                                                                        │
│   ┌────────────────────────────────────────────────────────────────┐   │
│   │                 INTARIO AI FLUTTER APPLICATION                 │   │
│   │  • Material 3 Dark/Light UI  • Riverpod State Management       │   │
│   │  • GoRouter Navigation       • Before/After Interactive Slider │   │
│   │  • Dio HTTP Gateway          • Haptic Touch Engine             │   │
│   └───────────────┬───────────────────────────────┬────────────────┘   │
│                   │                               │                    │
│     (MethodChannel Native Intent)                 │ (HTTPS REST API)   │
│                   ▼                               ▼                    │
│   ┌────────────────────────────────┐   ┌───────────────────────────┐   │
│   │       UNITY 6 AR ENGINE        │   │     FIREBASE STORAGE      │   │
│   │  • Google ARCore XR Subsystem  │   │  • High-Res Photo Storage │   │
│   │  • Horizontal Plane Tracking   │   │  • CDN Image Asset URLs   │   │
│   │  • Vertical Wall Mesh Gen      │   └─────────────┬─────────────┘   │
│   │  • 6-DOF Touch Gesture Engine  │                 │                 │
│   │  • Metric 1:1 3D Prefabs       │                 ▼                 │
│   └────────────────────────────────┘   ┌───────────────────────────┐   │
│                                        │     DECOR8 AI ENGINE      │   │
│                                        │  • Latent Diffusion Models│   │
│                                        │  • Multi-Style Transfer   │   │
│                                        │  • Photorealistic Output  │   │
│                                        └───────────────────────────┘   │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 📁 Repository Structure

```text
intario-ai/
├── intario_ai/                      # Flutter Mobile Application
│   ├── android/                     # Android Native Host & AR MethodChannels
│   ├── assets/                      # UI Icons, Brand Assets, Room Placeholders
│   ├── lib/
│   │   ├── config/                  # API Configurations & Endpoints
│   │   ├── constants/               # Room types, styles, palettes, themes
│   │   ├── models/                  # WizardState, ProjectModel
│   │   ├── providers/               # Riverpod Notifiers (Wizard, History, Theme)
│   │   ├── screens/
│   │   │   ├── flows/               # AI Generation Wizard Flow Screens
│   │   │   ├── home/                # Category Dashboard & Quick Actions
│   │   │   ├── premium_ar/          # Native Unity AR Launcher Cards
│   │   │   └── projects/            # Design History & Before/After Preview
│   │   ├── services/                # Decor8Service, FirebaseStorageService
│   │   ├── theme/                   # Obsidian Dark & Clean Light Design Tokens
│   │   ├── utils/                   # EnumNormalizer, HexValidator, AppHaptics
│   │   └── widgets/                 # BeforeAfterSlider, FlowHeader, GlassCard
│   └── pubspec.yaml                 # Flutter Dependencies
│
└── unity_ar_modules/                # Unity Spatial Computing Source Projects
    ├── wall_color_visualizer/       # AR Wall Color & Mesh Generator
    │   ├── Assets/Scripts/          # WallMeshGenerator.cs, ARExitController.cs
    │   └── ProjectSettings/        # Package: com.Intario_Ai.arwallcolor
    │
    ├── wall_decor_visualizer/       # AR Wall Art & Sconce Visualizer
    │   ├── Assets/Prefabs/          # 3D Paintings, Wall Decor Models
    │   └── ProjectSettings/        # Package: com.Intario_Ai.arwalldecor
    │
    └── furniture_visualizer/        # AR 1:1 Scale Furniture Visualizer
        ├── Assets/Prefabs/          # Living, Dining, Accent 3D Models
        └── ProjectSettings/        # Package: com.Intario_Ai.ARFurnitur
```

---

## 🛠️ Tech Stack & Dependencies

| Layer | Technology | Version | Purpose |
| :--- | :--- | :---: | :--- |
| **Mobile Core** | Flutter / Dart | 3.24+ / 3.5+ | Cross-platform UI, Material 3, animations |
| **State Management** | Flutter Riverpod | 2.5+ | Reactive state, wizard lifecycle, caching |
| **Navigation** | GoRouter | 14.x | Declarative routing & flow navigation |
| **Networking** | Dio | 5.x | Resilient REST communication & timeouts |
| **Cloud Storage** | Firebase Storage | Latest | High-resolution image upload & CDN URLs |
| **Spatial Engine** | Unity 6 / URP | 6000.x / 2022.3 | Real-time AR rendering pipeline |
| **AR Subsystem** | Google ARCore | 5.x / XR Plugin | Sub-centimeter vertical & horizontal plane tracking |
| **Generative AI** | Decor8 AI Engine | Cloud REST | Diffusion-based photorealistic interior staging |

---

## ⚡ Getting Started

### 1. Prerequisites
* **Flutter SDK**: `^3.24.0` ([Install Flutter](https://docs.flutter.dev/get-started/install))
* **Android Studio**: Ladybug / Koala with Android SDK 34+ and NDK
* **Unity Hub**: Unity `6000.0.x` or `2022.3 LTS` with Android Build Support (OpenJDK, Android SDK & NDK Tools)
* **Physical Device**: ARCore-supported Android device with Developer Mode enabled

### 2. Clone the Repository
```bash
git clone https://github.com/YOUR_USERNAME/intario-ai.git
cd intario-ai/intario_ai
```

### 3. Configure API Credentials
Edit `lib/config/api_config.dart`:
```dart
const String apiKey  = 'YOUR_DECOR8_API_KEY'; // Obtain from prod-app.decor8.ai
const String baseUrl = 'https://api.decor8.ai';
```

### 4. Configure Firebase
Place your `google-services.json` in:
```text
intario_ai/android/app/google-services.json
```

### 5. Install Dependencies & Run Flutter App
```bash
flutter pub get
flutter run
```

---

## 🎮 Building & Exporting Unity AR Modules

Each AR visualizer is configured as a standalone ARCore-enabled native Android package launched seamlessly from Flutter via `MethodChannel`:

1. Open the desired project in **Unity Hub** (`wall_color_visualizer`, `wall_decor_visualizer`, or `furniture_visualizer`).
2. Verify Build Settings:
   * **Platform**: Android
   * **Texture Compression**: ASTC
   * **Scripting Backend**: IL2CPP
   * **Target Architectures**: ARM64
3. Verify Package Identifiers:
   * **Wall Color**: `com.Intario_Ai.arwallcolor`
   * **Wall Decor**: `com.Intario_Ai.arwalldecor`
   * **Furniture**: `com.Intario_Ai.ARFurnitur`
4. Click **Build APK** and install onto your physical testing device alongside Intario AI.

---

## 🎨 Design System

Intario AI utilizes a custom dark-first glassmorphism design language:

* **Primary Electric Blue**: `#4A6CF7` (Dark Theme) / `#1B3EBF` (Light Theme)
* **Accent Mint**: `#00C9A7` (Active Generative States)
* **Accent Cyan**: `#00D7B6` (Gradients & Highlights)
* **Obsidian Canvas**: `#0E1116`
* **Glass Card Surface**: `#131720` with subtle border opacity
* **Typography**: Clean typography hierarchy leveraging Google Fonts (`Inter` & `SF Pro Display`)

---

## 🎓 Academic FYP Information

* **Project Title**: Intario AI — AI-Powered Interior Design & Real-Time AR Platform
* **Degree**: Bachelor of Science in Computer Science / Software Engineering
* **Project Type**: Final Year Project (FYP)

---

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.