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
 ├── core/             # Config, themes, constants
 ├── auth/             # Login, signup, role management
 ├── student/          # Student dashboard, games, gamification
 │   ├── games/        # Flame games (quiz, puzzle, etc.)
 │   ├── models/       # XP, progress, badges
 │   ├── services/     # Game logic, sync
 │   └── widgets/
 ├── teacher/          # Teacher dashboard
 │   ├── analytics/    # Charts, reports
 │   ├── assignments/  # Quests & tasks
 │   └── widgets/
 ├── services/         # Firebase, Hive/Drift, notifications
 ├── localization/     # i18n JSONs
 └── utils/            # Helpers
```

---

### 1. Clone the Repository
```bash
git clone https://github.com/PriyanshuYadav08/Offline_Gamified_IAPC.git
cd Offline_Gamified_IAPC
```

### 2. Contribution
PRs are welcome! For major changes, please open an issue first to discuss what you’d like to change.