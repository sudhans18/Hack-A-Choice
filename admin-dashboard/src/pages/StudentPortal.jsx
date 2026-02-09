/**
 * StudentPortal Page
 * 
 * Student-facing wellness dashboard with calming, supportive design.
 * Features:
 * - Large animated stress score gauge
 * - Friendly status messages
 * - Workload and attendance visualizations
 * - Personalized recommendations
 * 
 * Tone: Empathetic, supportive, non-clinical
 */

import React, { useState, useEffect } from 'react';
import { useParams, Link } from 'react-router-dom';
import {
    Chart as ChartJS,
    CategoryScale,
    LinearScale,
    PointElement,
    LineElement,
    BarElement,
    Title,
    Tooltip,
    Filler
} from 'chart.js';
import { Line, Bar } from 'react-chartjs-2';
import '../styles/student-portal.css';

// Register Chart.js components
ChartJS.register(
    CategoryScale,
    LinearScale,
    PointElement,
    LineElement,
    BarElement,
    Title,
    Tooltip,
    Filler
);

const API_BASE_URL = 'http://localhost:8000';

// Friendly messages based on stress level
const getStatusInfo = (score) => {
    if (score <= 30) {
        return {
            level: 'good',
            icon: '🌟',
            message: "You're doing great! Keep up the wonderful balance you've created.",
            encouragement: "Your consistent efforts are paying off beautifully."
        };
    } else if (score <= 60) {
        return {
            level: 'warning',
            icon: '💙',
            message: "You might be feeling a bit stretched lately. That's completely normal.",
            encouragement: "Small adjustments can make a big difference. We're here to help."
        };
    } else {
        return {
            level: 'alert',
            icon: '🤗',
            message: "It looks like things have been challenging. You're not alone in this.",
            encouragement: "Please reach out — your wellbeing matters more than any deadline."
        };
    }
};

// Wellness Gauge Component
const WellnessGauge = ({ score, size = 200 }) => {
    const [animatedScore, setAnimatedScore] = useState(0);
    const [offset, setOffset] = useState(440);

    const statusInfo = getStatusInfo(score);
    const radius = 70;
    const circumference = 2 * Math.PI * radius;

    // Animate score counting
    useEffect(() => {
        const duration = 1500;
        const steps = 60;
        const increment = score / steps;
        let currentStep = 0;

        const timer = setInterval(() => {
            currentStep++;
            if (currentStep <= steps) {
                setAnimatedScore(Math.round(increment * currentStep));
                const progress = (increment * currentStep) / 100;
                setOffset(circumference - (progress * circumference));
            } else {
                clearInterval(timer);
                setAnimatedScore(score);
                setOffset(circumference - (score / 100) * circumference);
            }
        }, duration / steps);

        return () => clearInterval(timer);
    }, [score, circumference]);

    return (
        <div className="wellness-gauge" style={{ width: size, height: size }}>
            <svg width="0" height="0">
                <defs>
                    <linearGradient id="gradient-wellness-good" x1="0%" y1="0%" x2="100%" y2="0%">
                        <stop offset="0%" stopColor="#10b981" />
                        <stop offset="100%" stopColor="#34d399" />
                    </linearGradient>
                    <linearGradient id="gradient-wellness-warning" x1="0%" y1="0%" x2="100%" y2="0%">
                        <stop offset="0%" stopColor="#f59e0b" />
                        <stop offset="100%" stopColor="#fbbf24" />
                    </linearGradient>
                    <linearGradient id="gradient-wellness-alert" x1="0%" y1="0%" x2="100%" y2="0%">
                        <stop offset="0%" stopColor="#f87171" />
                        <stop offset="100%" stopColor="#fca5a5" />
                    </linearGradient>
                </defs>
            </svg>

            <svg
                className="wellness-gauge__svg"
                width={size}
                height={size}
                viewBox="0 0 200 200"
            >
                <circle
                    className="wellness-gauge__bg"
                    cx="100"
                    cy="100"
                    r={radius}
                />
                <circle
                    className={`wellness-gauge__progress wellness-gauge__progress--${statusInfo.level}`}
                    cx="100"
                    cy="100"
                    r={radius}
                    style={{
                        strokeDasharray: circumference,
                        strokeDashoffset: offset
                    }}
                />
            </svg>

            <div className="wellness-gauge__center">
                <div className="wellness-gauge__score">{animatedScore}</div>
                <div className="wellness-gauge__max">out of 100</div>
            </div>
        </div>
    );
};

