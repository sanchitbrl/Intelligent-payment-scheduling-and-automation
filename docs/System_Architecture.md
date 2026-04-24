# eSewa Scheduler - System Architecture & Organization

## Overview
The eSewa Scheduler is a standalone Flutter application designed for managing and automating payment scheduling. 
It follows a standard single-page app architecture where the entire application runs locally on the user's device.

## System Architecture

### Frontend (User Interface)
The frontend is built using **Flutter** and **Dart**. It provides a responsive and interactive user interface for the user to:
* View their dashboard with payment summaries.
* Add, edit, skip, or delete scheduled payments.
* Receive alerts for overdue or upcoming payments.

The state management is handled by the **Provider** package, which acts as the glue between the database and the UI. It listens for changes in the database and updates the UI accordingly.

### Backend
There is **no remote backend or external API server** for this prototype application. All the backend logic (like calculating due dates, managing reminders, returning active payments) is currently handled directly within the Flutter application's services (e.g., `PaymentProvider` and `DatabaseService`).

### Database
The database is **entirely local to the device** it runs on, utilizing **SQLite** through the `sqflite` (and `sqflite_common_ffi` for desktop environments) package.
* **Location:** The database is an SQLite file named `esewa_scheduler.db`, saved in the device's application documents directory.
* **Structure:** It currently uses local tables like `payments` (to store the scheduled items) and `payment_history` (to track paid or skipped entries).

## File System Organization

```text
lib/
├── main.dart
├── models/
│   └── payment.dart
├── screens/
│   ├── add_payment_screen.dart
│   ├── dashboard_screen.dart
│   ├── edit_payment_screen.dart
│   ├── reminders_screen.dart
│   └── schedule_screen.dart
├── services/
│   ├── database_service.dart
│   └── payment_provider.dart
└── widgets/
    ├── app_theme.dart
    └── payment_card.dart
```

## Detailed File Descriptions

### Core System
* **`lib/main.dart`**: The entry point of the Flutter application. It initializes the database components (`sqflite_common_ffi` for desktop platforms), sets up the app-wide state management using `ChangeNotifierProvider`, defines the main shell, and configures the bottom navigation bar.

### Models
* **`lib/models/payment.dart`**: Defines the data structure of a `Payment`. Contains all the core business logic, formulas for calculating days until due, standard classifications through Enums (`PaymentFrequency`, `PaymentCategory`), and conversion methods for turning SQLite data maps into structured Dart objects.

### Services (The Local Backend)
* **`lib/services/database_service.dart`**: Acts as the Data Access Layer (DAL). Responsibilities include creating the database file and tables on first start, and handling CRUD operations (inserting, updating, deleting, and fetching items) directly using SQLite.
* **`lib/services/payment_provider.dart`**: The central state manager for the app. It communicates with the `DatabaseService` to fetch/modify data, caches it in memory, and triggers updates (`notifyListeners()`) so the UI screens refresh dynamically when the underlying data changes.

### Screens (Pages)
* **`lib/screens/dashboard_screen.dart`**: The primary home page. Displays high-level analytics, overdue alerts, and the most immediate upcoming payments.
* **`lib/screens/add_payment_screen.dart`**: Contains the form functionality to schedule a new payment.
* **`lib/screens/edit_payment_screen.dart`**: Contains the form to update existing scheduled payments.
* **`lib/screens/reminders_screen.dart`**: Shows a targeted list of payments that are specifically due within the next 14 days.
* **`lib/screens/schedule_screen.dart`**: A comprehensive list showing all scheduled payments registered within the system.

### Shared Widgets
* **`lib/widgets/app_theme.dart`**: Serves as a centralized repository for app styling, storing custom colors, typography, and unified Material 3 theme configurations.
* **`lib/widgets/payment_card.dart`**: A reusable UI component that visually represents a single payment's information, category, progress bar showing time until due, and contextual action buttons (Pay, Edit, Skip, Delete).

### Configuration Files
* **`pubspec.yaml`**: The Flutter project configuration. Defines dependencies (like `provider`, `intl`, `sqflite`) and app metadata.
* **`analysis_options.yaml`**: Controls the static code analyzer rules and linting behavior.
