# Offline-First Gamified STEM Learning Platform

🚀 A Progressive Web App (PWA) for rural schools that makes STEM subjects engaging through **mini-games, adaptive learning, and teacher analytics** — built with React, Phaser.js, Firebase, and Capacitor.

---

## 📚 Project Overview
- **Students**: Play interactive STEM games (quizzes, puzzles, simulations) even without internet.  
- **Teachers**: Track progress, mastery, and assignments via dashboards.  
- **Gamification**: Points, XP, streaks, badges, avatars, and class leaderboards.  
- **Offline-First**: IndexedDB + Service Workers for offline caching and sync.  
- **Multilingual**: Localized STEM content packs (English, Hindi, etc.).

---

## 🛠️ Tech Stack
**Frontend**
- React (TypeScript)
- Phaser.js (mini-games)
- TailwindCSS (UI)
- Chart.js / Recharts (analytics)
- i18next (multilingual content)

**Backend**
- Firebase Authentication (roles: student, teacher)
- Firebase Firestore (progress, assignments, events)
- Firebase Cloud Storage (content packs, assets)
- Firebase Cloud Functions (aggregation, leaderboards, conflict resolution)

**Offline Layer**
- Service Workers
- IndexedDB (Dexie.js)

**Mobile Deployment**
- Capacitor (wrap PWA into Android APK)

---

## ⚡ Getting Started

### 1. Clone the Repository
```bash
git clone https://github.com/PriyanshuYadav08/Offline_Gamified_IAPC.git
cd iapc-stem-platform/client
```

### 2. Contribution
PRs are welcome! For major changes, please open an issue first to discuss what you’d like to change.