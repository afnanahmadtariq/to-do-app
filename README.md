# To Do App

A Flutter-based task management application integrated with Firebase for cloud storage and real-time synchronization.

## Features

- **Task Management**: Create, edit, delete, and mark tasks as complete
- **Project Organization**: Group tasks into projects for better organization
- **Tagging System**: Assign tags to tasks for easy categorization
- **Search Functionality**: Quickly find tasks using the search feature
- **Firebase Integration**: Secure authentication, Firestore for data persistence, and Firebase Storage for media
- **Cross-Platform**: Runs on Android, iOS, Web, Windows, Linux, and macOS

## Screenshots

<!-- Add app screenshots here -->

![Home Screen](screenshots/home_screen.png)
![Add Task Screen](screenshots/add_task_screen.png)
![Project Detail Screen](screenshots/project_detail_screen.png)
![Task Detail Screen](screenshots/task_detail_screen.png)

## Installation

### Prerequisites

- Flutter SDK (version 3.0 or higher)
- Dart SDK
- Firebase account and project

### Setup

1. **Clone the repository**:
   ```bash
   git clone https://github.com/afnanahmadtariq/to-do-app.git
   cd to-do-app
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**:
   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Enable Authentication, Firestore, and Storage
   - Add your app to Firebase (Android/iOS/Web as needed)
   - Download and place `google-services.json` (Android) or configure accordingly
   - Update `lib/firebase_options.dart` with your Firebase config

4. **Run the app**:
   ```bash
   flutter run
   ```

## Usage

- **Sign up/Login**: Use Firebase Authentication to create an account or log in
- **Create Projects**: Organize your tasks into different projects
- **Add Tasks**: Create tasks with titles, descriptions, due dates, and tags
- **Manage Tasks**: Edit, complete, or delete tasks as needed
- **Search**: Use the search feature to find specific tasks quickly

## 📱 Download Latest Version

Get the latest Android build directly:

[![Download APK](https://img.shields.io/badge/Download-Latest%20APK-3DDC84?style=for-the-badge&logo=android&logoColor=white)](https://github.com/afnanahmadtariq/to-do-app/releases/latest/download/app-release.apk)

> **Note**: This link always points to the most recent release. For older versions please check releases.

## Credits

- **Design Inspiration**: [UI/UX Design for Mobile Task Management App](https://dribbble.com/shots/21236436-UI-UX-Design-for-Mobile-Task-Management-App) on Dribbble

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

