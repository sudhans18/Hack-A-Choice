/**
 * GlassCard Component
 * 
 * Reusable glassmorphism container with backdrop blur,
 * transparency, and subtle border. Used throughout the dashboard.
 */

import React from 'react';

const GlassCard = ({
    children,
    className = '',
    noHover = false,
    onClick,
    style
}) => {
    return (
        <div
            className={`glass-card ${noHover ? 'glass-card--no-hover' : ''} ${className}`}
            onClick={onClick}
            style={style}
        >
            {children}
        </div>
    );
};

export default GlassCard;
