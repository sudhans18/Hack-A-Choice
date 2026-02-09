/**
 * StressTrendChart Component - Enterprise Analytics
 * 
 * Line chart showing risk score distribution.
 * Props: data (array of {week, score} objects)
 */

import React from 'react';
import { Line } from 'react-chartjs-2';
import {
    Chart as ChartJS,
    CategoryScale,
    LinearScale,
    PointElement,
    LineElement,
    Title,
    Tooltip,
    Filler
} from 'chart.js';
import './Charts.css';

ChartJS.register(
    CategoryScale,
    LinearScale,
    PointElement,
    LineElement,
    Title,
    Tooltip,
    Filler
);

const StressTrendChart = ({ data: trendData = [] }) => {
    const chartData = {
        labels: trendData.map(d => d.week),
        datasets: [{
            label: 'Risk Score',
            data: trendData.map(d => d.score),
            fill: true,
            borderColor: '#E10600',
            backgroundColor: (context) => {
                const ctx = context.chart.ctx;
                const gradient = ctx.createLinearGradient(0, 0, 0, 200);
                gradient.addColorStop(0, 'rgba(225, 6, 0, 0.25)');
                gradient.addColorStop(1, 'rgba(225, 6, 0, 0.02)');
                return gradient;
            },
            borderWidth: 2,
            tension: 0.3,
            pointRadius: 3,
            pointBackgroundColor: '#E10600',
            pointBorderColor: '#0B0B0B',
            pointBorderWidth: 2,
            pointHoverRadius: 5,
            pointHoverBackgroundColor: '#FFFFFF',
            pointHoverBorderColor: '#E10600',
            pointHoverBorderWidth: 2
        }]
    };

    const options = {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
            legend: {
                display: false
            },
            tooltip: {
                backgroundColor: '#0B0B0B',
                titleColor: '#FFFFFF',
                bodyColor: 'rgba(255, 255, 255, 0.8)',
                borderColor: 'rgba(255, 255, 255, 0.12)',
                borderWidth: 1,
                padding: 12,
                cornerRadius: 4,
                callbacks: {
                    label: (context) => `Risk Score: ${context.raw}`
                }
            }
        },
        scales: {
            x: {
                grid: {
                    color: 'rgba(255, 255, 255, 0.06)',
                    drawBorder: false
                },
                ticks: {
                    color: 'rgba(255, 255, 255, 0.38)',
                    font: {
                        size: 10,
                        family: 'Inter, sans-serif'
                    },
                    maxRotation: 45,
                    minRotation: 45
                }
            },
            y: {
                min: 0,
                max: 100,
                grid: {
                    color: 'rgba(255, 255, 255, 0.06)',
                    drawBorder: false
                },
                ticks: {
                    color: 'rgba(255, 255, 255, 0.38)',
                    font: {
                        size: 10,
                        family: 'Inter, sans-serif'
                    },
                    stepSize: 25
                }
            }
        },
        animation: {
            duration: 800,
            easing: 'easeOutQuart'
        },
        interaction: {
            intersect: false,
            mode: 'index'
        }
    };

    return (
        <div className="chart-card">
            <div className="chart-card__header">
                <h3 className="chart-card__title">Risk Score Distribution</h3>
                <span className="chart-card__subtitle">Sample student scores</span>
            </div>
            <div className="chart-card__body">
                <Line data={chartData} options={options} />
            </div>
        </div>
    );
};

export default StressTrendChart;
