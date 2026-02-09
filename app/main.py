"""
FastAPI Backend - Academic Stress Early Warning System

This is the main API server that wraps the rule-based risk engine
and exposes frontend-ready REST endpoints for the React Admin Dashboard.

Run with:
    uvicorn main:app --reload

Endpoints:
    GET  /students           - All students with basic risk info
    GET  /students/at-risk   - Moderate + High risk students (sorted)
    GET  /risk/{student_id}  - Full detail for one student
    POST /simulate/what-if   - What-if intervention simulation
"""

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from typing import List, Optional
import uvicorn

# Import our modules
from data_store import data_store
from risk_engine import what_if_simulation


# =============================================================================
# PYDANTIC RESPONSE MODELS
# =============================================================================

class StudentSummary(BaseModel):
    """Basic student info for table display."""
    studentId: int
    name: str
    email: str
    department: str
    year: int
    riskScore: int
    riskLevel: str
    anomalyScore: float


class AtRiskStudent(StudentSummary):
    """At-risk student with flag count."""
    flagCount: int


class Recommendation(BaseModel):
    """Single recommendation card data."""
    id: str
    icon: str
    title: str
    description: str
    priority: str


class TrendPoint(BaseModel):
    """Single point in stress trend timeline."""
    week: str
    score: int
    level: str


class StudentRiskDetail(BaseModel):
    """Full student risk profile for detail page."""
    studentId: int
    name: str
    email: str
    department: str
    year: int
    attendance: float
    lateSubmissions: int
    missedSubmissions: int
    workloadTasks: int
    riskScore: int
    riskLevel: str
    anomalyScore: float
    triggeredRules: List[str]
    recommendations: List[Recommendation]
    stressTrend: List[TrendPoint]


class DashboardStats(BaseModel):
    """Summary statistics for dashboard header."""
    totalStudents: int
    highRisk: int
    moderateRisk: int
    lowRisk: int
    averageRisk: float
    averageAnomaly: float


class AllStudentsResponse(BaseModel):
    """Response for GET /students."""
    students: List[StudentSummary]
    stats: DashboardStats


class WhatIfRequest(BaseModel):
    """Request body for what-if simulation."""
    student_id: int = Field(..., description="Student ID to simulate")
    fix_attendance: bool = Field(False, description="Simulate fixing attendance to 90%")
    fix_workload: bool = Field(False, description="Simulate reducing workload to baseline")


class WhatIfResponse(BaseModel):
    """Response for what-if simulation."""
    originalRisk: int
    originalLevel: str
    newRisk: int
    newLevel: str
    riskReduction: int
    reductionPercent: float
    explanation: str
    interventions: dict


# =============================================================================
# FASTAPI APP SETUP
# =============================================================================

app = FastAPI(
    title="Academic Stress Early Warning System API",
    description="Backend API for detecting and explaining student stress risk using rule-based intelligence.",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc"
)

# Enable CORS for frontend development
# Allows React dev server on localhost:3000, localhost:5173, etc.
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:3000",      # Create React App default
        "http://localhost:5173",      # Vite default
        "http://localhost:5174",      # Vite alternate
        "http://127.0.0.1:3000",
        "http://127.0.0.1:5173",
        "*"                           # Allow all for demo purposes
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"]
)


# =============================================================================
# API ENDPOINTS
# =============================================================================

@app.get("/", tags=["Health"])
async def root():
    """
    Health check endpoint.
    
    Frontend: Can be used to verify API is running.
    """
    return {
        "status": "healthy",
        "service": "Academic Stress Early Warning System",
        "version": "1.0.0",
        "studentsLoaded": len(data_store.get_all_students())
    }


@app.get(
    "/students", 
    response_model=AllStudentsResponse,
    tags=["Students"],
    summary="Get all students with risk summary"
)
async def get_all_students():
    """
    Returns ALL students with their risk scores and anomaly scores.
    
    **Frontend Usage:**
    - Render complete student table with sorting
    - Power the stats cards showing risk distribution
    - Enable search/filter across all students
    
    **Response includes:**
    - `students`: Array of all students with basic info
    - `stats`: Summary counts for dashboard header cards
    """
    students = data_store.get_all_students()
    stats = data_store.get_dashboard_stats()
    
    return AllStudentsResponse(
        students=[StudentSummary(**s) for s in students],
        stats=DashboardStats(**stats)
    )


