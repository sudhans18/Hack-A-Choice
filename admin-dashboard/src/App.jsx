/**
 * Main App Component
 * 
 * Faculty/Admin Analytics Dashboard
 * NO student-facing pages.
 * 
 * Routes:
 * - Dashboard (/) - Analytics overview
 * - StudentDetail (/student/:studentId) - Individual student analytics
 */

import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import Dashboard from './pages/Dashboard';
import StudentDetail from './pages/StudentDetail';

// Import styles - theme first for CSS variables
import './styles/theme.css';
import './styles/index.css';
import './styles/animations.css';
import './styles/components.css';

function App() {
  return (
    <Router>
      <Routes>
        {/* Admin Dashboard Routes */}
        <Route path="/" element={<Dashboard />} />
        <Route path="/student/:studentId" element={<StudentDetail />} />

        {/* Redirect any unknown routes to dashboard */}
        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
    </Router>
  );
}

export default App;
