/**
 * CircularGauge Component
 * 
 * SVG-based animated circular progress indicator
 * displaying stress risk score (0-100).
 * 
 * Features:
 * - Smooth animation from 0 to actual score
 * - Color-coded based on risk level (green/amber/red gradient)
 * - Central score display with label
 */

import React, { useEffect, useState } from 'react';
import { getRiskLevel } from '../data/mockData';

const CircularGauge = ({ score, size = 200 }) => {
    const [animatedScore, setAnimatedScore] = useState(0);
    const [offset, setOffset] = useState(440);

    const level = getRiskLevel(score);
    const radius = 70;
    const circumference = 2 * Math.PI * radius; // ~440

    // Animate the score counting up
    useEffect(() => {
        const duration = 1500; // 1.5 seconds
        const steps = 60;
        const increment = score / steps;
        let currentStep = 0;

        const timer = setInterval(() => {
            currentStep++;
            if (currentStep <= steps) {
                setAnimatedScore(Math.round(increment * currentStep));
                // Calculate stroke offset for progress
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
        <div className="circular-gauge" style={{ width: size, height: size }}>
            {/* SVG Gradient Definitions */}
            <svg width="0" height="0">
                <defs>
                    <linearGradient id="gradient-low" x1="0%" y1="0%" x2="100%" y2="0%">
                        <stop offset="0%" stopColor="#22c55e" />
                        <stop offset="100%" stopColor="#4ade80" />
                    </linearGradient>
                    <linearGradient id="gradient-moderate" x1="0%" y1="0%" x2="100%" y2="0%">
                        <stop offset="0%" stopColor="#f59e0b" />
                        <stop offset="100%" stopColor="#fbbf24" />
                    </linearGradient>
                    <linearGradient id="gradient-high" x1="0%" y1="0%" x2="100%" y2="0%">
                        <stop offset="0%" stopColor="#ef4444" />
                        <stop offset="100%" stopColor="#f87171" />
                    </linearGradient>
                </defs>
            </svg>

            {/* Main Gauge Circle */}
            <svg
                className="circular-gauge__svg"
                width={size}
                height={size}
                viewBox="0 0 200 200"
            >
                {/* Background Circle */}
                <circle
                    className="circular-gauge__bg"
                    cx="100"
                    cy="100"
                    r={radius}
                />

                {/* Progress Circle */}
                <circle
                    className={`circular-gauge__progress circular-gauge__progress--${level}`}
                    cx="100"
                    cy="100"
                    r={radius}
                    style={{
                        strokeDasharray: circumference,
                        strokeDashoffset: offset
                    }}
                />
            </svg>

            {/* Center Score Display */}
            <div className="circular-gauge__value">
                <div
                    className="circular-gauge__score"
                    style={{
                        color: level === 'high' ? '#ef4444' :
                            level === 'moderate' ? '#f59e0b' : '#22c55e'
                    }}
                >
                    {animatedScore}
                </div>
                <div className="circular-gauge__label">Risk Score</div>
            </div>
        </div>
    );
};

export default CircularGauge;
