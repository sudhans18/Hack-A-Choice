# COGNIS: Academic Stress Early Warning System

> **Detecting burnout before it happens.** A rule-based early warning system that monitors behavioral academic signals to flag student stress risk early.

---

## 🌟 Overview

Educational institutions typically detect student stress only after academic performance declines. **COGNIS** proposes a proactive solution that analyzes real-time academic behavior—like attendance drops and submission delays—to calculate an explainable **Stress Risk Score (0-100)**.

---

## 🏗️ Project Architecture

The system consists of three main components working in harmony:

1.  **Backend (FastAPI)**: The brain of the system. It houses the Rule Engine, manages the data store, and exposes REST endpoints.
2.  **Admin Dashboard (React)**: A professional interface for faculty and administrators to monitor student health, view "At-Risk" lists, and perform "What-if" simulations.
3.  **Mobile App (Flutter)**: A personalized student portal where individuals can track their stress levels, view workload graphs, and receive tailored recommendations.

```mermaid
graph TD
    A[Student Mobile App - Flutter] <--> B(FastAPI Backend)
    C[Admin Dashboard - React] <--> B
    B --> D{Rule Engine}
    D --> E[Risk Level: Low/Mod/High]
    B --> F[(Simulated Data Store)]
```

---

### 🛠️ Key Features

- **Predictive Intelligence Lab (What-If Simulator)**: High-fidelity simulation environment with granular range sliders for:
    - Attendance Rate (%)
    - Weekly Workload (Tasks)
    - Late & Missed Submissions
- **Liquid-Smooth Feedback**: Zero-latency Risk Meter and Gauge that react instantly to student metric adjustments.
- **Explainable Rule Fusion**: Real-time natural language explanations for every rule triggered or removed (e.g., "✓ Removed: Attendance below 75%").
- **Admin Dashboard**: Real-time risk heatmaps, student analytics, and intervention tracking.
- **ML + Rule Fusion**: Combines pre-trained ML models with a robust, domain-expert rule engine for high precision.
- **Stress Trend Visualization**: 8-week history tracking using interactive line charts.

---

## 🚀 Getting Started

### 1. Prerequisites
- Python 3.9+
- Node.js & npm
- Flutter SDK

### 2. Backend Setup
```bash
# Navigate to root
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r app/requirements.txt
python app/main.py
```
*API docs available at: `http://localhost:8000/docs`*

### 3. Admin Dashboard Setup
```bash
cd admin-dashboard
npm install
npm run dev
```

### 4. Mobile App (Flutter) Setup
```bash
cd stress_monitor
flutter pub get
flutter run
```

---

## 👥 Contributors

This project was built with ❤️ by:

| Name | GitHub | LinkedIn |
| :--- | :--- | :--- |
| **Rohith Kanna S** | [Rohithkannas](https://github.com/Rohithkannas) | [LinkedIn](https://www.linkedin.com/in/rohith4510/) |
| **Sudhan S** | [sudhans18](https://github.com/sudhans18) | [LinkedIn](https://www.linkedin.com/in/sudhan18/) |

---

## 📜 License

This project is licensed under the MIT License.
