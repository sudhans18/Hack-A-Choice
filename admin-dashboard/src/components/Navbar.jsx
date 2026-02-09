/**
 * Navbar Component - Preventive Intelligence System
 * 
 * Navigation: Dashboard, Preventive Signals, Insights
 * Uses scroll anchors for single-page navigation.
 */

import React from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import './Navbar.css';

const Navbar = () => {
    const navigate = useNavigate();
    const location = useLocation();

    const handleNavClick = (section) => {
        // Navigate to home if not already there
        if (location.pathname !== '/') {
            navigate('/');
            // Wait for navigation, then scroll
            setTimeout(() => scrollToSection(section), 100);
        } else {
            scrollToSection(section);
        }
    };

    const scrollToSection = (section) => {
        if (section === 'dashboard') {
            window.scrollTo({ top: 0, behavior: 'smooth' });
        } else if (section === 'signals') {
            const el = document.querySelector('.silent-risk-section');
            if (el) el.scrollIntoView({ behavior: 'smooth', block: 'start' });
        } else if (section === 'insights') {
            const el = document.querySelector('.charts-grid');
            if (el) el.scrollIntoView({ behavior: 'smooth', block: 'start' });
        }
    };

    const isActive = (id) => {
        if (location.pathname === '/' && id === 'dashboard') return true;
        if (location.pathname.includes('/student') && id === 'signals') return true;
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
                        <span className="navbar__brand-tagline">Preventive Intelligence</span>
                    </div>
                </div>

                {/* Center: Navigation */}
                <div className="navbar__nav">
                    <button
                        className={`navbar__nav-item ${isActive('dashboard') ? 'navbar__nav-item--active' : ''}`}
                        onClick={() => handleNavClick('dashboard')}
                    >
                        Dashboard
                    </button>
                    <button
                        className={`navbar__nav-item ${isActive('signals') ? 'navbar__nav-item--active' : ''}`}
                        onClick={() => handleNavClick('signals')}
                    >
                        Preventive Signals
                    </button>
                    <button
                        className="navbar__nav-item"
                        onClick={() => handleNavClick('insights')}
                    >
                        Insights
                    </button>
                </div>

                {/* Right: Admin */}
                <div className="navbar__admin">
                    <div className="navbar__admin-info">
                        <span className="navbar__admin-name">Faculty Admin</span>
                        <span className="navbar__admin-role">Early Support Access</span>
                    </div>
                    <div className="navbar__admin-avatar">FA</div>
                </div>
            </div>
        </nav>
    );
};

export default Navbar;
