#  Money Tracker

A full-stack personal finance management application developed using **Flutter**, **ASP.NET Core Web API**, **Dapper ORM**, and **Microsoft SQL Server**. The application enables users to efficiently manage expenses, debts, monthly budgets, and personal notes through a clean and intuitive interface.

---

## 📌 Features

- 👤 User Registration & Login
- 💸 Expense Tracking
- 📅 Monthly Budget Management
- 💳 Debt Management
- 📝 Personal Notes
- 🔒 Secure RESTful APIs
- 📊 Dashboard with Financial Overview
- 📱 Cross-Platform Flutter Application

---

## 🛠️ Tech Stack

### Frontend
- Flutter
- Dart

### Backend
- ASP.NET Core Web API
- C#
- Dapper ORM

### Database
- Microsoft SQL Server

### Tools
- Visual Studio
- Visual Studio Code
- Git & GitHub

---

## 📂 Project Structure

```
Money_Tracker
│
├── money_backend
│   ├── Controllers
│   ├── Models
│   ├── Service
│   ├── Contract
│   ├── Program.cs
│   └── appsettings.json
│
├── money_tracker
│   ├── lib
│   ├── assets
│   ├── android
│   ├── ios
│   ├── web
│   └── pubspec.yaml
│
└── money_sql.sql
```

---

## 🚀 Installation

### Backend

```bash
git clone https://github.com/elsabaiju/Money_Tracker.git

cd Money_Tracker/money_backend/MoneyTracker

dotnet restore

dotnet run
```

---

### Frontend

```bash
cd Money_Tracker/money_tracker

flutter pub get

flutter run
```

---

## 🗄️ Database

1. Open SQL Server Management Studio.
2. Create a new database.
3. Execute the SQL script:

```
money_sql.sql
```

4. Update the connection string inside:

```
appsettings.json
```

---

## 🔑 API Modules

- User Authentication
- Expense Management
- Debt Management
- Monthly Budget
- Notes Management

---

## 🎯 Future Enhancements

- Export Reports (PDF/Excel)
- Charts & Analytics
- Notifications
- Cloud Database Integration
- AI-powered Expense Insights

---
