"""
Risk Engine - Core Logic for Academic Stress Detection

This module contains the rule-based stress detection engine that:
- Generates simulated student data
- Computes risk scores based on behavioral rules
- Detects anomalies in student behavior
- Provides explainable recommendations
- Simulates stress trends and what-if scenarios

DO NOT MODIFY THE RULE LOGIC - This is the single source of truth.
"""

import random
from typing import Dict, List, Tuple, Any
from dataclasses import dataclass
from datetime import datetime, timedelta


# =============================================================================
# DATA MODELS
# =============================================================================

@dataclass
class Student:
    """Represents a student with academic behavior metrics."""
    student_id: int
    name: str
    email: str
    department: str
    year: int
    attendance_rate: float          # 0-100
    late_submissions: int           # count
    missed_submissions: int         # count
    workload_tasks: int             # weekly task count
    previous_attendance: float      # for behavior change detection
    previous_workload: int          # for workload spike detection


# =============================================================================
# DATA GENERATION (50 Students)
# =============================================================================

DEPARTMENTS = [
    "Computer Science", "Data Science", "Mechanical Engineering",
    "Electrical Engineering", "Business Administration", "Psychology",
    "Chemistry", "Biomedical Engineering", "Mathematics", "Physics"
]

FIRST_NAMES = [
    "Alex", "Sarah", "Marcus", "Emily", "James", "Priya", "David", "Olivia",
    "Michael", "Emma", "Daniel", "Sophia", "Ethan", "Isabella", "Noah",
    "Mia", "Liam", "Ava", "Lucas", "Charlotte", "Mason", "Amelia", "Logan",
    "Harper", "Benjamin", "Evelyn", "Elijah", "Abigail", "Oliver", "Ella",
    "Jacob", "Scarlett", "Aiden", "Grace", "Jack", "Lily", "Henry", "Aria",
    "Sebastian", "Chloe", "Owen", "Zoey", "Samuel", "Penelope", "Ryan",
    "Layla", "Nathan", "Riley", "Leo", "Nora"
]

LAST_NAMES = [
    "Thompson", "Chen", "Johnson", "Rodriguez", "Wilson", "Patel", "Kim",
    "Martinez", "Brown", "Davis", "Miller", "Garcia", "Anderson", "Taylor",
    "Thomas", "Moore", "Jackson", "White", "Harris", "Martin", "Clark",
    "Lewis", "Robinson", "Walker", "Young", "Allen", "King", "Wright",
    "Scott", "Torres", "Nguyen", "Hill", "Flores", "Green", "Adams",
    "Nelson", "Baker", "Hall", "Rivera", "Campbell", "Mitchell", "Carter",
    "Roberts", "Gomez", "Phillips", "Evans", "Turner", "Diaz", "Parker", "Cruz"
]


def generate_students(n: int = 50) -> List[Student]:
    """
    Generate n simulated students with realistic academic behavior data.
    
    Creates a diverse mix of:
    - High performers (low risk)
    - Moderate performers (some flags)
    - Struggling students (high risk)
    """
    students = []
    
    for i in range(n):
        student_id = 1000 + i
        first_name = FIRST_NAMES[i % len(FIRST_NAMES)]
        last_name = LAST_NAMES[i % len(LAST_NAMES)]
        name = f"{first_name} {last_name}"
        email = f"{first_name.lower()}.{last_name.lower()[0]}@university.edu"
        
        # Determine student profile type (affects data generation)
        profile = random.choices(
            ["excellent", "good", "moderate", "struggling", "critical"],
            weights=[0.15, 0.25, 0.30, 0.20, 0.10]
        )[0]
        
        if profile == "excellent":
            attendance = random.uniform(92, 100)
            late_subs = 0
            missed_subs = 0
            workload = random.randint(6, 10)
            prev_attendance = attendance + random.uniform(-2, 2)
            prev_workload = workload
        elif profile == "good":
            attendance = random.uniform(82, 94)
            late_subs = random.randint(0, 1)
            missed_subs = 0
            workload = random.randint(8, 12)
            prev_attendance = attendance + random.uniform(-5, 5)
            prev_workload = workload - random.randint(0, 2)
        elif profile == "moderate":
            attendance = random.uniform(72, 85)
            late_subs = random.randint(1, 3)
            missed_subs = random.randint(0, 1)
            workload = random.randint(10, 15)
            prev_attendance = attendance + random.uniform(5, 15)
            prev_workload = workload - random.randint(2, 5)
        elif profile == "struggling":
            attendance = random.uniform(62, 78)
            late_subs = random.randint(2, 5)
            missed_subs = random.randint(1, 2)
            workload = random.randint(14, 20)
            prev_attendance = attendance + random.uniform(10, 20)
            prev_workload = workload - random.randint(4, 8)
        else:  # critical
            attendance = random.uniform(50, 68)
            late_subs = random.randint(4, 8)
            missed_subs = random.randint(2, 4)
            workload = random.randint(16, 25)
            prev_attendance = attendance + random.uniform(15, 30)
            prev_workload = workload - random.randint(6, 12)
        
        students.append(Student(
            student_id=student_id,
            name=name,
            email=email,
            department=random.choice(DEPARTMENTS),
            year=random.randint(1, 4),
            attendance_rate=round(attendance, 1),
            late_submissions=late_subs,
            missed_submissions=missed_subs,
            workload_tasks=workload,
            previous_attendance=round(max(0, min(100, prev_attendance)), 1),
            previous_workload=max(1, prev_workload)
        ))
    
    return students


