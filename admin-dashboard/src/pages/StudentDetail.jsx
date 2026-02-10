/**
 * StudentDetail Page - Preventive Intelligence System
 * 
 * Individual student profile with:
 * - Preventive Risk Signal panel
 * - SHAP feature explanations (insight language)
 * - Trajectory visualization
 * - Ethical disclaimers
 */

import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { Bar } from 'react-chartjs-2';
import {
    Chart as ChartJS,
    CategoryScale,
    LinearScale,
    BarElement,
    Title,
    Tooltip
} from 'chart.js';

import Navbar from '../components/Navbar';
import LoadingScreen from '../components/LoadingScreen';
import WhatIfSimulator from '../components/WhatIfSimulator';
import { getStudentAnalytics } from '../services/api';
import './StudentDetail.css';

ChartJS.register(CategoryScale, LinearScale, BarElement, Title, Tooltip);

const StudentDetail = () => {
    const { studentId } = useParams();
    const navigate = useNavigate();
    const [student, setStudent] = useState(null);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);

    useEffect(() => {
        const fetchStudent = async () => {
            try {
                setLoading(true);
                const data = await getStudentAnalytics(studentId);
                setStudent(data);
                setError(null);
            } catch (err) {
                console.error('Failed to load student:', err);
                setError('Unable to load profile. Please try again.');
            } finally {
                setLoading(false);
            }
        };
        fetchStudent();
    }, [studentId]);

    const getRiskClass = (level) => {
        if (level === 'High') return 'risk--high';
        if (level === 'Moderate') return 'risk--moderate';
        return 'risk--low';
    };

    const getCollapseClass = (level) => {
        if (level === 'Elevated') return 'collapse--elevated';
        if (level === 'Watch') return 'collapse--watch';
        return 'collapse--low';
    };

    // SHAP chart data
    const shapData = student?.shapExplanation ? {
        labels: student.shapExplanation.map(s => s.feature),
        datasets: [{
            label: 'Influence',
            data: student.shapExplanation.map(s => s.impact),
            backgroundColor: student.shapExplanation.map(s =>
                s.impact > 0 ? 'rgba(225, 6, 0, 0.7)' : 'rgba(255, 255, 255, 0.3)'
            ),
            borderColor: student.shapExplanation.map(s =>
                s.impact > 0 ? '#E10600' : 'rgba(255, 255, 255, 0.5)'
            ),
            borderWidth: 1,
            borderRadius: 4,
        }]
    } : null;

    const shapOptions = {
        indexAxis: 'y',
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
            legend: { display: false },
            tooltip: {
                backgroundColor: '#0B0B0B',
                titleColor: '#FFFFFF',
                bodyColor: 'rgba(255, 255, 255, 0.8)',
                borderColor: 'rgba(255, 255, 255, 0.12)',
                borderWidth: 1,
                callbacks: {
                    label: (ctx) => {
                        const value = ctx.raw;
                        if (value > 0) return `Increases concern`;
                        if (value < 0) return `Reduces concern`;
                        return 'Neutral';
                    }
                }
            }
        },
        scales: {
            x: {
                grid: { color: 'rgba(255, 255, 255, 0.06)' },
                ticks: {
                    color: 'rgba(255, 255, 255, 0.4)',
                    font: { size: 10 }
                }
            },
            y: {
                grid: { display: false },
                ticks: {
                    color: 'rgba(255, 255, 255, 0.7)',
                    font: { size: 11 }
                }
            }
        }
    };

    if (loading) return <LoadingScreen />;

    if (error || !student) {
        return (
            <div className="student-detail">
                <Navbar />
                <main className="student-detail__content">
                    <div className="student-detail__error">
                        <p>{error || 'Profile not found'}</p>
                        <button className="btn-secondary" onClick={() => navigate('/')}>
                            Return to Dashboard
                        </button>
                    </div>
                </main>
            </div>
        );
    }

    const collapse = student.silentCollapseRisk || {};

    return (
        <div className="student-detail">
            <Navbar />

            <main className="student-detail__content">
                {/* Ethical Disclaimer */}
                <div className="student-detail__disclaimer">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                        <circle cx="12" cy="12" r="10" />
                        <path d="M12 16v-4" />
                        <path d="M12 8h.01" />
                    </svg>
                    <span>
                        These signals are intended to support early outreach and are not clinical assessments.
                    </span>
                </div>

                {/* Header */}
                <header className="student-detail__header">
                    <button className="btn-icon" onClick={() => navigate('/')}>
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                            <path d="M19 12H5" />
                            <path d="M12 19l-7-7 7-7" />
                        </svg>
                    </button>
                    <div>
                        <h1>Profile #{student.studentId.toString().padStart(4, '0')}</h1>
                        <p className="student-detail__subtitle">Individual preventive intelligence profile</p>
                    </div>
                </header>

                {/* Summary Cards */}
                <div className="summary-grid">
                    <div className={`summary-card summary-card--main ${getRiskClass(student.finalRiskLevel)}`}>
                        <div className="summary-card__label">Concern Level</div>
                        <div className="summary-card__value">{student.finalRiskLevel}</div>
                        <div className="summary-card__score">Score: {student.finalRiskScore}/100</div>
                    </div>
                    <div className="summary-card">
                        <div className="summary-card__label">Model Confidence</div>
                        <div className="summary-card__value">{(student.mlConfidence * 100).toFixed(0)}%</div>
                    </div>
                    <div className="summary-card">
                        <div className="summary-card__label">Active Indicators</div>
                        <div className="summary-card__value">{student.ruleTriggers?.length || 0}</div>
                    </div>
                </div>

                {/* Preventive Risk Signal Panel */}
                <section className="preventive-signal-panel">
                    <div className="preventive-signal-panel__header">
                        <h2>Preventive Risk Signal</h2>
                        <span className={`collapse-badge large ${getCollapseClass(collapse.level)}`}>
                            {collapse.level || 'Low'}
                        </span>
                    </div>

                    <div className="preventive-signal-panel__body">
                        {/* Plain language explanation */}
                        <div className="signal-explanation">
                            {collapse.level === 'Elevated' && (
                                <p>
                                    This individual shows rising concern patterns without a corresponding
                                    drop in academic performance. This may indicate internal strain that
                                    is not visible through traditional metrics.
                                </p>
                            )}
                            {collapse.level === 'Watch' && (
                                <p>
                                    This individual shows some early indicators that warrant continued
                                    observation. Patterns suggest monitoring for trend changes.
                                </p>
                            )}
                            {collapse.level === 'Low' && (
                                <p>
                                    Current patterns do not indicate elevated concern. Standard support
                                    channels remain available.
                                </p>
                            )}
                        </div>

                        {/* Drivers list */}
                        {collapse.drivers && collapse.drivers.length > 0 && (
                            <div className="signal-drivers">
                                <h4>Why this signal was raised</h4>
                                <ul>
                                    {collapse.drivers.map((driver, idx) => (
                                        <li key={idx}>
                                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                                                <path d="M12 5v14" />
                                                <path d="M5 12h14" />
                                            </svg>
                                            {driver}
                                        </li>
                                    ))}
                                </ul>
                            </div>
                        )}

                        {/* Signal score visualization */}
                        <div className="signal-score-bar">
                            <div className="signal-score-bar__track">
                                <div
                                    className={`signal-score-bar__fill ${getCollapseClass(collapse.level)}`}
                                    style={{ width: `${collapse.score || 0}%` }}
                                />
                            </div>
                            <div className="signal-score-bar__labels">
                                <span>Low</span>
                                <span>Watch</span>
                                <span>Elevated</span>
                            </div>
                        </div>
                    </div>
                </section>

                {/* SHAP Explainability */}
                <section className="explainability-panel">
                    <div className="explainability-panel__header">
                        <h2>Contributing Factors</h2>
                        <p>Key influences on this assessment</p>
                    </div>
                    <div className="explainability-panel__chart">
                        {shapData && <Bar data={shapData} options={shapOptions} />}
                    </div>
                    <div className="explainability-panel__legend">
                        <div className="legend-item">
                            <span className="legend-color legend-color--red"></span>
                            <span>Increases concern</span>
                        </div>
                        <div className="legend-item">
                            <span className="legend-color legend-color--white"></span>
                            <span>Stabilizing factor</span>
                        </div>
                    </div>
                </section>

                {/* What-If Simulator */}
                <WhatIfSimulator
                    studentId={student.studentId}
                    originalScore={student.finalRiskScore}
                    originalLevel={student.finalRiskLevel}
                    initialData={{
                        attendance: student.attendance_rate || 75,
                        workloadTasks: student.study_load || 10,
                        lateSubmissions: student.lateSubmissions || 0,
                        missedSubmissions: student.missedSubmissions || 0,
                        previousAttendance: student.previous_attendance || 85,
                        previousWorkload: student.previous_workload || 8
                    }}
                />

                {/* Active Indicators */}
                {student.ruleTriggers && student.ruleTriggers.length > 0 && (
                    <section className="indicators-panel">
                        <h2>Active Indicators</h2>
                        <ul className="indicators-list">
                            {student.ruleTriggers.map((trigger, idx) => (
                                <li key={idx} className="indicator-item">
                                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                                        <circle cx="12" cy="12" r="10" />
                                        <line x1="12" y1="8" x2="12" y2="12" />
                                        <line x1="12" y1="16" x2="12.01" y2="16" />
                                    </svg>
                                    {trigger}
                                </li>
                            ))}
                        </ul>
                    </section>
                )}

                {/* Feature Values */}
                <section className="features-panel">
                    <h2>Observed Factors</h2>
                    <div className="features-grid">
                        <div className="feature-item">
                            <span className="feature-label">Anxiety Level</span>
                            <span className="feature-value">{student.anxiety_level}/21</span>
                        </div>
                        <div className="feature-item">
                            <span className="feature-label">Depression Indicators</span>
                            <span className="feature-value">{student.depression}/27</span>
                        </div>
                        <div className="feature-item">
                            <span className="feature-label">Sleep Quality</span>
                            <span className="feature-value">{student.sleep_quality}/5</span>
                        </div>
                        <div className="feature-item">
                            <span className="feature-label">Academic Performance</span>
                            <span className="feature-value">{student.academic_performance}/5</span>
                        </div>
                        <div className="feature-item">
                            <span className="feature-label">Social Support</span>
                            <span className="feature-value">{student.social_support}/3</span>
                        </div>
                        <div className="feature-item">
                            <span className="feature-label">Peer Pressure</span>
                            <span className="feature-value">{student.peer_pressure}/5</span>
                        </div>
                        <div className="feature-item">
                            <span className="feature-label">Study Load</span>
                            <span className="feature-value">{student.study_load}/5</span>
                        </div>
                        <div className="feature-item">
                            <span className="feature-label">Bullying Exposure</span>
                            <span className="feature-value">{student.bullying}/5</span>
                        </div>
                    </div>
                </section>

                {/* Footer */}
                <footer className="student-detail__footer">
                    COGNIS Preventive Intelligence • Profile #{student.studentId} • For early support only
                </footer>
            </main>
        </div>
    );
};

export default StudentDetail;
