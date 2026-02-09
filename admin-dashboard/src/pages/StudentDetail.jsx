/**
 * StudentDetail Page - Analytics Edition
 * 
 * Displays precomputed ML + Rule fusion analytics for a single student.
 * Shows SHAP feature importance, rule triggers, and ML confidence.
 * NO interactive sliders or prediction buttons.
 */

import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import {
    Chart as ChartJS,
    CategoryScale,
    LinearScale,
    PointElement,
    LineElement,
    BarElement,
    Title,
    Tooltip,
    Filler,
    Legend
} from 'chart.js';
import { Line, Bar } from 'react-chartjs-2';

import Navbar from '../components/Navbar';
import CircularGauge from '../components/CircularGauge';
import { getStudentRisk } from '../services/api';
import './StudentDetail.css';

ChartJS.register(
    CategoryScale,
    LinearScale,
    PointElement,
    LineElement,
    BarElement,
    Title,
    Tooltip,
    Filler,
    Legend
);

const StudentDetail = () => {
    const { studentId } = useParams();
    const navigate = useNavigate();
    const [student, setStudent] = useState(null);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        const fetchStudent = async () => {
            setLoading(true);
            const data = await getStudentRisk(studentId);
            setStudent(data);
            setLoading(false);
        };
        fetchStudent();
    }, [studentId]);

    const getRiskClass = (score) => {
        if (score >= 61) return 'risk--high';
        if (score >= 31) return 'risk--moderate';
        return 'risk--low';
    };

    const getMlLevelLabel = (prediction) => {
        const labels = { 0: 'Low', 1: 'Moderate', 2: 'High' };
        return labels[prediction] || 'Unknown';
    };

    if (loading) {
        return (
            <div className="student-detail">
                <Navbar />
                <div className="student-detail__loading">
                    <div className="student-detail__spinner"></div>
                    <p>Loading analytics...</p>
                </div>
            </div>
        );
    }

    if (!student) {
        return (
            <div className="student-detail">
                <Navbar />
                <div className="student-detail__error">
                    <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                        <circle cx="12" cy="12" r="10" />
                        <line x1="12" y1="8" x2="12" y2="12" />
                        <line x1="12" y1="16" x2="12.01" y2="16" />
                    </svg>
                    <h2>Student Not Found</h2>
                    <p>The requested student profile could not be located.</p>
                    <button className="btn-primary" onClick={() => navigate('/')}>
                        Return to Dashboard
                    </button>
                </div>
            </div>
        );
    }

    // Trend chart configuration
    const trendData = {
        labels: student.stressTrend?.map(d => d.week) || [],
        datasets: [{
            label: 'Risk Score',
            data: student.stressTrend?.map(d => d.score) || [],
            fill: true,
            borderColor: '#E10600',
            backgroundColor: 'rgba(225, 6, 0, 0.1)',
            tension: 0.3,
            pointBackgroundColor: '#E10600',
            pointBorderColor: '#0B0B0B',
            pointBorderWidth: 2,
            pointRadius: 3
        }]
    };

    const trendOptions = {
        responsive: true,
        maintainAspectRatio: false,
        plugins: { legend: { display: false } },
        scales: {
            x: { grid: { color: 'rgba(255,255,255,0.06)' }, ticks: { color: 'rgba(255,255,255,0.38)' } },
            y: { min: 0, max: 100, grid: { color: 'rgba(255,255,255,0.06)' }, ticks: { color: 'rgba(255,255,255,0.38)' } }
        }
    };

    // SHAP explanation bar chart
    const shapData = {
        labels: student.shapExplanation?.map(s => s.feature) || [],
        datasets: [{
            label: 'Impact',
            data: student.shapExplanation?.map(s => s.impact) || [],
            backgroundColor: student.shapExplanation?.map(s =>
                s.impact > 0 ? 'rgba(225, 6, 0, 0.8)' : 'rgba(255, 255, 255, 0.3)'
            ) || [],
            borderRadius: 4,
            barThickness: 24
        }]
    };

    const shapOptions = {
        indexAxis: 'y',
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
            legend: { display: false },
            tooltip: {
                backgroundColor: '#0B0B0B',
                titleColor: '#FFFFFF',
                bodyColor: 'rgba(255,255,255,0.8)',
                callbacks: {
                    label: (ctx) => `Impact: ${ctx.raw > 0 ? '+' : ''}${ctx.raw.toFixed(3)}`
                }
            }
        },
        scales: {
            x: { grid: { color: 'rgba(255,255,255,0.06)' }, ticks: { color: 'rgba(255,255,255,0.38)' } },
            y: { grid: { display: false }, ticks: { color: 'rgba(255,255,255,0.6)' } }
        }
    };

    return (
        <div className="student-detail">
            <Navbar />

            <main className="student-detail__content">
                {/* Back Button */}
                <button className="student-detail__back" onClick={() => navigate('/')}>
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                        <polyline points="15,18 9,12 15,6" />
                    </svg>
                    Back to Dashboard
                </button>

                {/* Student Header */}
                <header className="student-header">
                    <div className="student-header__avatar">
                        #{student.id || studentId}
                    </div>
                    <div className="student-header__info">
                        <h1>Student #{studentId}</h1>
                        <div className="student-header__meta">
                            <span>Analytics Profile</span>
                            <span>ML Confidence: {(student.mlConfidence * 100).toFixed(0)}%</span>
                        </div>
                    </div>
                    <div className="student-header__status">
                        <span className={`risk-badge ${getRiskClass(student.riskScore)}`}>
                            {student.riskLevel} RISK
                        </span>
                    </div>
                </header>

                {/* Analytics Summary Grid */}
                <div className="analytics-summary">
                    <div className="analytics-card">
                        <h4>Final Fused Score</h4>
                        <div className="analytics-card__value">{student.riskScore}</div>
                        <p>Weighted: 60% ML + 40% Rules</p>
                    </div>
                    <div className="analytics-card">
                        <h4>ML Prediction</h4>
                        <div className="analytics-card__value">{getMlLevelLabel(student.mlPrediction)}</div>
                        <p>Confidence: {(student.mlConfidence * 100).toFixed(0)}%</p>
                    </div>
                    <div className="analytics-card">
                        <h4>Rule Score</h4>
                        <div className="analytics-card__value">{student.ruleRiskScore || 0}</div>
                        <p>{student.triggeredRules?.length || 0} rules triggered</p>
                    </div>
                </div>

                {/* Main Grid */}
                <div className="detail-grid">
                    {/* Left Column */}
                    <div className="detail-column">
                        {/* Risk Gauge */}
                        <div className="detail-card">
                            <h3 className="detail-card__title">Current Risk Level</h3>
                            <div className="detail-card__gauge">
                                <CircularGauge score={student.riskScore} size={180} />
                            </div>
                        </div>

                        {/* Rule Triggers */}
                        <div className="detail-card">
                            <div className="detail-card__header">
                                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                                    <path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z" />
                                    <line x1="12" y1="9" x2="12" y2="13" />
                                    <line x1="12" y1="17" x2="12.01" y2="17" />
                                </svg>
                                <h3>Rule-Based Triggers</h3>
                            </div>

                            {student.triggeredRules?.length > 0 ? (
                                <ul className="rule-list">
                                    {student.triggeredRules.map((rule, index) => (
                                        <li key={index} className="rule-list__item">
                                            <span className="rule-list__indicator"></span>
                                            <span className="rule-list__text">{rule}</span>
                                        </li>
                                    ))}
                                </ul>
                            ) : (
                                <p className="detail-card__empty">
                                    No rule-based risk factors detected.
                                </p>
                            )}
                        </div>
                    </div>

                    {/* Right Column - Charts */}
                    <div className="detail-column">
                        {/* Trend Chart */}
                        <div className="detail-card detail-card--chart">
                            <h3 className="detail-card__title">Risk Trend</h3>
                            <div className="detail-card__chart" style={{ height: 180 }}>
                                <Line data={trendData} options={trendOptions} />
                            </div>
                        </div>

                        {/* SHAP Explanation */}
                        <div className="detail-card detail-card--chart">
                            <h3 className="detail-card__title">Feature Importance (SHAP)</h3>
                            <p className="detail-card__subtitle">
                                Top contributing factors to risk prediction
                            </p>
                            <div className="detail-card__chart" style={{ height: 200 }}>
                                {student.shapExplanation?.length > 0 ? (
                                    <Bar data={shapData} options={shapOptions} />
                                ) : (
                                    <p className="detail-card__empty">No SHAP data available</p>
                                )}
                            </div>
                        </div>
                    </div>
                </div>

                {/* Raw Features */}
                <div className="detail-card">
                    <h3 className="detail-card__title">Raw Feature Values</h3>
                    <div className="features-grid">
                        <div className="feature-item">
                            <span className="feature-item__label">Anxiety Level</span>
                            <span className="feature-item__value">{student.anxiety_level}/21</span>
                        </div>
                        <div className="feature-item">
                            <span className="feature-item__label">Depression</span>
                            <span className="feature-item__value">{student.depression}/27</span>
                        </div>
                        <div className="feature-item">
                            <span className="feature-item__label">Sleep Quality</span>
                            <span className="feature-item__value">{student.sleep_quality}/5</span>
                        </div>
                        <div className="feature-item">
                            <span className="feature-item__label">Academic Performance</span>
                            <span className="feature-item__value">{student.academic_performance}/5</span>
                        </div>
                        <div className="feature-item">
                            <span className="feature-item__label">Social Support</span>
                            <span className="feature-item__value">{student.social_support}/3</span>
                        </div>
                        <div className="feature-item">
                            <span className="feature-item__label">Peer Pressure</span>
                            <span className="feature-item__value">{student.peer_pressure}/5</span>
                        </div>
                        <div className="feature-item">
                            <span className="feature-item__label">Study Load</span>
                            <span className="feature-item__value">{student.study_load}/5</span>
                        </div>
                        <div className="feature-item">
                            <span className="feature-item__label">Bullying Exposure</span>
                            <span className="feature-item__value">{student.bullying}/5</span>
                        </div>
                    </div>
                </div>

                {/* Footer */}
                <footer className="student-detail__footer">
                    COGNIS Analytics • Read-only audit trail
                </footer>
            </main>
        </div>
    );
};

export default StudentDetail;