# =============================================================================
# RULE-BASED RISK COMPUTATION
# =============================================================================

def compute_risk(student: Student) -> Tuple[int, List[str]]:
    """
    Compute risk score (0-100) based on academic behavior rules.
    
    RULES (DO NOT MODIFY):
    - Rule 1: Attendance < 75% → +20 points
    - Rule 2: ≥2 late submissions → +25 points
    - Rule 3: Workload increase >40% → +15 points
    - Rule 4: Any missed submission → +25 points
    - Rule 5: Attendance drop >20% from previous → +15 points
    
    Returns:
        Tuple of (risk_score, list_of_triggered_rules)
    """
    score = 0
    reasons = []
    
    # Rule 1: Attendance Drop
    if student.attendance_rate < 75:
        score += 20
        reasons.append(f"Attendance below 75% (current: {student.attendance_rate}%)")
    
    # Rule 2: Consecutive Late Submissions
    if student.late_submissions >= 2:
        score += 25
        reasons.append(f"Multiple late submissions ({student.late_submissions} assignments)")
    
    # Rule 3: Workload Spike
    if student.previous_workload > 0:
        workload_increase = ((student.workload_tasks - student.previous_workload) 
                            / student.previous_workload) * 100
        if workload_increase > 40:
            score += 15
            reasons.append(f"Workload increased by {workload_increase:.0f}%")
    
    # Rule 4: Missing Submissions
    if student.missed_submissions > 0:
        score += 25
        reasons.append(f"Missing {student.missed_submissions} assignment(s)")
    
    # Rule 5: Sudden Behavior Change
    attendance_drop = student.previous_attendance - student.attendance_rate
    if attendance_drop > 20:
        score += 15
        reasons.append(f"Sudden attendance drop ({attendance_drop:.0f}% decrease)")
    
    # Cap at 100
    return min(100, score), reasons


def get_risk_level(score: int) -> str:
    """
    Convert numeric score to risk level category.
    
    Thresholds:
    - 0-30: Low
    - 31-60: Moderate
    - 61-100: High
    """
    if score <= 30:
        return "Low"
    elif score <= 60:
        return "Moderate"
    else:
        return "High"


# =============================================================================
# ANOMALY DETECTION
# =============================================================================

def anomaly_score(student: Student) -> float:
    """
    Calculate anomaly score (0-1) based on deviation from expected behavior.
    
    Higher score = more anomalous behavior detected.
    Uses weighted combination of:
    - Attendance deviation from 85% baseline
    - Late submission ratio
    - Workload deviation from 10 tasks baseline
    """
    # Attendance anomaly (deviation from 85% expected)
    attendance_anomaly = abs(85 - student.attendance_rate) / 85
    
    # Late submission anomaly (expected: 0-1 per term)
    late_anomaly = min(1.0, student.late_submissions / 5)
    
    # Workload anomaly (deviation from 10 tasks baseline)
    workload_anomaly = abs(student.workload_tasks - 10) / 15
    
    # Weighted combination
    score = (
        0.4 * attendance_anomaly +
        0.35 * late_anomaly +
        0.25 * min(1.0, workload_anomaly)
    )
    
    return round(min(1.0, score), 3)


# =============================================================================
# RECOMMENDATION ENGINE
# =============================================================================

