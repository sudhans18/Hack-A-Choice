/**
 * RiskDistributionChart Component - Enterprise Analytics
 * 
 * Donut chart with white/red color scheme.
 * Props: high, moderate, low (integer counts)
 */

import React from 'react';
import { Doughnut } from 'react-chartjs-2';
import {
    Chart as ChartJS,
    ArcElement,
    Tooltip,
    Legend
} from 'chart.js';
import './Charts.css';

ChartJS.register(ArcElement, Tooltip, Legend);

const RiskDistributionChart = ({ high = 0, moderate = 0, low = 0 }) => {
    const data = {
        labels: ['High Risk', 'Moderate Risk', 'Low Risk'],
        datasets: [{
            data: [high, moderate, low],
            backgroundColor: [
                'rgba(225, 6, 0, 0.85)',       // High - primary red
                'rgba(255, 107, 102, 0.6)',   // Moderate - light red
                'rgba(255, 255, 255, 0.2)'    // Low - white muted
            ],
            borderColor: [
                'rgba(225, 6, 0, 1)',
                'rgba(255, 107, 102, 0.8)',
                'rgba(255, 255, 255, 0.4)'
            ],
            borderWidth: 1,
            hoverOffset: 4,
            spacing: 2
        }]
    };

    const options = {
        responsive: true,
        maintainAspectRatio: false,
        cutout: '68%',
        plugins: {
            legend: {
                display: true,
                position: 'bottom',
                labels: {
                    color: 'rgba(255, 255, 255, 0.6)',
                    padding: 16,
                    usePointStyle: true,
                    pointStyle: 'circle',
                    font: {
                        size: 11,
                        family: 'Inter, sans-serif'
                    }
                }
            },
            tooltip: {
                backgroundColor: '#0B0B0B',
                titleColor: '#FFFFFF',
                bodyColor: 'rgba(255, 255, 255, 0.8)',
                borderColor: 'rgba(255, 255, 255, 0.12)',
                borderWidth: 1,
                padding: 12,
                cornerRadius: 4,
                displayColors: true,
                callbacks: {
                    label: (context) => {
                        const total = context.dataset.data.reduce((a, b) => a + b, 0);
                        const percentage = total > 0 ? ((context.raw / total) * 100).toFixed(1) : 0;
                        return ` ${context.raw} students (${percentage}%)`;
                    }
                }
            }
        },
        animation: {
            animateRotate: true,
            animateScale: false,
            duration: 600,
            easing: 'easeOutQuart'
        }
    };

    const total = high + moderate + low;

    return (
        <div className="chart-card">
            <div className="chart-card__header">
                <h3 className="chart-card__title">Risk Distribution</h3>
                <span className="chart-card__subtitle">Students by risk level</span>
            </div>
            <div className="chart-card__body chart-card__body--donut">
                <Doughnut data={data} options={options} />
                <div className="chart-card__center-text">
                    <span className="chart-card__center-value">{total}</span>
                    <span className="chart-card__center-label">STUDENTS</span>
                </div>
            </div>
        </div>
    );
};

export default RiskDistributionChart;