@app.get(
    "/students/at-risk",
    response_model=List[AtRiskStudent],
    tags=["Students"],
    summary="Get at-risk students (Moderate + High)"
)
async def get_at_risk_students():
    """
    Returns only Moderate and High risk students, sorted by risk score DESC.
    
    **Frontend Usage:**
    - Power the main dashboard "At-Risk Students" table
    - Highest risk students appear first for immediate attention
    - Each row is clickable to navigate to detail page
    
    **Sorting:** Descending by riskScore (85 → 31)
    """
    at_risk = data_store.get_at_risk_students()
    return [AtRiskStudent(**s) for s in at_risk]


@app.get(
    "/risk/{student_id}",
    response_model=StudentRiskDetail,
    tags=["Risk Analysis"],
    summary="Get full risk detail for a student"
)
async def get_student_risk_detail(student_id: int):
    """
    Returns comprehensive risk profile for a single student.
    
    **Frontend Usage:**
    - Animate the circular risk gauge (0-100)
    - Display "Why This Student Was Flagged" panel with triggeredRules
    - Render stress trend line chart with stressTrend data
    - Show recommendation cards with actionable advice
    - Pre-fill the What-If Simulator with current values
    
    **Response Fields:**
    - `triggeredRules`: Array of human-readable rule explanations
    - `recommendations`: Array of cards with icon, title, description
    - `stressTrend`: 8-week history for Chart.js line graph
    """
    detail = data_store.get_student_risk_detail(student_id)
    
    if not detail:
        raise HTTPException(
            status_code=404, 
            detail=f"Student with ID {student_id} not found"
        )
    
    return StudentRiskDetail(**detail)


@app.post(
    "/simulate/what-if",
    response_model=WhatIfResponse,
    tags=["Simulation"],
    summary="Simulate intervention impact"
)
async def simulate_what_if(request: WhatIfRequest):
    """
    Simulate the impact of interventions on a student's risk score.
    
    **Frontend Usage:**
    - Power the "What-If Simulator" slider UI
    - Show real-time risk prediction as sliders change
    - Display risk reduction percentage and explanation
    
    **Request Body:**
    - `student_id`: The student to simulate
    - `fix_attendance`: If true, assume attendance improves to 90%
    - `fix_workload`: If true, assume workload reduces to baseline (10 tasks)
    
    **Response:**
    - `originalRisk`: Current risk score
    - `newRisk`: Predicted score after intervention
    - `riskReduction`: Points reduced
    - `explanation`: Human-readable impact description
    """
    student = data_store.get_student(request.student_id)
    
    if not student:
        raise HTTPException(
            status_code=404,
            detail=f"Student with ID {request.student_id} not found"
        )
    
    result = what_if_simulation(
        student,
        fix_attendance=request.fix_attendance,
        fix_workload=request.fix_workload
    )
    
    return WhatIfResponse(**result)


@app.get(
    "/stats",
    response_model=DashboardStats,
    tags=["Dashboard"],
    summary="Get dashboard summary statistics"
)
async def get_dashboard_stats():
    """
    Returns summary statistics for dashboard cards.
    
    **Frontend Usage:**
    - Render the 4 stat cards at top of dashboard
    - Show total, high risk, moderate risk, low risk counts
    - Display average risk across all students
    """
    return DashboardStats(**data_store.get_dashboard_stats())


# =============================================================================
# MAIN ENTRY POINT
# =============================================================================

if __name__ == "__main__":
    print("\n🚀 Starting Academic Stress Early Warning System API...")
    print("📍 API Docs: http://localhost:8000/docs")
    print("📍 Frontend: http://localhost:5173\n")
    
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=8000,
        reload=True,
        log_level="info"
    )
