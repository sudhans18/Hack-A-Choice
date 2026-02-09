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
    POST /ingest/attendance  - Ingest attendance data (NEW)
    POST /ingest/assignment  - Ingest assignment data (NEW)
    POST /reset              - Reset data for demo (NEW)
"""

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from typing import List, Optional, Literal
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
# INGESTION REQUEST/RESPONSE MODELS (NEW)
# =============================================================================

class AttendanceIngestRequest(BaseModel):
    """
    Request body for ingesting attendance data.
    
    Simulates receiving real-time attendance updates from
    the student information system.
    """
    student_id: int = Field(..., description="Student ID to update")
    attendance_rate: float = Field(
        ..., 
        ge=0, 
        le=100,
        description="New attendance percentage (0-100)"
    )


class AttendanceIngestResponse(BaseModel):
    """Response after attendance ingestion."""
    success: bool
    studentId: int
    event: str
    previousAttendance: float
    newAttendance: float
    previousRiskScore: int
    newRiskScore: int
    riskLevel: str
    riskChange: int
    triggeredRules: List[str]


class AssignmentIngestRequest(BaseModel):
    """
    Request body for ingesting assignment submission data.
    
    Simulates receiving real-time assignment data from
    the learning management system.
    """
    student_id: int = Field(..., description="Student ID to update")
    status: Literal["on_time", "late", "missing"] = Field(
        ...,
        description="Submission status: 'on_time', 'late', or 'missing'"
    )
    task_count_change: int = Field(
        0,
        description="Change to workload (+1 for new task, -1 for completed)"
    )


class SubmissionChange(BaseModel):
    """Tracks before/after for a submission metric."""
    previous: int
    current: int


class AssignmentIngestResponse(BaseModel):
    """Response after assignment ingestion."""
    success: bool
    studentId: int
    event: str
    submissionStatus: str
    lateSubmissions: SubmissionChange
    missedSubmissions: SubmissionChange
    workloadTasks: SubmissionChange
    previousRiskScore: int
    newRiskScore: int
    riskLevel: str
    riskChange: int
    triggeredRules: List[str]


class ResetResponse(BaseModel):
    """Response after data reset."""
    success: bool
    message: str
    studentsLoaded: int
    stats: DashboardStats


class IngestionEvent(BaseModel):
    """A single ingestion event from the log."""
    type: str
    studentId: int
    timestamp: str
    riskChange: int


# =============================================================================
# FASTAPI APP SETUP
# =============================================================================

app = FastAPI(
    title="Academic Stress Early Warning System API",
    description="""
    Backend API for detecting and explaining student stress risk using rule-based intelligence.
    
    ## Features
    - **Rule-based risk scoring** with explainable AI
    - **Real-time data ingestion** for attendance and assignments
    - **What-if simulation** for intervention planning
    - **Dashboard-ready JSON** for React frontend
    
    ## Rule Engine
    The risk score (0-100) is computed using these rules:
    - Attendance < 75% → +20 points
    - ≥2 late submissions → +25 points
    - Workload spike > 40% → +15 points
    - Missing assignment → +25 points
    - Attendance drop > 20% → +15 points
    """,
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc"
)

# Enable CORS for frontend development
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:3000",
        "http://localhost:5173",
        "http://localhost:5174",
        "http://127.0.0.1:3000",
        "http://127.0.0.1:5173",
        "*"
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"]
)


# =============================================================================
# HEALTH & INFO ENDPOINTS
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


# =============================================================================
# STUDENT DATA ENDPOINTS
# =============================================================================

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


@app.get(
    "/stats",
    response_model=DashboardStats,
    tags=["Dashboard"],
    summary="Get dashboard summary statistics"
)
async def get_dashboard_stats():
    """Returns summary statistics for dashboard cards."""
    return DashboardStats(**data_store.get_dashboard_stats())


# =============================================================================
# INGESTION ENDPOINTS (NEW)
# =============================================================================

@app.post(
    "/ingest/attendance",
    response_model=AttendanceIngestResponse,
    tags=["Data Ingestion"],
    summary="Ingest attendance data for a student"
)
async def ingest_attendance(request: AttendanceIngestRequest):
    """
    Ingest a new attendance record for a student.
    
    **Use Case:**
    Simulates receiving real-time attendance data from the
    student information system. Updates the student's risk
    score immediately and returns the change.
    
    **Example:**
    ```json
    {
      "student_id": 1001,
      "attendance_rate": 72.5
    }
    ```
    
    **Frontend Usage:**
    - Show real-time risk updates
    - Trigger notifications when risk increases
    - Update dashboard in real-time (with polling or WebSocket)
    """
    result = data_store.ingest_attendance(
        student_id=request.student_id,
        attendance_rate=request.attendance_rate
    )
    
    if not result:
        raise HTTPException(
            status_code=404,
            detail=f"Student with ID {request.student_id} not found"
        )
    
    return AttendanceIngestResponse(**result)


@app.post(
    "/ingest/assignment",
    response_model=AssignmentIngestResponse,
    tags=["Data Ingestion"],
    summary="Ingest assignment submission data"
)
async def ingest_assignment(request: AssignmentIngestRequest):
    """
    Ingest a new assignment submission event for a student.
    
    **Use Case:**
    Simulates receiving real-time assignment data from the
    learning management system. Tracks late/missing submissions
    and workload changes.
    
    **Submission Status Values:**
    - `on_time`: Assignment submitted on time (no risk change)
    - `late`: Assignment submitted late (+1 late count)
    - `missing`: Assignment not submitted (+1 missing count)
    
    **Example:**
    ```json
    {
      "student_id": 1001,
      "status": "late",
      "task_count_change": 1
    }
    ```
    
    **Frontend Usage:**
    - Trigger alerts when patterns emerge (e.g., 2+ late)
    - Update student detail page in real-time
    """
    result = data_store.ingest_assignment(
        student_id=request.student_id,
        status=request.status,
        task_count_change=request.task_count_change
    )
    
    if not result:
        raise HTTPException(
            status_code=404,
            detail=f"Student with ID {request.student_id} not found"
        )
    
    return AssignmentIngestResponse(**result)


# =============================================================================
# SIMULATION ENDPOINTS
# =============================================================================

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


# =============================================================================
# DEMO/ADMIN ENDPOINTS
# =============================================================================

@app.post(
    "/reset",
    response_model=ResetResponse,
    tags=["Admin"],
    summary="Reset all data to initial state"
)
async def reset_data():
    """
    Reset all student data to fresh simulated state.
    
    **Use Case:**
    Useful for demo purposes to start with a clean slate.
    All ingestion history is cleared and new random students
    are generated.
    
    **Frontend Usage:**
    - "Reset Demo" button in admin panel
    - Clear all modifications and start fresh
    """
    result = data_store.reset_data()
    return ResetResponse(
        success=result["success"],
        message=result["message"],
        studentsLoaded=result["studentsLoaded"],
        stats=DashboardStats(**result["stats"])
    )


@app.get(
    "/events",
    tags=["Admin"],
    summary="Get recent ingestion events"
)
async def get_ingestion_events(limit: int = 50):
    """
    Get recent data ingestion events.
    
    **Frontend Usage:**
    - Activity log panel
    - Real-time event feed
    """
    return {
        "events": data_store.get_ingestion_log(limit),
        "count": len(data_store.get_ingestion_log(limit))
    }


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
