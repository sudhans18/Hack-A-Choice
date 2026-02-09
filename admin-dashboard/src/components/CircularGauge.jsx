/**
 * CircularGauge Component - Enterprise Edition
 * 
 * SVG-based animated circular progress indicator
 * using red/white color scheme only.
 */

import React, { useEffect, useState } from 'react';

const CircularGauge = ({ score, size = 200 }) => {
    const [animatedScore, setAnimatedScore] = useState(0);
    const [offset, setOffset] = useState(440);

    const radius = 70;
    const circumference = 2 * Math.PI * radius;

    // Risk level determination
    const getRiskLevel = (s) => {
        if (s >= 61) return 'high';
        if (s >= 31) return 'moderate';
        return 'low';
    };

    const level = getRiskLevel(score);

    // Get color based on risk level (red intensity scale)
    const getColor = (riskLevel) => {
        if (riskLevel === 'high') return '#E10600';
        if (riskLevel === 'moderate') return '#FF6B66';
        return 'rgba(255, 255, 255, 0.4)';
    };

    useEffect(() => {
        const duration = 1200;
        const steps = 50;
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

    const color = getColor(level);

    return (
        <div className="circular-gauge" style={{ width: size, height: size, position: 'relative' }}>
            <svg
                width={size}
                height={size}
                viewBox="0 0 200 200"
                style={{ transform: 'rotate(-90deg)' }}
            >
                {/* Background Circle */}
                <circle
                    cx="100"
                    cy="100"
                    r={radius}
                    fill="none"
                    stroke="rgba(255, 255, 255, 0.1)"
                    strokeWidth="8"
                />

                {/* Progress Circle */}
                <circle
                    cx="100"
                    cy="100"
                    r={radius}
                    fill="none"
                    stroke={color}
                    strokeWidth="8"
                    strokeLinecap="round"
                    style={{
                        strokeDasharray: circumference,
                        strokeDashoffset: offset,
                        transition: 'stroke-dashoffset 0.1s ease-out'
                    }}
                />
            </svg>

            {/* Center Score Display */}
            <div style={{
                position: 'absolute',
                top: '50%',
                left: '50%',
                transform: 'translate(-50%, -50%)',
                textAlign: 'center'
            }}>
                <div style={{
                    fontSize: size * 0.2,
                    fontWeight: 700,
                    color: color,
                    lineHeight: 1
                }}>
                    {animatedScore}
                </div>
                <div style={{
                    fontSize: size * 0.055,
                    color: 'rgba(255, 255, 255, 0.38)',
                    textTransform: 'uppercase',
                    letterSpacing: '0.1em',
                    marginTop: 4
                }}>
                    Risk Score
                </div>
            </div>
        </div>
    );
};

export default CircularGauge;
