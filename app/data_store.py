"""
Data Store - In-Memory Data Management

This module handles:
- Initialization of simulated student data
- In-memory storage for the prototype
- Data access patterns for API endpoints
- Real-time data ingestion and updates

For production, this would be replaced with a proper database layer.
"""

from typing import Dict, List, Optional
from datetime import datetime
from risk_engine import (
    Student, 
    generate_students, 
    compute_risk, 
    anomaly_score,
    get_risk_level,
    recommend,
    simulate_trend
)


class DataStore:
    """
    In-memory data store for student risk data.
    
    Initializes with 50 simulated students and pre-computes
    risk scores for fast API responses.
    """
    
    def __init__(self):
        """Initialize the data store with simulated student data."""
        self._students: Dict[int, Student] = {}
        self._risk_cache: Dict[int, dict] = {}
        self._ingestion_log: List[dict] = []  # Track ingested events
        self._initialize_data()
    
    def _initialize_data(self):
        """Generate 50 students and compute their risk profiles."""
        print("🔄 Initializing data store with 50 simulated students...")
        
        students = generate_students(50)
        
        for student in students:
            self._add_student(student)
        
        print(f"✅ Data store initialized with {len(self._students)} students")
        self._print_summary()
    
    def _add_student(self, student: Student):
        """Add a student and compute their risk profile."""
        self._students[student.student_id] = student
        self._refresh_risk_cache(student.student_id)
    
    def _refresh_risk_cache(self, student_id: int):
        """Recompute and cache risk data for a student."""
        student = self._students.get(student_id)
        if not student:
            return
        
        risk_score, reasons = compute_risk(student)
        
        self._risk_cache[student_id] = {
            "studentId": student.student_id,
            "name": student.name,
            "email": student.email,
            "department": student.department,
            "year": student.year,
            "attendance": student.attendance_rate,
            "lateSubmissions": student.late_submissions,
            "missedSubmissions": student.missed_submissions,
            "workloadTasks": student.workload_tasks,
            "riskScore": risk_score,
            "riskLevel": get_risk_level(risk_score),
            "anomalyScore": anomaly_score(student),
            "triggeredRules": reasons,
            "recommendations": recommend(reasons),
            "stressTrend": simulate_trend(risk_score)
        }
    
    def _print_summary(self):
        """Print summary of risk distribution."""
        high = sum(1 for d in self._risk_cache.values() if d["riskLevel"] == "High")
        moderate = sum(1 for d in self._risk_cache.values() if d["riskLevel"] == "Moderate")
        low = sum(1 for d in self._risk_cache.values() if d["riskLevel"] == "Low")
        
        print(f"   📊 Risk Distribution: High={high}, Moderate={moderate}, Low={low}")
    
    # =========================================================================
    # INGESTION METHODS (NEW)
    # =========================================================================
    
    def ingest_attendance(self, student_id: int, attendance_rate: float) -> dict:
        """
        Ingest a new attendance record for a student.
        
        Used by: POST /ingest/attendance
        
        This simulates receiving real-time attendance data from 
        the student information system.
        
        Args:
            student_id: The student's unique ID
            attendance_rate: New attendance percentage (0-100)
        
        Returns:
            dict with updated risk info and change summary
        """
        student = self._students.get(student_id)
        if not student:
            return None
        
        # Store previous values for comparison
        old_attendance = student.attendance_rate
        old_cache = self._risk_cache.get(student_id, {})
        old_score = old_cache.get("riskScore", 0)
        
        # Update the student record
        # Move current attendance to previous for behavior change detection
        student = Student(
            student_id=student.student_id,
            name=student.name,
            email=student.email,
            department=student.department,
            year=student.year,
            attendance_rate=attendance_rate,
            late_submissions=student.late_submissions,
            missed_submissions=student.missed_submissions,
            workload_tasks=student.workload_tasks,
            previous_attendance=old_attendance,
            previous_workload=student.previous_workload
        )
        self._students[student_id] = student
        
        # Recompute risk
        self._refresh_risk_cache(student_id)
        new_cache = self._risk_cache[student_id]
        
        # Log the ingestion event
        event = {
            "type": "attendance",
            "studentId": student_id,
            "timestamp": datetime.now().isoformat(),
            "oldValue": old_attendance,
            "newValue": attendance_rate,
            "riskChange": new_cache["riskScore"] - old_score
        }
        self._ingestion_log.append(event)
        
        return {
            "success": True,
            "studentId": student_id,
            "event": "attendance_updated",
            "previousAttendance": old_attendance,
            "newAttendance": attendance_rate,
            "previousRiskScore": old_score,
            "newRiskScore": new_cache["riskScore"],
            "riskLevel": new_cache["riskLevel"],
            "riskChange": new_cache["riskScore"] - old_score,
            "triggeredRules": new_cache["triggeredRules"]
        }
    
    def ingest_assignment(
        self, 
        student_id: int, 
        status: str,  # "on_time", "late", "missing"
        task_count_change: int = 0
    ) -> dict:
        """
        Ingest a new assignment submission event for a student.
        
        Used by: POST /ingest/assignment
        
        This simulates receiving real-time assignment data from
        the learning management system.
        
        Args:
            student_id: The student's unique ID
            status: One of "on_time", "late", "missing"
            task_count_change: Change to workload (+1 for new task, -1 for completed)
        
        Returns:
            dict with updated risk info and change summary
        """
        student = self._students.get(student_id)
        if not student:
            return None
        
        # Store previous values
        old_cache = self._risk_cache.get(student_id, {})
        old_score = old_cache.get("riskScore", 0)
        old_late = student.late_submissions
        old_missed = student.missed_submissions
        old_workload = student.workload_tasks
        
        # Update based on submission status
        new_late = old_late
        new_missed = old_missed
        new_workload = max(1, old_workload + task_count_change)
        
        if status == "late":
            new_late = old_late + 1
        elif status == "missing":
            new_missed = old_missed + 1
        
        # Create updated student record
        student = Student(
            student_id=student.student_id,
            name=student.name,
            email=student.email,
            department=student.department,
            year=student.year,
            attendance_rate=student.attendance_rate,
            late_submissions=new_late,
            missed_submissions=new_missed,
            workload_tasks=new_workload,
            previous_attendance=student.previous_attendance,
            previous_workload=old_workload
        )
        self._students[student_id] = student
        
        # Recompute risk
        self._refresh_risk_cache(student_id)
        new_cache = self._risk_cache[student_id]
        
        # Log the ingestion event
        event = {
            "type": "assignment",
            "studentId": student_id,
            "timestamp": datetime.now().isoformat(),
            "status": status,
            "taskChange": task_count_change,
            "riskChange": new_cache["riskScore"] - old_score
        }
        self._ingestion_log.append(event)
        
        return {
            "success": True,
            "studentId": student_id,
            "event": "assignment_recorded",
            "submissionStatus": status,
            "lateSubmissions": {"previous": old_late, "current": new_late},
            "missedSubmissions": {"previous": old_missed, "current": new_missed},
            "workloadTasks": {"previous": old_workload, "current": new_workload},
            "previousRiskScore": old_score,
            "newRiskScore": new_cache["riskScore"],
            "riskLevel": new_cache["riskLevel"],
            "riskChange": new_cache["riskScore"] - old_score,
            "triggeredRules": new_cache["triggeredRules"]
        }
    
    def reset_data(self) -> dict:
        """
        Reset all data to fresh simulated state.
        
        Used by: POST /reset
        Useful for demo purposes to start fresh.
        """
        self._students.clear()
        self._risk_cache.clear()
        self._ingestion_log.clear()
        self._initialize_data()
        
        return {
            "success": True,
            "message": "Data store reset to initial state",
            "studentsLoaded": len(self._students),
            "stats": self.get_dashboard_stats()
        }
    
    def get_ingestion_log(self, limit: int = 50) -> List[dict]:
        """Get recent ingestion events."""
        return self._ingestion_log[-limit:][::-1]  # Most recent first
    
    # =========================================================================
    # PUBLIC API METHODS
    # =========================================================================
    
    def get_all_students(self) -> List[dict]:
        """
        Get all students with basic risk info.
        
        Used by: GET /students
        Frontend: Renders full student table
        """
        return [
            {
                "studentId": data["studentId"],
                "name": data["name"],
                "email": data["email"],
                "department": data["department"],
                "year": data["year"],
                "riskScore": data["riskScore"],
                "riskLevel": data["riskLevel"],
                "anomalyScore": data["anomalyScore"]
            }
            for data in self._risk_cache.values()
        ]
    
    def get_at_risk_students(self) -> List[dict]:
        """
        Get only Moderate and High risk students, sorted by risk score DESC.
        
        Used by: GET /students/at-risk
        Frontend: Powers the main dashboard at-risk table
        """
        at_risk = [
            {
                "studentId": data["studentId"],
                "name": data["name"],
                "email": data["email"],
                "department": data["department"],
                "year": data["year"],
                "riskScore": data["riskScore"],
                "riskLevel": data["riskLevel"],
                "anomalyScore": data["anomalyScore"],
                "flagCount": len(data["triggeredRules"])
            }
            for data in self._risk_cache.values()
            if data["riskLevel"] in ["Moderate", "High"]
        ]
        
        # Sort by risk score descending (highest risk first)
        return sorted(at_risk, key=lambda x: x["riskScore"], reverse=True)
    
    def get_student_risk_detail(self, student_id: int) -> Optional[dict]:
        """
        Get full risk detail for a single student.
        
        Used by: GET /risk/{student_id}
        Frontend: Powers the student detail page with:
        - Animated risk gauge
        - Rule explanations
        - Trend chart
        - Recommendation cards
        """
        return self._risk_cache.get(student_id)
    
    def get_student(self, student_id: int) -> Optional[Student]:
        """
        Get raw student object for what-if simulations.
        
        Used internally by simulation endpoints.
        """
        return self._students.get(student_id)
    
    def get_dashboard_stats(self) -> dict:
        """
        Get summary statistics for dashboard header.
        
        Used by: GET /students (stats section)
        Frontend: Powers the stats cards at top of dashboard
        """
        all_data = list(self._risk_cache.values())
        
        return {
            "totalStudents": len(all_data),
            "highRisk": sum(1 for d in all_data if d["riskLevel"] == "High"),
            "moderateRisk": sum(1 for d in all_data if d["riskLevel"] == "Moderate"),
            "lowRisk": sum(1 for d in all_data if d["riskLevel"] == "Low"),
            "averageRisk": round(
                sum(d["riskScore"] for d in all_data) / len(all_data) if all_data else 0, 
                1
            ),
            "averageAnomaly": round(
                sum(d["anomalyScore"] for d in all_data) / len(all_data) if all_data else 0,
                3
            )
        }


# =============================================================================
# SINGLETON INSTANCE
# =============================================================================

# Create global instance to be imported by main.py
data_store = DataStore()
