# Offline-First Gamified STEM Learning Platform (Flutter)

🚀 A Flutter app for rural schools that makes STEM subjects engaging through **mini-games, adaptive learning, and teacher analytics** — built with Flutter, Flame, Firebase, and modern offline-first architecture.

---

## 📚 Project Overview
- **Students**: Play interactive STEM games (quizzes, puzzles, simulations) even without internet.
- **Teachers**: Track progress, mastery, and assignments via dashboards.
- **Gamification**: Points, XP, streaks, badges, avatars, and class leaderboards.
- **Offline-First**: Hive/Drift (local DB), background sync, and offline caching.
- **Multilingual**: Localized STEM content packs (English, Hindi, etc.).

---


## 🛠️ Tech Stack (Flutter App)
**Frontend (App):** Flutter (Dart)
**Game Engine:** Flame (mini-games, animations)
**UI Components:** Material 3 + Riverpod/Bloc (state management)
**Offline Storage:** Hive / Drift (SQLite wrapper)
**Backend:** Firebase (Auth, Firestore, Storage, Cloud Functions)
**Multilingual:** Flutter Intl / easy_localization
**Charts:** fl_chart (teacher dashboards)
**Notifications:** Firebase Cloud Messaging

---

## 📁 Directory Structure

```
lib/
 ├── main.dart
 ├── firebase_options.dart
 ├── auth/
 │   ├── auth.dart
 ├── dashboard/          
 │   ├── dashboard_page.dart
 │   ├── teacher_dashboard.dart
 ├── profile/          
 │   ├── edit_profile.dart    
 │   ├── user_profile.dart  
 ├── services/          
 │   ├── firebase_services.dart
 ├── student_functions/          
 │   ├── live_quizzes.dart    
 │   ├── quiz_attempt.dart
 │   ├── quiz_result.dart
 ├── teacher_functions/          
 │   ├── create_quiz.dart    
 │   ├── quiz_analytics.dart
 │   ├── students_in_class.dart    
 │   ├── teacher_options.dart 
```

---

### 1. Clone the Repository
```bash
git clone https://github.com/PriyanshuYadav08/Offline_Gamified_IAPC.git
cd Offline_Gamified_IAPC
```

### 2. Contribution
PRs are welcome! For major changes, please open an issue first to discuss what you’d like to change.