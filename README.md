<div align="center">

# 📝 Notein Free

**Fast, Private, and Fully Offline Mobile Notepad Application**

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev/)
[![Version](https://img.shields.io/badge/Version-1.0.0-green?style=for-the-badge)](#)
[![License](https://img.shields.io/badge/License-MIT-blue?style=for-the-badge)](#)

*Your data is yours. Notein Free ensures complete privacy by keeping everything on your device.*

</div>

---

## 📖 Overview

**Notein Free** is a beautifully designed, modern Flutter application aimed at providing a seamless note-taking experience. Unlike traditional note apps, Notein Free requires **no internet connection** and **no account creation**, ensuring that your personal thoughts, daily tasks, and calendar events remain 100% private and secure on your device.

## ✨ Key Features

- 📝 **Smooth Note Editing**: Faster, cleaner text and checklist editors with auto-save on back.
- ✅ **Smart Checklists**: Manage tasks and daily to-dos with interactive checklist notes.
- 📅 **Calendar & Reminders**: Add reminders from the editor and review them in a dedicated calendar view.
- 🎨 **Keep-Inspired UI/UX**: Search-first home layout, quick actions, note filters, and calmer visual hierarchy.
- 🔤 **Font System**: Choose between multiple app-wide font presets and adjust overall font scale.
- 🗂️ **Archive & Trash Management**: Dedicated archive/trash flows with restore and permanent delete actions.
- 🔒 **Stronger App Lock**: PIN is hashed instead of stored in plain text, with optional auto-lock on background.
- ⚡ **Offline First**: Everything stays local on-device with no account requirement.

## 🛠️ Technology Stack

- **Framework**: [Flutter](https://flutter.dev/) (Cross-platform UI toolkit)
- **Language**: [Dart](https://dart.dev/)
- **State Management**: `provider` (Scalable and predictable state management)
- **Local Storage**: `shared_preferences` (persistent local storage)
- **Security Utilities**: `crypto` (PIN hashing)
- **Icons**: `cupertino_icons` & Material Icons
- **Date Utilities**: `intl` & `table_calendar`

## 📁 Project Structure

```text
lib/
├── main.dart            # Application entry point
├── screens/             # UI views (home, editors, archive/trash, calendar, etc.)
├── widgets/             # Reusable custom UI components
├── theme/               # App theme + font configuration
├── models/              # Data structures and classes
├── providers/           # State management logic
└── utils/               # Helper functions and constants
```

## 🚀 Getting Started

Follow these instructions to get a copy of the project up and running on your local machine for development and testing.

### Prerequisites

Ensure you have the following installed:
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Version 3.2.0 or higher)
- Android Studio or Visual Studio Code
- An Android/iOS Emulator or a physical device connected

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/bhedanikhilkumar-code/NoteinFree.git
   ```

2. **Navigate to the project directory:**
   ```bash
   cd NoteinFree
   ```

3. **Fetch the dependencies:**
   ```bash
   flutter pub get
   ```

4. **Run the application:**
   ```bash
   flutter run
   ```

## 🤝 Contributing

Contributions are what make the open-source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

Distributed under the MIT License. This project is open-source and free for personal and educational use.

## 💬 Support & Contact

If you have any questions, suggestions, or issues, please feel free to open an issue in the repository.

<div align="center">
  <i>Crafted with ❤️ for the open-source community.</i>
</div>
