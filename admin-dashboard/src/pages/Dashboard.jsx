/**
 * Dashboard Page - Analytics Edition
 * 
 * Displays precomputed ML + Rule fusion analytics.
 * Read-only, deterministic, audit-friendly.
 * NO sliders, NO prediction buttons.
 */

import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';

import Navbar from '../components/Navbar';
import LoadingScreen from '../components/LoadingScreen';
import RiskDistributionChart from '../components/RiskDistributionChart';
import StressTrendChart from '../components/StressTrendChart';
import { getAnalytics } from '../services/api';
import './Dashboard.css';

const Dashboard = () => {
    const navigate = useNavigate();
    const [students, setStudents] = useState([]);
    const [stats, setStats] = useState(null);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);
    const [sortKey, setSortKey] = useState('finalRiskScore');
    const [sortDir, setSortDir] = useState('desc');
    const [filterLevel, setFilterLevel] = useState('all');

    useEffect(() => {
        const fetchData = async () => {
            try {
                setLoading(true);
                const data = await getAnalytics();
                setStudents(data.students || []);
                setStats(data.stats || null);
                setError(null);
            } catch (err) {
                console.error('Failed to load analytics:', err);
                setError('Failed to load analytics data. Please ensure the backend is running.');
            } finally {
                setLoading(false);
            }
        };
        fetchData();
    }, []);

    // Sort and filter students
    const displayStudents = [...students]
        .filter(s => filterLevel === 'all' || s.finalRiskLevel === filterLevel)
        .sort((a, b) => {
            const aVal = a[sortKey];
            const bVal = b[sortKey];
            return sortDir === 'desc' ? bVal - aVal : aVal - bVal;
        });

    const handleSort = (key) => {
        if (sortKey === key) {
            setSortDir(sortDir === 'desc' ? 'asc' : 'desc');
        } else {
            setSortKey(key);
            setSortDir('desc');
        }
    };

    const getRiskClass = (level) => {
        if (level === 'High') return 'risk--high';
        if (level === 'Moderate') return 'risk--moderate';
        return 'risk--low';
    };

    if (loading) return <LoadingScreen />;

    return (
        <div className="dashboard">
            <Navbar />

            <main className="dashboard__content">
                {/* Page Header */}
                <header className="dashboard__header">
                    <div>
                        <h1>Student Analytics</h1>
                        <p className="dashboard__subtitle">
                            Precomputed ML + Rule fusion risk assessment
                        </p>
                    </div>
                    <div className="dashboard__meta">
                        <span className="dashboard__badge">
                            {stats?.totalStudents || 0} Students Analyzed
                        </span>
                    </div>
                </header>

                {error && (
                    <div className="dashboard__error">
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                            <circle cx="12" cy="12" r="10" />
                            <line x1="12" y1="8" x2="12" y2="12" />
                            <line x1="12" y1="16" x2="12.01" y2="16" />
                        </svg>
                        <span>{error}</span>
                    </div>
                )}

                {/* Stats Cards */}
                {stats && (
                    <div className="stats-grid">
                        <div className="stat-card">
                            <div className="stat-card__value">{stats.totalStudents}</div>
                            <div className="stat-card__label">Total Students</div>
                        </div>
                        <div className="stat-card stat-card--high">
                            <div className="stat-card__value">{stats.highRisk}</div>
                            <div className="stat-card__label">High Risk</div>
                        </div>
                        <div className="stat-card stat-card--moderate">
                            <div className="stat-card__value">{stats.moderateRisk}</div>
                            <div className="stat-card__label">Moderate Risk</div>
                        </div>
                        <div className="stat-card stat-card--low">
                            <div className="stat-card__value">{stats.lowRisk}</div>
                            <div className="stat-card__label">Low Risk</div>
                        </div>
                        <div className="stat-card">
                            <div className="stat-card__value">{stats.averageRiskScore}</div>
                            <div className="stat-card__label">Avg Risk Score</div>
                        </div>
                        <div className="stat-card">
                            <div className="stat-card__value">{(stats.averageConfidence * 100).toFixed(0)}%</div>
                            <div className="stat-card__label">Avg Confidence</div>
                        </div>
                    </div>
                )}

                {/* Charts Row */}
                <div className="charts-grid">
                    <RiskDistributionChart
                        high={stats?.highRisk || 0}
                        moderate={stats?.moderateRisk || 0}
                        low={stats?.lowRisk || 0}
                    />
                    <StressTrendChart
                        data={displayStudents.slice(0, 50).map((s, i) => ({
                            week: `S${s.studentId}`,
                            score: s.finalRiskScore
                        }))}
                    />
                </div>

                {/* Filters */}
                <div className="dashboard__filters">
                    <div className="filter-group">
                        <label>Risk Level:</label>
                        <select
                            value={filterLevel}
                            onChange={(e) => setFilterLevel(e.target.value)}
                            className="filter-select"
                        >
                            <option value="all">All Levels</option>
                            <option value="High">High Risk</option>
                            <option value="Moderate">Moderate Risk</option>
                            <option value="Low">Low Risk</option>
                        </select>
                    </div>
                    <div className="filter-group">
                        <span className="filter-count">
                            Showing {displayStudents.length} of {students.length}
                        </span>
                    </div>
                </div>

                {/* Students Table */}
                <div className="dashboard__table-container">
                    <table className="dashboard__table">
                        <thead>
                            <tr>
                                <th onClick={() => handleSort('studentId')}>
                                    ID {sortKey === 'studentId' && (sortDir === 'desc' ? '↓' : '↑')}
                                </th>
                                <th onClick={() => handleSort('finalRiskScore')}>
                                    Risk Score {sortKey === 'finalRiskScore' && (sortDir === 'desc' ? '↓' : '↑')}
                                </th>
                                <th>Risk Level</th>
                                <th onClick={() => handleSort('mlConfidence')}>
                                    ML Confidence {sortKey === 'mlConfidence' && (sortDir === 'desc' ? '↓' : '↑')}
                                </th>
                                <th>Rule Flags</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            {displayStudents.slice(0, 100).map((student) => (
                                <tr
                                    key={student.studentId}
                                    className={`table-row ${getRiskClass(student.finalRiskLevel)}`}
                                >
                                    <td className="table-cell--id">
                                        #{student.studentId.toString().padStart(4, '0')}
                                    </td>
                                    <td className="table-cell--score">
                                        <div className="score-bar">
                                            <div
                                                className="score-bar__fill"
                                                style={{ width: `${student.finalRiskScore}%` }}
                                            />
                                            <span className="score-bar__value">{student.finalRiskScore}</span>
                                        </div>
                                    </td>
                                    <td>
                                        <span className={`risk-badge ${getRiskClass(student.finalRiskLevel)}`}>
                                            {student.finalRiskLevel}
                                        </span>
                                    </td>
                                    <td className="table-cell--confidence">
                                        {(student.mlConfidence * 100).toFixed(0)}%
                                    </td>
                                    <td className="table-cell--flags">
                                        {student.ruleTriggers?.length || 0} flags
                                    </td>
                                    <td>
                                        <button
                                            className="btn-secondary btn-sm"
                                            onClick={() => navigate(`/student/${student.studentId}`)}
                                        >
                                            View Details
                                        </button>
                                    </td>
                                </tr>
                            ))}
                        </tbody>
                    </table>
                </div>

                {/* Footer */}
                <footer className="dashboard__footer">
                    COGNIS Analytics • {stats?.totalStudents || 0} students • Read-only dashboard
                </footer>
            </main>
        </div>
    );
};

export default Dashboard;
