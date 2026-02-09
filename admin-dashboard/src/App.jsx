/**
 * Main App Component
 * 
 * Sets up React Router for navigation between:
 * - Dashboard (/) - Admin at-risk students overview
 * - StudentDetail (/student/:studentId) - Individual student profile (admin view)
 * - StudentPortal (/portal) - Student-facing wellness view
 * - StudentPortal (/portal/:studentId) - Specific student wellness view
 */

import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import Dashboard from './pages/Dashboard';
import StudentDetail from './pages/StudentDetail';
import StudentPortal from './pages/StudentPortal';

// Import styles
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

        {/* Student Portal Routes */}
        <Route path="/portal" element={<StudentPortal />} />
        <Route path="/portal/:studentId" element={<StudentPortal />} />
      </Routes>
    </Router>
  );
}

export default App;
