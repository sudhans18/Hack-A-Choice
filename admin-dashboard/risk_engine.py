import random
import numpy as np

# -----------------------------
# Rule-Based Stress Engine
# -----------------------------

def compute_risk(student):
    risk = 0
    reasons = []

    if student["attendance_2w"] < 75:
        risk += 20
        reasons.append("Attendance below 75% in last 2 weeks")

    if student["late_submissions"] >= 2:
        risk += 25
        reasons.append("Multiple late assignment submissions")

    if student["workload_spike_pct"] > 40:
        risk += 15
        reasons.append("Sudden workload spike (>40%)")

    if student["missing_assignment"]:
        risk += 25
        reasons.append("Missing assignment submission")

    if student["attendance_drop"] > 20:
        risk += 15
        reasons.append("Sharp attendance drop vs previous period")

    risk = min(100, risk)

    level = (
        "Low" if risk <= 30 else
        "Moderate" if risk <= 60 else
        "High"
    )

    return risk, level, reasons


def anomaly_score(student):
    score = 0
    if student["attendance_drop"] > 25:
        score += 1
    if student["late_submissions"] >= 3:
        score += 1
    if student["workload_spike_pct"] > 50:
        score += 1
    if student["missing_assignment"]:
        score += 1
    return score


def recommend(reasons):
    recs = []
    for r in reasons:
        if "Attendance" in r:
            recs.append("Schedule advisor check-in")
        if "late" in r:
            recs.append("Adopt weekly workload planning")
        if "workload" in r:
            recs.append("Rebalance academic schedule")
        if "Missing" in r:
            recs.append("Immediate academic follow-up")
    return list(set(recs))


def simulate_trend(base_risk):
    trend = []
    for _ in range(6):
        base_risk += random.randint(-8, 12)
        trend.append(max(0, min(100, base_risk)))
    return trend


def what_if_simulation(student, fix_attendance=False, fix_workload=False):
    modified = student.copy()

    if fix_attendance:
        modified["attendance_2w"] = min(95, modified["attendance_2w"] + 20)
        modified["attendance_drop"] = 0

    if fix_workload:
        modified["workload_spike_pct"] = 10

    original_risk, _, _ = compute_risk(student)
    new_risk, _, _ = compute_risk(modified)

    return {
        "original_risk": original_risk,
        "after_intervention_risk": new_risk,
        "risk_reduction": original_risk - new_risk
    }
