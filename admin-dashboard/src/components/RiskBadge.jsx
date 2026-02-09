/**
 * RiskBadge Component
 * 
 * Color-coded pill badge indicating risk level:
 * - Low (≤30): Green
 * - Moderate (31-60): Amber/Orange
 * - High (61+): Red
 * 
 * Includes a pulsing indicator dot for visual attention.
 */

import React from 'react';
import { getRiskLevel, getRiskLabel } from '../data/mockData';

const RiskBadge = ({ score }) => {
    const level = getRiskLevel(score);
    const label = getRiskLabel(score);

    return (
        <span className={`risk-badge risk-badge--${level}`}>
            {label}
        </span>
    );
};

export default RiskBadge;
