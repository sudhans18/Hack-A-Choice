/**
 * Mock Data Utilities
 * 
 * Helper functions for risk level calculations.
 * These match the backend logic in risk_engine.py.
 */

// Get risk level from score
export const getRiskLevel = (score) => {
  if (score <= 30) return 'low';
  if (score <= 60) return 'moderate';
  return 'high';
};

// Get risk label from score
export const getRiskLabel = (score) => {
  if (score <= 30) return 'Low Risk';
  if (score <= 60) return 'Moderate Risk';
  return 'High Risk';
};

// Dashboard stats placeholder (actual data comes from API)
export const dashboardStats = {
  totalStudents: 50,
  highRisk: 15,
  moderateRisk: 10,
  lowRisk: 25
};

// Empty students array - actual data comes from API
export const students = [];
