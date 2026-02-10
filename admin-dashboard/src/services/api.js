/**
 * API Service Layer - Analytics Edition
 * 
 * Connects to the FastAPI backend for precomputed analytics.
 * NO live predictions - all data is precomputed at server startup.
 * 
 * Base URL: http://localhost:8000
 */

const API_BASE_URL = 'http://localhost:8000';

/**
 * GET /students/analytics
 * Fetches ALL precomputed student analytics with ML + Rule fusion.
 * This is the primary data source for the dashboard.
 * 
 * @returns {Promise<Object>} { students: [...], stats: {...} }
 */
export const getAnalytics = async () => {
    try {
        const response = await fetch(`${API_BASE_URL}/students/analytics`);
        if (!response.ok) throw new Error('Failed to fetch analytics');
        return await response.json();
    } catch (error) {
        console.error('Analytics API Error:', error);
        throw error;
    }
};

/**
 * GET /students/analytics/{studentId}
 * Fetches detailed analytics for a single student.
 * Includes ML prediction, rule triggers, and SHAP explanation.
 * 
 * @param {string|number} studentId - The student's unique ID
 * @returns {Promise<Object|null>} Student analytics or null if not found
 */
export const getStudentAnalytics = async (studentId) => {
    try {
        const response = await fetch(`${API_BASE_URL}/students/analytics/${studentId}`);
        if (!response.ok) {
            if (response.status === 404) return null;
            throw new Error('Failed to fetch student analytics');
        }
        return await response.json();
    } catch (error) {
        console.error('Analytics API Error:', error);
        throw error;
    }
};

/**
 * GET /students/at-risk (Legacy - kept for compatibility)
 * Fetches students flagged with risk indicators.
 * 
 * @returns {Promise<Array>} List of at-risk students
 */
export const getAtRiskStudents = async () => {
    try {
        // Use analytics endpoint and filter
        const data = await getAnalytics();
        return data.students
            .filter(s => s.finalRiskLevel !== 'Low')
            .sort((a, b) => b.finalRiskScore - a.finalRiskScore)
            .map(student => ({
                id: String(student.studentId),
                name: `Student ${student.studentId}`,
                email: `student${student.studentId}@university.edu`,
                department: 'Analytics',
                year: Math.ceil(student.studentId % 4) + 1,
                riskScore: student.finalRiskScore,
                riskLevel: student.finalRiskLevel,
                mlConfidence: student.mlConfidence,
                triggeredRules: student.ruleTriggers || [],
            }));
    } catch (error) {
        console.error('API Error:', error);
        throw error;
    }
};

/**
 * GET /risk/{studentId} (Legacy - redirects to analytics)
 * Fetches detailed risk profile for a specific student.
 * 
 * @param {string} studentId - The student's unique ID
 * @returns {Promise<Object|null>} Student risk profile or null
 */
export const getStudentRisk = async (studentId) => {
    try {
        const data = await getStudentAnalytics(studentId);
        if (!data) return null;

        // Transform to expected frontend format
        return {
            id: String(data.studentId),
            name: `Student ${data.studentId}`,
            email: `student${data.studentId}@university.edu`,
            department: 'Analytics',
            year: Math.ceil(data.studentId % 4) + 1,
            riskScore: data.finalRiskScore,
            riskLevel: data.finalRiskLevel,
            mlPrediction: data.mlPrediction,
            mlConfidence: data.mlConfidence,
            ruleRiskScore: data.ruleRiskScore,
            triggeredRules: data.ruleTriggers || [],
            shapExplanation: data.shapExplanation || [],
            // Raw features for display
            anxiety_level: data.anxiety_level,
            depression: data.depression,
            sleep_quality: data.sleep_quality,
            academic_performance: data.academic_performance,
            social_support: data.social_support,
            peer_pressure: data.peer_pressure,
            study_load: data.study_load,
            bullying: data.bullying,
            // Mock trend data (analytics is static, no real trend)
            stressTrend: generateMockTrend(data.finalRiskScore),
            // No recommendations in analytics mode
            recommendations: [],
        };
    } catch (error) {
        console.error('API Error:', error);
        throw error;
    }
};

/**
 * Generate mock trend data based on final risk score.
 * Since analytics is static, we simulate historical trend.
 */
const generateMockTrend = (currentScore) => {
    const weeks = ['W1', 'W2', 'W3', 'W4', 'W5', 'W6', 'W7', 'W8'];
    const trend = [];

    for (let i = 0; i < weeks.length; i++) {
        // Gradually increase to current score with some variance
        const progress = (i + 1) / weeks.length;
        const base = currentScore * progress;
        const variance = (Math.random() - 0.5) * 15;
        const score = Math.max(0, Math.min(100, Math.round(base + variance)));
        trend.push({ week: weeks[i], score });
    }

    // Ensure last point is close to actual score
    trend[trend.length - 1].score = currentScore;
    return trend;
};

/**
 * GET /stats - Dashboard statistics
 * Now derived from analytics endpoint.
 * 
 * @returns {Promise<Object>} Dashboard statistics
 */
export const getDashboardStats = async () => {
    try {
        const data = await getAnalytics();
        return data.stats;
    } catch (error) {
        console.error('API Error:', error);
        throw error;
    }
};
/**
 * POST /simulate/what-if
 * Simulates the impact of interventions on a student's risk score.
 * 
 * @param {string|number} studentId - The student's unique ID
 * @param {Object} interventions - { fix_attendance: boolean, fix_workload: boolean }
 * @returns {Promise<Object>} Simulation results
 */
export const simulateWhatIf = async (studentId, interventions) => {
    try {
        const response = await fetch(`${API_BASE_URL}/simulate/what-if`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                student_id: parseInt(studentId),
                ...interventions
            })
        });
        if (!response.ok) throw new Error('Simulation failed');
        return await response.json();
    } catch (error) {
        console.error('Simulation API Error:', error);
        throw error;
    }
};
