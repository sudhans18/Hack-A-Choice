import React, { useState, useEffect, useCallback, useMemo } from 'react';
import { simulateWhatIf } from '../services/api';
import './WhatIfSimulator.css';

/**
 * Masterful What-If Simulator
 * High-fidelity, multi-variable academic risk prediction engine.
 */
const WhatIfSimulator = ({ studentId, originalScore, originalLevel, initialData }) => {
    // State for granular metrics
    const [attendance, setAttendance] = useState(initialData?.attendance || 75);
    const [workload, setWorkload] = useState(initialData?.workloadTasks || 10);
    const [lateSubs, setLateSubs] = useState(initialData?.lateSubmissions || 0);
    const [missedSubs, setMissedSubs] = useState(initialData?.missedSubmissions || 0);

    const [result, setResult] = useState(null);
    const [loading, setLoading] = useState(false);
    const [activeTab, setActiveTab] = useState('sim'); // sim | breakdown

    /**
     * Instant Rule Engine (Frontend Version)
     * Matches risk_engine.py logic for zero-latency feedback
     */
    const computeInstantRisk = useCallback((vals) => {
        let score = 0;

        // Rule 1: Attendance < 75%
        if (vals.attendance < 75) score += 20;

        // Rule 2: Late Submissions >= 2
        if (vals.lateSubs >= 2) score += 25;

        // Rule 3: Workload Spike > 40%
        if (initialData?.previousWorkload > 0) {
            const workloadIncrease = ((vals.workload - initialData.previousWorkload) / initialData.previousWorkload) * 100;
            if (workloadIncrease > 40) score += 15;
        }

        // Rule 4: Missed Submissions > 0
        if (vals.missedSubs > 0) score += 25;

        // Rule 5: Sudden Attendance Drop > 20%
        // In simulation, we assume stability if user fixed attendance,
        // otherwise compare with previous.
        const prevAttr = initialData?.previousAttendance || vals.attendance;
        const drop = prevAttr - vals.attendance;
        if (drop > 20) score += 15;

        return Math.min(100, score);
    }, [initialData]);

    const instantScore = useMemo(() => computeInstantRisk({
        attendance, workload, lateSubs, missedSubs
    }), [computeInstantRisk, attendance, workload, lateSubs, missedSubs]);

    // Official data sync with backend (Debounced)
    useEffect(() => {
        const timer = setTimeout(async () => {
            try {
                setLoading(true);
                const data = await simulateWhatIf(studentId, {
                    attendance_target: attendance,
                    workload_target: workload,
                    late_subs_target: lateSubs,
                    missed_subs_target: missedSubs
                });
                setResult(data);
            } catch (error) {
                console.error('Simulation error:', error);
            } finally {
                setLoading(false);
            }
        }, 300); // 300ms debounce

        return () => clearTimeout(timer);
    }, [studentId, attendance, workload, lateSubs, missedSubs]);

    const getRiskColor = (score) => {
        if (score <= 30) return '#22C55E'; // Green
        if (score <= 60) return '#F59E0B'; // Orange
        return '#E10600'; // Red
    };

    const getRiskLevel = (score) => {
        if (score <= 30) return 'Low';
        if (score <= 60) return 'Moderate';
        return 'High';
    };

    const riskColor = useMemo(() => getRiskColor(instantScore), [instantScore]);
    const riskLevel = useMemo(() => getRiskLevel(instantScore), [instantScore]);
    const impactPts = useMemo(() => instantScore - originalScore, [instantScore, originalScore]);

    // Gauge rotation logic (Score 0-100 to Degrees -90 to 90)
    const gaugeRotation = useMemo(() => {
        return (instantScore / 100) * 180 - 90;
    }, [instantScore]);

    return (
        <section className="master-simulator glass-card--no-hover">
            <div className="lab-header">
                <div className="lab-title">
                    <div className="pulsing-dot"></div>
                    <h2>Predictive Intelligence Lab</h2>
                </div>
                <div className="lab-controls">
                    <button
                        className={`tab-btn ${activeTab === 'sim' ? 'active' : ''}`}
                        onClick={() => setActiveTab('sim')}
                    >
                        Simulation
                    </button>
                    <button
                        className={`tab-btn ${activeTab === 'breakdown' ? 'active' : ''}`}
                        onClick={() => setActiveTab('breakdown')}
                    >
                        Rules Mapping
                    </button>
                    <div className="lab-status">{loading ? 'Computing...' : 'System Ready'}</div>
                </div>
            </div>

            <div className="lab-layout">
                {/* Visual Feedback Section */}
                <div className="visual-feedback">
                    <div className="gauge-container">
                        <div className="gauge-background"></div>
                        <div
                            className="gauge-needle"
                            style={{ transform: `rotate(${gaugeRotation}deg)`, backgroundColor: riskColor }}
                        ></div>
                        <div className="gauge-center">
                            <span className="gauge-score" style={{ color: riskColor }}>
                                {instantScore}
                            </span>
                            <span className="gauge-label">{riskLevel} Risk</span>
                        </div>
                        <div className="gauge-ticks">
                            <span>0</span>
                            <span className="tick-mid">50</span>
                            <span>100</span>
                        </div>
                    </div>

                    <div className="impact-box">
                        <div className="impact-header">Predictive Impact</div>
                        <div className={`impact-value ${impactPts < 0 ? 'positive' : impactPts > 0 ? 'negative' : ''}`}>
                            {impactPts < 0 ? '-' : impactPts > 0 ? '+' : ''}
                            {Math.abs(impactPts)}
                            <span className="points">pts</span>
                        </div>
                        <div className="impact-desc">
                            {impactPts < 0 ? 'Risk reduction achieved' : impactPts > 0 ? 'Added risk detected' : 'Neutral impact'}
                        </div>
                    </div>
                </div>

                {/* Controls Section */}
                <div className="granular-controls">
                    <div className="control-slider">
                        <div className="slider-header">
                            <label>Attendance Rate</label>
                            <span className="slider-value">{attendance}%</span>
                        </div>
                        <input
                            type="range" min="0" max="100" step="0.5"
                            className="master-range"
                            value={attendance}
                            onChange={(e) => setAttendance(parseFloat(e.target.value))}
                            style={{ '--progress': `${attendance}%` }}
                        />
                        <div className="slider-range-labels">
                            <span>Critical</span>
                            <span style={{ color: '#22C55E' }}>Target (75%+)</span>
                        </div>
                    </div>

                    <div className="control-slider">
                        <div className="slider-header">
                            <label>Weekly Workload</label>
                            <span className="slider-value">{workload} tasks</span>
                        </div>
                        <input
                            type="range" min="1" max="30" step="1"
                            className="master-range"
                            value={workload}
                            onChange={(e) => setWorkload(parseInt(e.target.value))}
                            style={{ '--progress': `${(workload / 30) * 100}%` }}
                        />
                        <div className="slider-range-labels">
                            <span>Ideal</span>
                            <span style={{ color: '#E10600' }}>Heavy</span>
                        </div>
                    </div>

                    <div className="control-row">
                        <div className="control-slider small">
                            <div className="slider-header">
                                <label>Late Subs</label>
                                <span className="slider-value">{lateSubs}</span>
                            </div>
                            <input
                                type="range" min="0" max="10" step="1"
                                className="master-range"
                                value={lateSubs}
                                onChange={(e) => setLateSubs(parseInt(e.target.value))}
                                style={{ '--progress': `${(lateSubs / 10) * 100}%` }}
                            />
                        </div>
                        <div className="control-slider small">
                            <div className="slider-header">
                                <label>Missed Subs</label>
                                <span className="slider-value">{missedSubs}</span>
                            </div>
                            <input
                                type="range" min="0" max="5" step="1"
                                className="master-range"
                                value={missedSubs}
                                onChange={(e) => setMissedSubs(parseInt(e.target.value))}
                                style={{ '--progress': `${(missedSubs / 5) * 100}%` }}
                            />
                        </div>
                    </div>
                </div>
            </div>

            <div className={`lab-footer ${activeTab === 'breakdown' ? 'expanded' : ''}`}>
                {activeTab === 'sim' ? (
                    <div className="explanation-scroll">
                        {result?.explanation.split(' | ').map((text, i) => (
                            <div key={i} className={`explanation-line ${text.startsWith('⚠') ? 'warning' : 'success'}`}>
                                {text}
                            </div>
                        ))}
                    </div>
                ) : (
                    <div className="rules-breakdown">
                        <div className="rule-map-item">
                            <span>Rule 1: Attendance &lt; 75%</span>
                            <span className="points-badge">+20 pts</span>
                        </div>
                        <div className="rule-map-item">
                            <span>Rule 2: Late Submissions ≥ 2</span>
                            <span className="points-badge">+25 pts</span>
                        </div>
                        <div className="rule-map-item">
                            <span>Rule 4: Any Missed Submission</span>
                            <span className="points-badge">+25 pts</span>
                        </div>
                    </div>
                )}
            </div>
        </section>
    );
};

export default WhatIfSimulator;
