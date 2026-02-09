/**
 * StudentDetail Page
 * 
 * Comprehensive risk profile for a single student showing:
 * - Animated circular gauge with stress score
 * - Rule explanation panel (why this student was flagged)
 * - Stress trend timeline (line chart)
 * - Recommendation cards
 * - What-If Simulator for exploring scenarios
 */

import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import {
    Chart as ChartJS,
    CategoryScale,
    LinearScale,
    PointElement,
    LineElement,
    Title,
    Tooltip,
    Filler,
    Legend
} from 'chart.js';
import { Line } from 'react-chartjs-2';

import GlassCard from '../components/GlassCard';
import RiskBadge from '../components/RiskBadge';
import CircularGauge from '../components/CircularGauge';
import RecommendationCard from '../components/RecommendationCard';
import WhatIfSimulator from '../components/WhatIfSimulator';
import { getStudentRisk } from '../services/api';
import { getRiskLevel } from '../data/mockData';

// Register Chart.js components
ChartJS.register(
    CategoryScale,
    LinearScale,
    PointElement,
    LineElement,
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

    // Fetch student data
    useEffect(() => {
        const fetchStudent = async () => {
            setLoading(true);
            const data = await getStudentRisk(studentId);
            setStudent(data);
            setLoading(false);
        };
        fetchStudent();
    }, [studentId]);

    if (loading) {
        return (
            <div className="container animate-fade-in" style={{ textAlign: 'center', paddingTop: '100px' }}>
                <div className="animate-pulse-glow" style={{ fontSize: '2rem' }}>Loading...</div>
            </div>
        );
    }

    if (!student) {
        return (
            <div className="container animate-fade-in" style={{ textAlign: 'center', paddingTop: '100px' }}>
                <h2>Student not found</h2>
                <button className="btn btn-primary" onClick={() => navigate('/')} style={{ marginTop: 'var(--space-4)' }}>
                    Back to Dashboard
                </button>
            </div>
        );
    }

    const riskLevel = getRiskLevel(student.riskScore);

    // Chart configuration
    const chartData = {
        labels: student.stressTrend.map(d => d.week),
        datasets: [
            {
                label: 'Stress Risk Score',
                data: student.stressTrend.map(d => d.score),
                fill: true,
                borderColor: riskLevel === 'high' ? '#ef4444' :
                    riskLevel === 'moderate' ? '#f59e0b' : '#22c55e',
                backgroundColor: riskLevel === 'high' ? 'rgba(239, 68, 68, 0.1)' :
                    riskLevel === 'moderate' ? 'rgba(245, 158, 11, 0.1)' : 'rgba(34, 197, 94, 0.1)',
                tension: 0.4,
                pointBackgroundColor: riskLevel === 'high' ? '#ef4444' :
                    riskLevel === 'moderate' ? '#f59e0b' : '#22c55e',
                pointBorderColor: '#fff',
                pointBorderWidth: 2,
                pointRadius: 5,
                pointHoverRadius: 7
            }
        ]
    };

    const chartOptions = {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
            legend: {
                display: false
            },
            tooltip: {
                backgroundColor: 'rgba(15, 23, 42, 0.9)',
                titleColor: '#fff',
                bodyColor: '#cbd5e1',
                borderColor: 'rgba(255, 255, 255, 0.1)',
                borderWidth: 1,
                padding: 12,
                cornerRadius: 8,
                displayColors: false,
                callbacks: {
                    label: (context) => `Risk Score: ${context.raw}`
                }
            }
        },
        scales: {
            x: {
                grid: {
                    color: 'rgba(255, 255, 255, 0.05)',
                    drawBorder: false
                },
                ticks: {
                    color: '#64748b'
                }
            },
            y: {
                min: 0,
                max: 100,
                grid: {
                    color: 'rgba(255, 255, 255, 0.05)',
                    drawBorder: false
                },
                ticks: {
                    color: '#64748b',
                    stepSize: 20
                }
            }
        },
        interaction: {
            intersect: false,
            mode: 'index'
        }
    };

    return (
        <div className="container animate-fade-in">
            {/* Back Button */}
            <div style={{ marginBottom: 'var(--space-6)', paddingTop: 'var(--space-6)' }}>
                <button className="back-btn" onClick={() => navigate('/')}>
                    ← Back to Dashboard
                </button>
            </div>

            {/* Student Header */}
            <div className="student-header">
                <div className="student-header__avatar">
                    {student.name.split(' ').map(n => n[0]).join('')}
                </div>
                <div className="student-header__info">
                    <h1>{student.name}</h1>
                    <div className="student-header__meta">
                        <span>📧 {student.email}</span>
                        <span>🏛️ {student.department}</span>
                        <span>📚 Year {student.year}</span>
                    </div>
                </div>
                <div style={{ marginLeft: 'auto' }}>
                    <RiskBadge score={student.riskScore} />
                </div>
            </div>

            {/* Main Content Grid */}
            <div className="detail-grid">
                {/* Left Column - Gauge & Rules */}
                <div style={{ display: 'flex', flexDirection: 'column', gap: 'var(--space-6)' }}>
                    {/* Risk Score Gauge */}
                    <GlassCard noHover style={{ display: 'flex', flexDirection: 'column', alignItems: 'center' }}>
                        <h3 style={{ marginBottom: 'var(--space-4)' }}>Current Risk Level</h3>
                        <CircularGauge score={student.riskScore} size={200} />
                    </GlassCard>

                    {/* Rule Explanation Panel */}
                    <GlassCard className="rule-panel" noHover>
                        <div className="rule-panel__header">
                            <span className="rule-panel__icon">⚠️</span>
                            <h3>Why This Student Was Flagged</h3>
                        </div>

                        {student.triggeredRules.length > 0 ? (
                            <ul className="rule-list">
                                {student.triggeredRules.map((rule, index) => (
                                    <li key={index} className="rule-list__item">
                                        <span className="rule-list__indicator"></span>
                                        <span className="rule-list__text">{rule}</span>
                                    </li>
                                ))}
                            </ul>
                        ) : (
                            <p style={{ color: 'var(--gray-400)', marginTop: 'var(--space-4)' }}>
                                No risk factors detected. This student is in good standing.
                            </p>
                        )}
                    </GlassCard>
                </div>

                {/* Right Column - Chart */}
                <GlassCard className="chart-container" noHover>
                    <h3>📈 Stress Trend Over Time</h3>
                    <div style={{ height: '220px', marginTop: 'var(--space-4)' }}>
                        <Line data={chartData} options={chartOptions} />
                    </div>
                </GlassCard>
            </div>

            {/* Recommendations Section */}
            <GlassCard noHover style={{ marginBottom: 'var(--space-6)' }}>
                <h3 style={{ marginBottom: 'var(--space-6)' }}>💡 Recommended Actions</h3>
                <div className="recommendations-grid stagger-children">
                    {student.recommendations.map((rec) => (
                        <RecommendationCard
                            key={rec.id}
                            icon={rec.icon}
                            title={rec.title}
                            description={rec.description}
                        />
                    ))}
                </div>
            </GlassCard>

            {/* What-If Simulator */}
            <WhatIfSimulator student={student} />

            {/* Footer */}
            <footer style={{
                textAlign: 'center',
                padding: 'var(--space-8) 0',
                color: 'var(--gray-500)',
                fontSize: '0.875rem'
            }}>
                Academic Stress Early Warning System • Prototype Demo
            </footer>
        </div>
    );
};

export default StudentDetail;
