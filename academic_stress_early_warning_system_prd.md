# Academic Stress and Burnout Early Warning System (Prototype)

## 1. Problem Overview
Educational institutions typically detect student stress only after academic performance declines. This project proposes a **rule-based early warning system** that monitors behavioral academic signals and flags potential burnout risk early.

The prototype focuses on **interpretability, speed of implementation, and demo clarity** rather than production deployment.

---

## 2. Goals

### Primary Goals
- Detect early stress risk using academic behavior signals
- Provide explainable alerts (rule-based reasoning)
- Build a working dashboard + mobile interface
- Demonstrate risk detection using simulated data

### Non‑Goals (Hackathon Scope)
- Clinical diagnosis
- Real institutional integration
- Long‑term data storage architecture
- Privacy‑grade infrastructure

---

## 3. Users

### Student
- View workload trend
- See stress risk indicator
- Receive recommendations

### Faculty / Admin
- View at‑risk students list
- Monitor attendance/submission patterns

---

## 4. Core Idea
The system calculates a **Stress Risk Score (0–100)** using rules derived from:

- Attendance trend
- Assignment submission delay patterns
- Workload density
- Sudden behavioral change detection

The score triggers risk levels:
- 0–30 → Low
- 31–60 → Moderate
- 61–100 → High

---

## 5. Prototype Architecture

Frontend (Flutter)
↓
Backend API (FastAPI / Node)
↓
Rule Engine Service
↓
Database (Firebase / Mongo / SQLite)

Optional:
Simulated Data Generator

---

## 6. Data Model (Prototype)

### Student
- id
- name
- department

### AttendanceRecord
- studentId
- date
- present

### Assignment
- studentId
- dueDate
- submittedDate

### Workload
- studentId
- tasksPerWeek

---

## 7. Rule Engine Design

### Rule 1: Attendance Drop
If attendance < 75% over last 2 weeks
+20 risk

### Rule 2: Consecutive Late Submissions
If ≥2 late submissions
+25 risk

### Rule 3: Workload Spike
If workload increase >40%
+15 risk

### Rule 4: Missing Submission
If assignment not submitted
+25 risk

### Rule 5: Sudden Behavior Change
Attendance drop >20% compared to previous period
+15 risk

Cap score at 100.

---

## 8. API Design

### POST /ingest/attendance
### POST /ingest/assignment
### GET /risk/{studentId}
### GET /students/at-risk

---

## 9. UI Screens (Flutter)

Student App:
- Stress Score Card
- Workload Graph
- Attendance Trend
- Recommendations

Admin Dashboard:
- At‑risk students table
- Student detail page
- Rule explanation panel

---

## 10. Demo Flow

1. Load simulated semester dataset
2. Trigger rule engine
3. Dashboard shows flagged students
4. Click student → explanation of rules triggered
5. Mobile app shows student stress status

This demo is critical for judges.

---

## 11. Implementation Plan (24‑Hour Hackathon Friendly)

### Phase 1 — Setup (2 hours)
- Repo setup
- Firebase project
- Flutter scaffold
- Backend scaffold

### Phase 2 — Backend + Rules (5 hours)
- Student models
- Rule engine logic
- Risk scoring
- API endpoints

### Phase 3 — Dashboard (4 hours)
- Student list
- Risk indicator UI
- Graphs

### Phase 4 — Flutter App (4 hours)
- Stress score screen
- API integration

### Phase 5 — Simulation + Demo Prep (3 hours)
- Data generator script
- Demo dataset
- Presentation preparation

---

## 12. Work Split (Team of 4)

### AI Engineer
- Risk scoring rules implementation
- Behavior change detection logic
- Simulated dataset generator
- Recommendation mapping

### Full Stack Engineer 1
- Backend APIs
- Database schema
- Rule engine integration

### Full Stack Engineer 2
- Admin dashboard (React)
- Risk visualization
- Student detail page

### Flutter Developer
- Student mobile app
- API integration
- Stress indicator UI

---

## 13. Tech Stack (Prototype Optimized)

Backend: FastAPI
Frontend Dashboard: React
Mobile: Flutter
Database: Firebase Firestore
Charts: Chart.js

---

## 14. Novelty Elements for Hackathon

To stand out, include:

- Explainable rule triggers ("flagged due to attendance drop")
- Stress trend timeline
- Recommendation engine
- Behavioral change detection

Optional wow feature:
"What‑if simulator" for faculty.

---

## 15. Recommendation Engine (Simple Rules)

If attendance drop → suggest meeting advisor
If late submissions → suggest workload planning
If workload spike → suggest schedule balancing

---

## 16. Risks

- Over‑engineering rules
- UI taking too long
- Data simulation complexity

Keep rules simple.

---

## 17. Success Criteria

Prototype success =

- Risk score computed
- Students flagged
- Dashboard works
- Mobile app shows result
- Demo dataset proves detection

That’s enough to win a hackathon.

