/**
 * WhatIfSimulator Component
 * 
 * Interactive panel allowing faculty to adjust student parameters
 * (attendance, late submissions, workload) and preview the
 * projected risk score in real-time.
 * 
 * Uses the calculateWhatIfScore function to simulate rule engine output.
 */

import React, { useState, useEffect } from 'react';
import GlassCard from './GlassCard';
import { calculateWhatIfScore } from '../services/api';
import { getRiskLevel, getRiskLabel } from '../data/mockData';

const WhatIfSimulator = ({ student }) => {
    // Initialize with student's current values
    const [attendance, setAttendance] = useState(student.attendance);
    const [lateSubmissions, setLateSubmissions] = useState(student.lateSubmissions);
    const [workloadTasks, setWorkloadTasks] = useState(student.workloadTasks);
    const [predictedScore, setPredictedScore] = useState(student.riskScore);

    // Recalculate score when parameters change
    useEffect(() => {
        const newScore = calculateWhatIfScore(
            { attendance, lateSubmissions, workloadTasks },
            student.riskScore
        );
        setPredictedScore(newScore);
    }, [attendance, lateSubmissions, workloadTasks, student.riskScore]);

    const riskLevel = getRiskLevel(predictedScore);
    const riskLabel = getRiskLabel(predictedScore);

    // Color for score display
    const scoreColor = riskLevel === 'high' ? '#ef4444' :
        riskLevel === 'moderate' ? '#f59e0b' : '#22c55e';

    return (
        <GlassCard className="simulator" noHover>
            <h3>🔮 What-If Simulator</h3>
            <p style={{ color: 'var(--gray-400)', marginTop: 'var(--space-2)' }}>
                Adjust parameters to preview how changes would affect risk score
            </p>

            <div className="simulator__controls">
                {/* Attendance Slider */}
                <div className="simulator__control">
                    <label className="simulator__label">
                        <span>📊 Attendance Rate</span>
                        <span className="simulator__value">{attendance}%</span>
                    </label>
                    <input
                        type="range"
                        className="slider"
                        min="0"
                        max="100"
                        value={attendance}
                        onChange={(e) => setAttendance(Number(e.target.value))}
                    />
                </div>

                {/* Late Submissions Slider */}
                <div className="simulator__control">
                    <label className="simulator__label">
                        <span>⏰ Late Submissions</span>
                        <span className="simulator__value">{lateSubmissions}</span>
                    </label>
                    <input
                        type="range"
                        className="slider"
                        min="0"
                        max="10"
                        value={lateSubmissions}
                        onChange={(e) => setLateSubmissions(Number(e.target.value))}
                    />
                </div>

                {/* Workload Slider */}
                <div className="simulator__control">
                    <label className="simulator__label">
                        <span>📚 Weekly Tasks</span>
                        <span className="simulator__value">{workloadTasks}</span>
                    </label>
                    <input
                        type="range"
                        className="slider"
                        min="0"
                        max="25"
                        value={workloadTasks}
                        onChange={(e) => setWorkloadTasks(Number(e.target.value))}
                    />
                </div>
            </div>

            {/* Predicted Result */}
            <div className="simulator__result">
                <span className="simulator__result-label">Predicted Risk:</span>
                <span
                    className="simulator__result-score"
                    style={{ color: scoreColor }}
                >
                    {predictedScore}
                </span>
                <span
                    className={`risk-badge risk-badge--${riskLevel}`}
                    style={{ marginLeft: 'var(--space-2)' }}
                >
                    {riskLabel}
                </span>
            </div>

            {/* Reset Button */}
            <div style={{ marginTop: 'var(--space-6)', textAlign: 'center' }}>
                <button
                    className="btn btn-secondary"
                    onClick={() => {
                        setAttendance(student.attendance);
                        setLateSubmissions(student.lateSubmissions);
                        setWorkloadTasks(student.workloadTasks);
                    }}
                >
                    Reset to Current Values
                </button>
            </div>
        </GlassCard>
    );
};

export default WhatIfSimulator;
