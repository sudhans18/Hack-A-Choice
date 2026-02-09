/**
 * API Service Layer
 * 
 * Connects to the FastAPI backend for the Academic Stress Early Warning System.
 * Base URL: http://localhost:8000
 */

const API_BASE_URL = 'http://localhost:8000';

/**
 * GET /students/at-risk
 * Fetches all students who have been flagged with risk indicators
 * Sorted by risk score (highest first)
 * @returns {Promise<Array>} List of at-risk students
 */
export const getAtRiskStudents = async () => {
    try {
        const response = await fetch(`${API_BASE_URL}/students/at-risk`);
        if (!response.ok) throw new Error('Failed to fetch at-risk students');

        const data = await response.json();

        // Transform to frontend format
        return data.map(student => ({
            id: String(student.studentId),
            name: student.name,
            email: student.email,
            department: student.department,
            year: student.year,
            riskScore: student.riskScore,
            triggeredRules: [], // Will be fetched in detail view
        }));
    } catch (error) {
        console.error('API Error:', error);
        throw error;
    }
};

/**
 * GET /risk/{studentId}
 * Fetches detailed risk profile for a specific student
 * @param {string} studentId - The student's unique ID
 * @returns {Promise<Object|null>} Student risk profile or null if not found
 */
export const getStudentRisk = async (studentId) => {
    try {
        const response = await fetch(`${API_BASE_URL}/risk/${studentId}`);
        if (!response.ok) {
            if (response.status === 404) return null;
            throw new Error('Failed to fetch student risk');
        }

        const data = await response.json();

        // Transform to frontend format
        return {
            id: String(data.studentId),
            name: data.name,
            email: data.email,
            department: data.department,
            year: data.year,
            riskScore: data.riskScore,
            triggeredRules: data.triggeredRules,
            stressTrend: data.stressTrend.map(point => ({
                week: point.week,
                score: point.score
            })),
            recommendations: data.recommendations.map((rec, idx) => ({
                id: idx + 1,
                icon: rec.icon,
                title: rec.title,
                description: rec.description
            })),
            attendance: data.attendance,
            lateSubmissions: data.lateSubmissions,
            workloadTasks: data.workloadTasks
        };
    } catch (error) {
        console.error('API Error:', error);
        throw error;
    }
};

/**
 * GET /stats
 * Fetches summary statistics for the dashboard
 * @returns {Promise<Object>} Dashboard statistics
 */
export const getDashboardStats = async () => {
    try {
        const response = await fetch(`${API_BASE_URL}/stats`);
        if (!response.ok) throw new Error('Failed to fetch stats');
        return await response.json();
    } catch (error) {
        console.error('API Error:', error);
        throw error;
    }
};

/**
 * POST /simulate/what-if
 * Simulate the impact of interventions on student's risk score
 * @param {Object} params - Simulation parameters
 * @param {number} params.studentId - Student ID
 * @param {boolean} params.fixAttendance - Whether to simulate fixing attendance
 * @param {boolean} params.fixWorkload - Whether to simulate fixing workload
 * @returns {Promise<Object>} Simulation result
 */
export const simulateWhatIf = async ({ studentId, fixAttendance, fixWorkload }) => {
    try {
        const response = await fetch(`${API_BASE_URL}/simulate/what-if`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                student_id: Number(studentId),
                fix_attendance: fixAttendance,
                fix_workload: fixWorkload
            })
        });

        if (!response.ok) throw new Error('Failed to run simulation');
        return await response.json();
    } catch (error) {
        console.error('API Error:', error);
        throw error;
    }
};

/**
 * Calculate predicted risk score based on what-if parameters
 * This is a client-side simulation matching the backend rules
 * @param {Object} params - Modified parameters
 * @param {number} params.attendance - Attendance percentage (0-100)
 * @param {number} params.lateSubmissions - Number of late submissions
 * @param {number} params.workloadTasks - Number of tasks per week
 * @param {number} baseScore - Current base risk score
 * @returns {number} Predicted risk score
 */
export const calculateWhatIfScore = (params, baseScore) => {
    let score = 0;

    // Rule 1: Attendance Drop
    if (params.attendance < 75) {
        score += 20;
    }

    // Rule 2: Consecutive Late Submissions
    if (params.lateSubmissions >= 2) {
        score += 25;
    }

    // Rule 3: Workload Spike (> 12 tasks is considered heavy)
    if (params.workloadTasks > 12) {
        score += 15;
    }

    // Rule 4: Missing Submissions (assume late > 3 means some missed)
    if (params.lateSubmissions > 3) {
        score += 25;
    }

    // Rule 5: Behavior Change (simplified - low attendance + high workload)
    if (params.attendance < 80 && params.workloadTasks > 10) {
        score += 15;
    }

    // Cap at 100
    return Math.min(100, score);
};