def recommend(reasons: List[str]) -> List[Dict[str, str]]:
    """
    Generate actionable recommendations based on triggered risk factors.
    
    Maps each risk factor to specific, actionable advice.
    """
    recommendations = []
    
    for reason in reasons:
        reason_lower = reason.lower()
        
        if "attendance" in reason_lower and "below" in reason_lower:
            recommendations.append({
                "id": "REC_ATTENDANCE",
                "icon": "👥",
                "title": "Schedule Advisor Meeting",
                "description": "Book a session with your academic advisor to discuss attendance patterns and identify any barriers to class participation.",
                "priority": "high"
            })
        
        if "late submission" in reason_lower:
            recommendations.append({
                "id": "REC_DEADLINE",
                "icon": "📅",
                "title": "Deadline Management Workshop",
                "description": "Attend a time management workshop or use a calendar system to track assignment due dates 48 hours in advance.",
                "priority": "medium"
            })
        
        if "workload" in reason_lower:
            recommendations.append({
                "id": "REC_WORKLOAD",
                "icon": "⚖️",
                "title": "Workload Balancing",
                "description": "Work with your advisor to evaluate current course load and consider redistributing tasks or dropping non-essential activities.",
                "priority": "medium"
            })
        
        if "missing" in reason_lower:
            recommendations.append({
                "id": "REC_RECOVERY",
                "icon": "📚",
                "title": "Academic Recovery Plan",
                "description": "Contact your professors to discuss make-up options and create a catch-up plan for missed assignments.",
                "priority": "high"
            })
        
        if "sudden" in reason_lower or "drop" in reason_lower:
            recommendations.append({
                "id": "REC_CHECKIN",
                "icon": "💬",
                "title": "Wellness Check-In",
                "description": "Consider visiting the campus counseling center to discuss any personal challenges affecting your academic performance.",
                "priority": "high"
            })
    
    # Add general recommendation if no specific ones
    if not recommendations:
        recommendations.append({
            "id": "REC_MAINTAIN",
            "icon": "✅",
            "title": "Keep Up the Good Work!",
            "description": "You're doing well! Continue your current study habits and maintain your healthy academic balance.",
            "priority": "low"
        })
    
    # Remove duplicates while preserving order
    seen = set()
    unique_recs = []
    for rec in recommendations:
        if rec["id"] not in seen:
            seen.add(rec["id"])
            unique_recs.append(rec)
    
    return unique_recs


# =============================================================================
# TREND SIMULATION
# =============================================================================

def simulate_trend(base_risk: int, weeks: int = 8) -> List[Dict[str, Any]]:
    """
    Simulate historical stress trend leading to current risk level.
    
    Creates a realistic progression showing how risk evolved over time.
    """
    trend = []
    
    # Calculate starting point (lower than current)
    start_risk = max(10, base_risk - random.randint(20, 40))
    
    # Generate smooth progression with some variance
    for week in range(weeks):
        progress = week / (weeks - 1) if weeks > 1 else 1
        
        # Interpolate with some noise
        week_score = start_risk + (base_risk - start_risk) * progress
        week_score += random.randint(-5, 5)
        week_score = max(0, min(100, int(week_score)))
        
        trend.append({
            "week": f"Week {week + 1}",
            "score": week_score,
            "level": get_risk_level(week_score)
        })
    
    # Ensure last week matches current risk
    trend[-1]["score"] = base_risk
    trend[-1]["level"] = get_risk_level(base_risk)
    
    return trend


# =============================================================================
# WHAT-IF SIMULATION
# =============================================================================

def what_if_simulation(
    student: Student,
    fix_attendance: bool = False,
    fix_workload: bool = False
) -> Dict[str, Any]:
    """
    Simulate the impact of interventions on student's risk score.
    
    Shows predicted risk reduction if:
    - fix_attendance: Attendance improves to 90%
    - fix_workload: Workload reduces to baseline (10 tasks)
    
    Returns:
        Dict with original risk, new risk, reduction, and explanation
    """
    # Calculate original risk
    original_score, original_reasons = compute_risk(student)
    
    # Create modified student copy
    modified_attendance = 90.0 if fix_attendance else student.attendance_rate
    modified_workload = 10 if fix_workload else student.workload_tasks
    modified_prev_attendance = modified_attendance if fix_attendance else student.previous_attendance
    
    modified_student = Student(
        student_id=student.student_id,
        name=student.name,
        email=student.email,
        department=student.department,
        year=student.year,
        attendance_rate=modified_attendance,
        late_submissions=student.late_submissions,
        missed_submissions=student.missed_submissions,
        workload_tasks=modified_workload,
        previous_attendance=modified_prev_attendance,
        previous_workload=student.previous_workload
    )
    
    # Calculate new risk
    new_score, new_reasons = compute_risk(modified_student)
    
    # Build explanation
    explanations = []
    if fix_attendance and modified_attendance > student.attendance_rate:
        explanations.append(
            f"Improving attendance from {student.attendance_rate}% to 90% removes attendance-related flags"
        )
    if fix_workload and modified_workload < student.workload_tasks:
        explanations.append(
            f"Reducing workload from {student.workload_tasks} to 10 tasks normalizes workload stress"
        )
    
    reduction = original_score - new_score
    
    return {
        "originalRisk": original_score,
        "originalLevel": get_risk_level(original_score),
        "newRisk": new_score,
        "newLevel": get_risk_level(new_score),
        "riskReduction": reduction,
        "reductionPercent": round((reduction / original_score * 100) if original_score > 0 else 0, 1),
        "explanation": " | ".join(explanations) if explanations else "No changes applied",
        "interventions": {
            "fixedAttendance": fix_attendance,
            "fixedWorkload": fix_workload
        }
    }
