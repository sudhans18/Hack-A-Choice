/**
 * Dashboard Page
 * 
 * Main admin dashboard showing:
 * - Summary statistics (total students, risk breakdowns)
 * - Sortable table of at-risk students
 * - Clickable rows navigating to student detail
 * 
 * Features glassmorphism styling and smooth animations.
 */

import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import GlassCard from '../components/GlassCard';
import RiskBadge from '../components/RiskBadge';
import { getAtRiskStudents, getDashboardStats } from '../services/api';

const Dashboard = () => {
    const navigate = useNavigate();
    const [students, setStudents] = useState([]);
    const [stats, setStats] = useState(null);
    const [sortField, setSortField] = useState('riskScore');
    const [sortDirection, setSortDirection] = useState('desc');
    const [loading, setLoading] = useState(true);

    // Fetch data on mount
    useEffect(() => {
        const fetchData = async () => {
            setLoading(true);
            const [studentsData, statsData] = await Promise.all([
                getAtRiskStudents(),
                getDashboardStats()
            ]);
            setStudents(studentsData);
            setStats(statsData);
            setLoading(false);
        };
        fetchData();
    }, []);

    // Handle sorting
    const handleSort = (field) => {
        if (sortField === field) {
            setSortDirection(sortDirection === 'asc' ? 'desc' : 'asc');
        } else {
            setSortField(field);
            setSortDirection('desc');
        }
    };

    // Sort students
    const sortedStudents = [...students].sort((a, b) => {
        let aVal = a[sortField];
        let bVal = b[sortField];

        if (typeof aVal === 'string') {
            aVal = aVal.toLowerCase();
            bVal = bVal.toLowerCase();
        }

        if (sortDirection === 'asc') {
            return aVal > bVal ? 1 : -1;
        } else {
            return aVal < bVal ? 1 : -1;
        }
    });

    // Navigate to student detail
    const handleRowClick = (studentId) => {
        navigate(`/student/${studentId}`);
    };

    // Sort indicator
    const SortIndicator = ({ field }) => {
        if (sortField !== field) return <span style={{ opacity: 0.3 }}> ↕</span>;
        return <span> {sortDirection === 'asc' ? '↑' : '↓'}</span>;
    };

    if (loading) {
        return (
            <div className="container animate-fade-in" style={{ textAlign: 'center', paddingTop: '100px' }}>
                <div className="animate-pulse-glow" style={{ fontSize: '2rem' }}>Loading...</div>
            </div>
        );
    }

    return (
        <div className="container animate-fade-in">
            {/* Header */}
            <header className="header">
                <div className="header__logo">
                    <div className="header__logo-icon">🎓</div>
                    <h1 className="header__title">Student Wellness Monitor</h1>
                </div>
                <div>
                    <button className="btn btn-primary">
                        📊 Generate Report
                    </button>
                </div>
            </header>

            {/* Stats Overview */}
            <div className="stats-grid stagger-children">
                <GlassCard className="stat-card">
                    <div className="stat-card__value">{stats?.totalStudents || 0}</div>
                    <div className="stat-card__label">Total Students Monitored</div>
                </GlassCard>

                <GlassCard className="stat-card">
                    <div className="stat-card__value" style={{ color: '#ef4444' }}>
                        {stats?.highRisk || 0}
                    </div>
                    <div className="stat-card__label">High Risk</div>
                </GlassCard>

                <GlassCard className="stat-card">
                    <div className="stat-card__value" style={{ color: '#f59e0b' }}>
                        {stats?.moderateRisk || 0}
                    </div>
                    <div className="stat-card__label">Moderate Risk</div>
                </GlassCard>

                <GlassCard className="stat-card">
                    <div className="stat-card__value" style={{ color: '#22c55e' }}>
                        {stats?.lowRisk || 0}
                    </div>
                    <div className="stat-card__label">Low Risk</div>
                </GlassCard>
            </div>

            {/* Students Table */}
            <GlassCard noHover style={{ overflow: 'hidden' }}>
                <h2 style={{ marginBottom: 'var(--space-6)' }}>At-Risk Students</h2>

                <div style={{ overflowX: 'auto' }}>
                    <table className="data-table">
                        <thead>
                            <tr>
                                <th
                                    onClick={() => handleSort('name')}
                                    className={sortField === 'name' ? 'sorted' : ''}
                                >
                                    Student Name <SortIndicator field="name" />
                                </th>
                                <th
                                    onClick={() => handleSort('department')}
                                    className={sortField === 'department' ? 'sorted' : ''}
                                >
                                    Department <SortIndicator field="department" />
                                </th>
                                <th
                                    onClick={() => handleSort('year')}
                                    className={sortField === 'year' ? 'sorted' : ''}
                                >
                                    Year <SortIndicator field="year" />
                                </th>
                                <th
                                    onClick={() => handleSort('riskScore')}
                                    className={sortField === 'riskScore' ? 'sorted' : ''}
                                >
                                    Risk Score <SortIndicator field="riskScore" />
                                </th>
                                <th>Status</th>
                                <th>Flags</th>
                            </tr>
                        </thead>
                        <tbody className="stagger-children">
                            {sortedStudents.map((student) => (
                                <tr
                                    key={student.id}
                                    onClick={() => handleRowClick(student.id)}
                                >
                                    <td>
                                        <div style={{ display: 'flex', alignItems: 'center', gap: 'var(--space-3)' }}>
                                            <div
                                                style={{
                                                    width: 36,
                                                    height: 36,
                                                    borderRadius: 'var(--radius-md)',
                                                    background: 'linear-gradient(135deg, var(--purple), var(--blue))',
                                                    display: 'flex',
                                                    alignItems: 'center',
                                                    justifyContent: 'center',
                                                    fontWeight: 600,
                                                    fontSize: '0.875rem'
                                                }}
                                            >
                                                {student.name.split(' ').map(n => n[0]).join('')}
                                            </div>
                                            <div>
                                                <div style={{ fontWeight: 500 }}>{student.name}</div>
                                                <div style={{ fontSize: '0.75rem', color: 'var(--gray-400)' }}>
                                                    {student.email}
                                                </div>
                                            </div>
                                        </div>
                                    </td>
                                    <td style={{ color: 'var(--gray-300)' }}>{student.department}</td>
                                    <td style={{ color: 'var(--gray-300)' }}>Year {student.year}</td>
                                    <td>
                                        <span style={{
                                            fontWeight: 700,
                                            fontSize: '1.125rem',
                                            color: student.riskScore > 60 ? '#ef4444' :
                                                student.riskScore > 30 ? '#f59e0b' : '#22c55e'
                                        }}>
                                            {student.riskScore}
                                        </span>
                                    </td>
                                    <td>
                                        <RiskBadge score={student.riskScore} />
                                    </td>
                                    <td style={{ color: 'var(--gray-400)' }}>
                                        {student.triggeredRules.length > 0
                                            ? `${student.triggeredRules.length} rule${student.triggeredRules.length > 1 ? 's' : ''} triggered`
                                            : '—'}
                                    </td>
                                </tr>
                            ))}
                        </tbody>
                    </table>
                </div>
            </GlassCard>

            {/* Footer */}
            <footer style={{
                textAlign: 'center',
                padding: 'var(--space-8) 0',
                color: 'var(--gray-500)',
                fontSize: '0.875rem'
            }}>
                Academic Stress Early Warning System • Prototype Demo
            </footer>
        </div>
    );
};

export default Dashboard;
