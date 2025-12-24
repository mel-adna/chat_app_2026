# Chat 2026

A modern, real-time chat application built with Flutter and Firebase, featuring a clean architecture, secure authentication, and a stunning UI.

## Features

*   **Authentication**: Secure Google & Email/Password login.
*   **Real-time Messaging**: Instant chat with Firestore integration.
*   **Multimedia**: Send and receive images securely.
*   **Online Status**: Real-time "Online/Offline" indicators and green dots.
*   **Push Notifications**: Foregound alerts for new messages.
*   **Profile Management**: Edit display name and profile details.
*   **Settings**: Customizable user preferences.
*   **Modern UI**: Glassmorphism effects, smooth animations (Hero), and Dark Mode.

## Screenshots

| Login Screen | Home Screen | Chat Screen |
|:---:|:---:|:---:|
| ![Login](path/to/login_screenshot.png) | ![Home](path/to/home_screenshot.png) | ![Chat](path/to/chat_screenshot.png) |

## Tech Stack

*   **Framework**: [Flutter](https://flutter.dev/)
*   **Backend**: [Firebase](https://firebase.google.com/) (Auth, Firestore, Storage)
*   **State Management**: `flutter_bloc`
*   **Architecture**: Clean Architecture (Data, Domain, Presentation layers)

## Getting Started

### Prerequisites

*   Flutter SDK installed
*   Firebase Project created with Auth, Firestore, and Storage enabled.

### Setup

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/yourusername/chat_2026.git
    cd chat_2026
    ```

2.  **Add Firebase Configuration:**
    *   **Android**: Download `google-services.json` from Firebase Console and place it in `android/app/`.
    *   **iOS**: Download `GoogleService-Info.plist` and place it in `ios/Runner/`.

3.  **Environment Variables:**
    Create a `.env` file in the root directory (see `.env.example` if available) or configure:
    ```
    # Add any specific keys here
    ```

4.  **Install Dependencies:**
    ```bash
    flutter pub get
    ```

5.  **Run the App:**
    ```bash
    flutter run
    ```

## Security Note

This project uses `flutter_dotenv` for managing sensitive keys, and `.env` is excluded from version control. Ensure you configure your Firebase Security Rules strictly in production (e.g., `allow read, write: if request.auth != null;`).

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.

---
*Built with Flutter*
