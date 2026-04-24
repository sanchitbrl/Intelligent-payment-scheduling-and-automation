# eSewa Payment Scheduler

<div align="center">
  <h3>Intelligent Payment Scheduling and Automation</h3>
  <p>A comprehensive mobile application for tracking, scheduling, and automating your recurring payments.</p>
</div>

## Demo Video

*(https://www.youtube.com/watch?v=ClFuyU0xJjI)*

## Features

- **Smart Payment Scheduling**: Easily schedule recurring payments with flexible frequencies (Daily, Weekly, Monthly, Quarterly).
- **AI-Powered Suggestions**: Automatically analyzes your payment history to identify and suggest potential recurring payment schedules.
- **Timely Reminders**: Get notified days in advance before your payments are due.
- **Categorization**: Organize your payments into categories like Utilities, Subscriptions, Education, Loans, and Insurance.
- **Comprehensive History**: Keep track of all your past transactions, both paid and skipped.
- **Secure Authentication**: Secure login and account management.

## Tech Stack

### Frontend (Mobile App)
- **Framework**: [Flutter](https://flutter.dev/)
- **State Management**: Provider
- **Networking**: HTTP
- **Local Storage**: Shared Preferences

### Backend (API)
- **Runtime**: [Node.js](https://nodejs.org/)
- **Framework**: Express.js
- **Database ORM**: [Prisma](https://www.prisma.io/)
- **Database**: PostgreSQL
- **Security**: JWT Authentication & bcryptjs

## Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.0.0 or higher)
- [Node.js](https://nodejs.org/) (v16+)
- [PostgreSQL](https://www.postgresql.org/) database

### Backend Setup

1. Navigate to the backend directory:
   ```bash
   cd backend
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Set up environment variables:
   Create a `.env` file in the `backend` directory and add your configurations:
   ```env
   DATABASE_URL="postgresql://user:password@localhost:5432/esewa_db"
   JWT_SECRET="your_super_secret_jwt_key"
   PORT=3000
   ```

4. Initialize the database:
   ```bash
   npx prisma db push
   ```
   *(Optional) You can also run `npm run seed` if you have dummy data configured.*

5. Start the backend server:
   ```bash
   npm run dev
   ```

### Frontend Setup

1. Navigate to the frontend directory:
   ```bash
   cd frontend
   ```

2. Install Flutter packages:
   ```bash
   flutter pub get
   ```

3. Run the application:
   ```bash
   flutter run
   ```
   *Make sure you have an emulator running or a physical device connected.*

## App Structure

- **Dashboard**: Get a quick overview of your upcoming payments and smart AI suggestions.
- **Schedule**: View, manage, and add all your active recurring payments.
- **History**: Detailed log of past paid or skipped payments.
- **Reminders**: A dedicated hub for alerts on payments that are due very soon.

## Contributing

Contributions, issues, and feature requests are welcome! Feel free to check the issues page if you want to contribute.
