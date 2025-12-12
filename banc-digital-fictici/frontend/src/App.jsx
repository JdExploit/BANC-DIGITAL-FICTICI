import React, { useState, useEffect } from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { createClient } from '@supabase/supabase-js';
import LoginPage from './pages/LoginPage';
import Dashboard from './pages/Dashboard';
import Accounts from './pages/Accounts';
import Transfers from './pages/Transfers';
import Transactions from './pages/Transactions';
import AdminPanel from './pages/AdminPanel';
import Navbar from './components/Navbar';
import Sidebar from './components/Sidebar';
import './styles/bbva.css';


// Vulnerabilidad A05: Secret expuesto en frontend
const supabaseUrl = process.env.REACT_APP_SUPABASE_URL || 'http://localhost:8000';
const supabaseAnonKey = process.env.REACT_APP_SUPABASE_ANON_KEY || 'weak_key_exposed';
const supabaseServiceKey = process.env.REACT_APP_SUPABASE_SERVICE_ROLE_KEY || 'master_key_exposed';

export const supabase = createClient(supabaseUrl, supabaseAnonKey);

function App() {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // Vulnerabilidad A02: Gestión débil de tokens
    const token = localStorage.getItem('jwt_token');
    if (token) {
      try {
        // Decodificar JWT sin verificación (vulnerable)
        const payload = JSON.parse(atob(token.split('.')[1]));
        setUser(payload);
        
        // Vulnerabilidad: No verificar expiración ni firma
        console.log('JWT Payload:', payload);
      } catch (error) {
        console.error('Token inválido');
        localStorage.removeItem('jwt_token');
      }
    }
    setLoading(false);
  }, []);

  const handleLogin = (token) => {
    localStorage.setItem('jwt_token', token);
    const payload = JSON.parse(atob(token.split('.')[1]));
    setUser(payload);
  };

  const handleLogout = () => {
    localStorage.removeItem('jwt_token');
    setUser(null);
  };

  if (loading) {
    return (
      <div className="loading-screen">
        <div className="bbva-spinner"></div>
        <p>Cargando BBVA Digital...</p>
      </div>
    );
  }

  return (
    <Router>
      <div className="app-container">
        {user && <Navbar user={user} onLogout={handleLogout} />}
        <div className="main-content">
          {user && <Sidebar />}
          <div className="content-area">
            <Routes>
              <Route path="/login" element={
                !user ? <LoginPage onLogin={handleLogin} /> : <Navigate to="/dashboard" />
              } />
              <Route path="/dashboard" element={
                user ? <Dashboard user={user} /> : <Navigate to="/login" />
              } />
              <Route path="/accounts" element={
                user ? <Accounts user={user} /> : <Navigate to="/login" />
              } />
              <Route path="/transfers" element={
                user ? <Transfers user={user} /> : <Navigate to="/login" />
              } />
              <Route path="/transactions" element={
                user ? <Transactions user={user} /> : <Navigate to="/login" />
              } />
              <Route path="/admin" element={
                user ? <AdminPanel user={user} /> : <Navigate to="/login" />
              } />
              <Route path="/" element={<Navigate to="/dashboard" />} />
            </Routes>
          </div>
        </div>
      </div>
    </Router>
  );
}

export default App;