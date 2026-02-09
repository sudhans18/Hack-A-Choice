/**
 * LoadingScreen Component - Enterprise Analytics
 * 
 * Simple loading spinner with black/red theme.
 */

import React from 'react';
import './LoadingScreen.css';

const LoadingScreen = () => {
    return (
        <div className="loading-screen">
            <div className="loading-screen__content">
                {/* Logo */}
                <div className="loading-screen__logo">
                    <div className="loading-screen__logo-ring"></div>
                    <div className="loading-screen__logo-inner">
                        <svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                            <circle cx="12" cy="12" r="10" />
                            <path d="M12 8v4l3 3" />
                        </svg>
                    </div>
                </div>

                {/* Title */}
                <h1 className="loading-screen__title">COGNIS</h1>
                <p className="loading-screen__subtitle">Loading Analytics...</p>

                {/* Loading indicator */}
                <div className="loading-screen__loader">
                    <div className="loading-screen__spinner"></div>
                </div>
            </div>
        </div>
    );
};

export default LoadingScreen;
