/**
 * LoadingScreen Component - Professional SaaS Loading Experience
 * 
 * Full-screen loading with:
 * - Gradient background (purple → indigo → teal)
 * - Animated logo ring
 * - Typing subtext animation
 * - Smooth fade-out transition
 */

import React, { useState, useEffect } from 'react';
import './LoadingScreen.css';

const LoadingScreen = ({ onComplete }) => {
    const [fadeOut, setFadeOut] = useState(false);
    const [textIndex, setTextIndex] = useState(0);

    const statusTexts = [
        "Initializing analytics engine…",
        "Analyzing behavioral patterns…",
        "Loading preventive signals…",
        "Preparing dashboard…"
    ];

    useEffect(() => {
        // Cycle through status texts
        const textTimer = setInterval(() => {
            setTextIndex(prev => (prev + 1) % statusTexts.length);
        }, 1500);

        // Minimum display time for perceived polish
        const fadeTimer = setTimeout(() => {
            setFadeOut(true);
            if (onComplete) {
                setTimeout(onComplete, 500); // Wait for fade animation
            }
        }, 2500);

        return () => {
            clearInterval(textTimer);
            clearTimeout(fadeTimer);
        };
    }, [onComplete]);

    return (
        <div className={`loading-screen ${fadeOut ? 'loading-screen--fade-out' : ''}`}>
            {/* Animated gradient background */}
            <div className="loading-screen__bg"></div>

            {/* Content */}
            <div className="loading-screen__content">
                {/* Animated logo */}
                <div className="loading-screen__logo">
                    <div className="loading-screen__ring">
                        <div className="loading-screen__ring-inner"></div>
                    </div>
                    <div className="loading-screen__icon">
                        <svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5">
                            <circle cx="12" cy="12" r="10" />
                            <path d="M12 6v6l4 2" />
                        </svg>
                    </div>
                </div>

                {/* System name */}
                <h1 className="loading-screen__title">COGNIS</h1>
                <p className="loading-screen__subtitle">Academic Stress Early Warning System</p>

                {/* Animated status text */}
                <div className="loading-screen__status">
                    <span className="loading-screen__status-text" key={textIndex}>
                        {statusTexts[textIndex]}
                    </span>
                </div>

                {/* Waveform animation */}
                <div className="loading-screen__wave">
                    <span></span>
                    <span></span>
                    <span></span>
                    <span></span>
                    <span></span>
                </div>
            </div>

            {/* Bottom branding */}
            <div className="loading-screen__footer">
                <span>Preventive Intelligence Platform</span>
            </div>
        </div>
    );
};

export default LoadingScreen;