// Main Student Portal Component
const StudentPortal = () => {
    const { studentId } = useParams();
    const [student, setStudent] = useState(null);
    const [allStudents, setAllStudents] = useState([]);
    const [selectedId, setSelectedId] = useState(studentId || '1000');
    const [loading, setLoading] = useState(true);

    // Fetch all students for selector
    useEffect(() => {
        fetch(`${API_BASE_URL}/students`)
            .then(res => res.json())
            .then(data => setAllStudents(data.students || []))
            .catch(err => console.error(err));
    }, []);

    // Fetch selected student data
    useEffect(() => {
        setLoading(true);
        fetch(`${API_BASE_URL}/risk/${selectedId}`)
            .then(res => res.json())
            .then(data => {
                setStudent(data);
                setLoading(false);
            })
            .catch(err => {
                console.error(err);
                setLoading(false);
            });
    }, [selectedId]);

    if (loading) {
        return (
            <div className="student-portal">
                <div className="student-portal__container">
                    <div className="loading-container">
                        <div className="loading-spinner"></div>
                        <p>Loading your wellness data...</p>
                    </div>
                </div>
            </div>
        );
    }

    if (!student) {
        return (
            <div className="student-portal">
                <div className="student-portal__container">
                    <div className="loading-container">
                        <p>Unable to load student data. Please try again.</p>
                    </div>
                </div>
            </div>
        );
    }

    const statusInfo = getStatusInfo(student.riskScore);
    const firstName = student.name.split(' ')[0];

    // Chart data for trend
    const trendData = {
        labels: student.stressTrend?.map(d => d.week) || [],
        datasets: [{
            label: 'Wellness Score',
            data: student.stressTrend?.map(d => d.score) || [],
            fill: true,
            borderColor: '#3b82f6',
            backgroundColor: 'rgba(59, 130, 246, 0.1)',
            tension: 0.4,
            pointBackgroundColor: '#3b82f6',
            pointBorderColor: '#fff',
            pointBorderWidth: 2,
            pointRadius: 4
        }]
    };

    const chartOptions = {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
            legend: { display: false },
            tooltip: {
                backgroundColor: '#fff',
                titleColor: '#334155',
                bodyColor: '#64748b',
                borderColor: '#e2e8f0',
                borderWidth: 1,
                padding: 12,
                cornerRadius: 12
            }
        },
        scales: {
            x: {
                grid: { display: false },
                ticks: { color: '#94a3b8', font: { size: 11 } }
            },
            y: {
                min: 0,
                max: 100,
                grid: { color: '#f1f5f9' },
                ticks: { color: '#94a3b8', stepSize: 25 }
            }
        }
    };

    // Get current date
    const today = new Date().toLocaleDateString('en-US', {
        weekday: 'long',
        month: 'long',
        day: 'numeric'
    });

    return (
        <div className="student-portal">
            <div className="student-portal__container">
                {/* Back to Admin */}
                <Link to="/" className="back-nav">
                    ← Back to Admin Dashboard
                </Link>

                {/* Student Selector (for demo) */}
                <div className="student-selector">
                    <label className="student-selector__label">
                        Demo: Select a student to view
                    </label>
                    <select
                        className="student-selector__select"
                        value={selectedId}
                        onChange={(e) => setSelectedId(e.target.value)}
                    >
                        {allStudents.map(s => (
                            <option key={s.studentId} value={s.studentId}>
                                {s.name} — {s.riskLevel} Risk ({s.riskScore})
                            </option>
                        ))}
                    </select>
                </div>

                {/* Header */}
                <header className="student-portal__header">
                    <h1 className="student-portal__greeting">Hi, {firstName} 👋</h1>
                    <p className="student-portal__date">{today}</p>
                </header>

                {/* Main Stress Card */}
                <div className="stress-card">
                    <p className="stress-card__title">Your Wellness Score</p>

                    <WellnessGauge score={student.riskScore} />

                    {/* Friendly Status Message */}
                    <div className={`status-message status-message--${statusInfo.level}`}>
                        <div className="status-message__icon">{statusInfo.icon}</div>
                        <p className="status-message__text">{statusInfo.message}</p>
                    </div>

                    <p style={{ fontSize: '0.875rem', color: '#64748b', marginTop: '12px' }}>
                        {statusInfo.encouragement}
                    </p>
                </div>

                {/* Info Cards */}
                <div className="info-cards">
                    {/* Attendance Card */}
                    <div className="info-card info-card--animated">
                        <div className="info-card__header">
                            <div className="info-card__icon">📊</div>
                            <div>
                                <h3 className="info-card__title">Attendance</h3>
                                <p className="info-card__subtitle">Your class participation</p>
                            </div>
                        </div>
                        <div className="progress-bar">
                            <div
                                className="progress-bar__fill progress-bar__fill--blue"
                                style={{ width: `${student.attendance || 75}%` }}
                            ></div>
                        </div>
                        <div className="progress-bar__label">
                            <span>Current: {student.attendance || 75}%</span>
                            <span>Target: 85%</span>
                        </div>
                    </div>

                    {/* Workload Card */}
                    <div className="info-card info-card--animated">
                        <div className="info-card__header">
                            <div className="info-card__icon">📚</div>
                            <div>
                                <h3 className="info-card__title">Weekly Workload</h3>
                                <p className="info-card__subtitle">{student.workloadTasks || 10} active tasks</p>
                            </div>
                        </div>
                        <div className="progress-bar">
                            <div
                                className="progress-bar__fill progress-bar__fill--lavender"
                                style={{ width: `${Math.min(100, ((student.workloadTasks || 10) / 20) * 100)}%` }}
                            ></div>
                        </div>
                        <div className="progress-bar__label">
                            <span>Current load</span>
                            <span>{(student.workloadTasks || 10) <= 10 ? 'Manageable' : 'Heavy'}</span>
                        </div>
                    </div>

                    {/* Trend Card */}
                    <div className="info-card info-card--animated">
                        <div className="info-card__header">
                            <div className="info-card__icon">📈</div>
                            <div>
                                <h3 className="info-card__title">Your Journey</h3>
                                <p className="info-card__subtitle">Wellness over the past 8 weeks</p>
                            </div>
                        </div>
                        <div className="mini-chart">
                            <Line data={trendData} options={chartOptions} />
                        </div>
                    </div>
                </div>

                {/* Recommendations */}
                {student.recommendations && student.recommendations.length > 0 && (
                    <div className="recommendation-section">
                        <h2 className="recommendation-section__title">
                            💡 Personalized for You
                        </h2>

                        {student.recommendations.map((rec, idx) => (
                            <div key={idx} className="student-recommendation">
                                <div className="student-recommendation__icon">
                                    {rec.icon}
                                </div>
                                <div className="student-recommendation__content">
                                    <h4 className="student-recommendation__title">{rec.title}</h4>
                                    <p className="student-recommendation__description">{rec.description}</p>
                                </div>
                                <span className="student-recommendation__arrow">→</span>
                            </div>
                        ))}
                    </div>
                )}

                {/* Action Button */}
                <div style={{ marginTop: '32px' }}>
                    <button className="action-button action-button--primary">
                        💬 Talk to Someone
                    </button>
                    <div style={{ height: '12px' }}></div>
                    <button className="action-button action-button--secondary">
                        📅 Schedule Advisor Meeting
                    </button>
                </div>

                {/* Footer */}
                <footer className="student-portal__footer">
                    <p>Your data is confidential and used only to support you.</p>
                    <p style={{ marginTop: '8px' }}>
                        Need help? <a href="#">Contact Support</a>
                    </p>
                </footer>
            </div>
        </div>
    );
};

export default StudentPortal;
