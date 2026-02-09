/**
 * Main App Component
 * 
 * Sets up React Router for navigation between:
 * - Dashboard (/) - Main at-risk students overview
 * - StudentDetail (/student/:studentId) - Individual student profile
 */

import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import Dashboard from './pages/Dashboard';
import StudentDetail from './pages/StudentDetail';

// Import styles
import './styles/index.css';
import './styles/animations.css';
import './styles/components.css';

function App() {
  return (
    <Router>
      <Routes>
        <Route path="/" element={<Dashboard />} />
        <Route path="/student/:studentId" element={<StudentDetail />} />
      </Routes>
    </Router>
  );
}

export default App;
