"""
Data Store - In-Memory Data Management

This module handles:
- Initialization of simulated student data
- In-memory storage for the prototype
- Data access patterns for API endpoints

For production, this would be replaced with a proper database layer.
"""

from typing import Dict, List, Optional
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
        self._initialize_data()
    
    def _initialize_data(self):
        """Generate 50 students and compute their risk profiles."""
        print("🔄 Initializing data store with 50 simulated students...")
        
        students = generate_students(50)
        
        for student in students:
            self._students[student.student_id] = student
            
            # Pre-compute risk data for faster API responses
            risk_score, reasons = compute_risk(student)
            
            self._risk_cache[student.student_id] = {
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
        
        print(f"✅ Data store initialized with {len(self._students)} students")
        self._print_summary()
    
    def _print_summary(self):
        """Print summary of risk distribution."""
        high = sum(1 for d in self._risk_cache.values() if d["riskLevel"] == "High")
        moderate = sum(1 for d in self._risk_cache.values() if d["riskLevel"] == "Moderate")
        low = sum(1 for d in self._risk_cache.values() if d["riskLevel"] == "Low")
        
        print(f"   📊 Risk Distribution: High={high}, Moderate={moderate}, Low={low}")
    
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
