/**
 * Navbar Component - Enterprise Analytics
 * 
 * Fixed top navigation for faculty/admin only.
 * Dashboard + ML Analytics navigation.
 */

import React from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import './Navbar.css';

const Navbar = () => {
    const navigate = useNavigate();
    const location = useLocation();

    const navItems = [
        { id: 'dashboard', label: 'Dashboard', path: '/' },
        { id: 'analytics', label: 'ML Analytics', path: '/' },
    ];

    const isActive = (id) => {
        if (location.pathname === '/' && id === 'dashboard') return true;
        if (location.pathname.includes('/student') && id === 'analytics') return true;
        return false;
    };

    return (
        <nav className="navbar">
            <div className="navbar__container">
                {/* Left: Logo */}
                <div className="navbar__brand" onClick={() => navigate('/')}>
                    <div className="navbar__logo">
                        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                            <circle cx="12" cy="12" r="10" />
                            <path d="M12 6v6l4 2" />
                        </svg>
                    </div>
                    <div className="navbar__brand-text">
                        <span className="navbar__brand-name">COGNIS</span>
                        <span className="navbar__brand-tagline">ML Analytics</span>
                    </div>
                </div>

                {/* Center: Navigation */}
                <div className="navbar__nav">
                    {navItems.map((item) => (
                        <button
                            key={item.id}
                            className={`navbar__nav-item ${isActive(item.id) ? 'navbar__nav-item--active' : ''}`}
                            onClick={() => navigate(item.path)}
                        >
                            {item.label}
                        </button>
                    ))}
                </div>

                {/* Right: Admin */}
                <div className="navbar__admin">
                    <div className="navbar__admin-info">
                        <span className="navbar__admin-name">Faculty Admin</span>
                        <span className="navbar__admin-role">Analytics Access</span>
                    </div>
                    <div className="navbar__admin-avatar">FA</div>
                </div>
            </div>
        </nav>
    );
};

export default Navbar;
