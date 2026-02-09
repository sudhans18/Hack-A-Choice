/**
 * Dashboard Page - Preventive Intelligence System
 * 
 * Surfaces "invisible risk" without panic or stigma.
 * Read-only, deterministic, audit-friendly.
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
    const [dataLoaded, setDataLoaded] = useState(false);
    const [showLoader, setShowLoader] = useState(true);
    const [error, setError] = useState(null);
    const [sortKey, setSortKey] = useState('finalRiskScore');
    const [sortDir, setSortDir] = useState('desc');
    const [filterLevel, setFilterLevel] = useState('all');

    useEffect(() => {
        const fetchData = async () => {
            const startTime = Date.now();
            try {
                const data = await getAnalytics();
                setStudents(data.students || []);
                setStats(data.stats || null);
                setError(null);
                setDataLoaded(true);

                // Ensure minimum loading time for polish
                const elapsed = Date.now() - startTime;
                const minTime = 2000; // 2 seconds minimum
                if (elapsed < minTime) {
                    await new Promise(r => setTimeout(r, minTime - elapsed));
                }
            } catch (err) {
                console.error('Failed to load analytics:', err);
                setError('Failed to load analytics data. Please ensure the backend is running.');
                setDataLoaded(true);
            }
        };
        fetchData();
    }, []);

    const handleLoadingComplete = () => {
        setShowLoader(false);
    };

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

    const getCollapseClass = (level) => {
        if (level === 'Elevated') return 'collapse--elevated';
        if (level === 'Watch') return 'collapse--watch';
        return 'collapse--low';
    };

    // Show loading screen until complete
    if (showLoader) {
        return <LoadingScreen onComplete={dataLoaded ? handleLoadingComplete : undefined} />;
    }

    return (
        <div className="dashboard">
            <Navbar />

            <main className="dashboard__content">
                {/* Ethical Disclaimer */}
                <div className="dashboard__disclaimer">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                        <circle cx="12" cy="12" r="10" />
                        <path d="M12 16v-4" />
                        <path d="M12 8h.01" />
                    </svg>
                    <span>
                        These signals are intended to support early outreach and are not clinical assessments.
                    </span>
                </div>

                {/* Page Header */}
                <header className="dashboard__header">
                    <div>
                        <h1>Preventive Intelligence Dashboard</h1>
                        <p className="dashboard__subtitle">
                            Early support indicators for proactive outreach
                        </p>
                    </div>
                    <div className="dashboard__meta">
                        <span className="dashboard__badge">
                            {stats?.totalStudents || 0} Students Monitored
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

                {/* Silent Risk Indicators Section */}
                {stats && (
                    <section className="silent-risk-section">
                        <div className="silent-risk-section__header">
                            <h2>Silent Risk Indicators</h2>
                            <p>Students showing internal strain patterns without visible academic decline</p>
                        </div>
                        <div className="silent-risk-grid">
                            <div className="silent-risk-card silent-risk-card--elevated">
                                <div className="silent-risk-card__icon">
                                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                                        <path d="M12 9v4" />
                                        <path d="M12 17h.01" />
                                        <path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z" />
                                    </svg>
                                </div>
                                <div className="silent-risk-card__content">
                                    <div className="silent-risk-card__value">{stats.elevatedCollapseRisk || 0}</div>
                                    <div className="silent-risk-card__label">Elevated Attention</div>
                                    <p className="silent-risk-card__desc">Recommend proactive outreach</p>
                                </div>
                            </div>
                            <div className="silent-risk-card silent-risk-card--watch">
                                <div className="silent-risk-card__icon">
                                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                                        <circle cx="12" cy="12" r="10" />
                                        <polyline points="12,6 12,12 16,14" />
                                    </svg>
                                </div>
                                <div className="silent-risk-card__content">
                                    <div className="silent-risk-card__value">{stats.watchCollapseRisk || 0}</div>
                                    <div className="silent-risk-card__label">Under Observation</div>
                                    <p className="silent-risk-card__desc">Monitor for trend changes</p>
                                </div>
                            </div>
                            <div className="silent-risk-card">
                                <div className="silent-risk-card__icon">
                                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                                        <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14" />
                                        <polyline points="22,4 12,14.01 9,11.01" />
                                    </svg>
                                </div>
                                <div className="silent-risk-card__content">
                                    <div className="silent-risk-card__value">
                                        {(stats.totalStudents || 0) - (stats.elevatedCollapseRisk || 0) - (stats.watchCollapseRisk || 0)}
                                    </div>
                                    <div className="silent-risk-card__label">Stable Pattern</div>
                                    <p className="silent-risk-card__desc">No immediate attention needed</p>
                                </div>
                            </div>
                        </div>
                    </section>
                )}

                {/* Stats Cards */}
                {stats && (
                    <div className="stats-grid">
                        <div className="stat-card">
                            <div className="stat-card__value">{stats.totalStudents}</div>
                            <div className="stat-card__label">Total Monitored</div>
                        </div>
                        <div className="stat-card stat-card--high">
                            <div className="stat-card__value">{stats.highRisk}</div>
                            <div className="stat-card__label">High Concern</div>
                        </div>
                        <div className="stat-card stat-card--moderate">
                            <div className="stat-card__value">{stats.moderateRisk}</div>
                            <div className="stat-card__label">Moderate Concern</div>
                        </div>
                        <div className="stat-card stat-card--low">
                            <div className="stat-card__value">{stats.lowRisk}</div>
                            <div className="stat-card__label">Low Concern</div>
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
                        data={displayStudents.slice(0, 50).map((s) => ({
                            week: `#${s.studentId}`,
                            score: s.finalRiskScore
                        }))}
                    />
                </div>

                {/* Filters */}
                <div className="dashboard__filters">
                    <div className="filter-group">
                        <label>Concern Level:</label>
                        <select
                            value={filterLevel}
                            onChange={(e) => setFilterLevel(e.target.value)}
                            className="filter-select"
                        >
                            <option value="all">All Levels</option>
                            <option value="High">High Concern</option>
                            <option value="Moderate">Moderate Concern</option>
                            <option value="Low">Low Concern</option>
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
                                    Concern Score {sortKey === 'finalRiskScore' && (sortDir === 'desc' ? '↓' : '↑')}
                                </th>
                                <th>Concern Level</th>
                                <th>Silent Signal</th>
                                <th>Flags</th>
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
                                    <td>
                                        <span className={`collapse-badge ${getCollapseClass(student.silentCollapseRisk?.level)}`}>
                                            {student.silentCollapseRisk?.level || 'Low'}
                                        </span>
                                    </td>
                                    <td className="table-cell--flags">
                                        {student.ruleTriggers?.length || 0} indicators
                                    </td>
                                    <td>
                                        <button
                                            className="btn-secondary btn-sm"
                                            onClick={() => navigate(`/student/${student.studentId}`)}
                                        >
                                            View Profile
                                        </button>
                                    </td>
                                </tr>
                            ))}
                        </tbody>
                    </table>
                </div>

                {/* Footer */}
                <footer className="dashboard__footer">
                    COGNIS Preventive Intelligence • {stats?.totalStudents || 0} monitored • For early support only
                </footer>
            </main>
        </div>
    );
};

export default Dashboard;
