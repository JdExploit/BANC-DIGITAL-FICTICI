import React, { useState } from 'react';
import '../styles/login.css';

const LoginPage = ({ onLogin }) => {
  const [credentials, setCredentials] = useState({ email: '', password: '' });
  const [error, setError] = useState('');

  // Usuarios de prueba
  const testUsers = [
    { email: 'cliente1@bbva.es', password: 'Password123!', name: 'Juan Pérez', id: '11111111-1111-1111-1111-111111111101', role: 'client' },
    { email: 'cliente2@bbva.es', password: 'Password123!', name: 'María García', id: '11111111-1111-1111-1111-111111111102', role: 'client' },
    { email: 'admin@bbva.es', password: 'AdminPassword123!', name: 'Admin BBVA', id: '11111111-1111-1111-1111-111111111103', role: 'service_role' }
  ];

  const handleLogin = (e) => {
    e.preventDefault();
    setError('');
    
    // Vulnerabilidad A02: Autenticación débil - sin verificación real
    const user = testUsers.find(u => 
      u.email === credentials.email && u.password === credentials.password
    );
    
    if (user) {
      // Generar JWT débil (vulnerable)
      const payload = {
        sub: user.id,
        email: user.email,
        name: user.name,
        role: user.role,
        iat: Math.floor(Date.now() / 1000),
        exp: Math.floor(Date.now() / 1000) + (60 * 60) // 1 hora
      };
      
      // Vulnerabilidad: Secret débil y conocido
      const secret = 'weak_jwt_secret_change_me';
      const token = btoa(JSON.stringify({ 
        alg: 'HS256', 
        typ: 'JWT' 
      })) + '.' + 
      btoa(JSON.stringify(payload)) + '.' + 
      btoa(secret); // Esto NO es cómo funciona JWT realmente, es para demostración
      
      onLogin(token);
    } else {
      setError('Credenciales incorrectas');
    }
  };

  const handleQuickLogin = (user) => {
    setCredentials({ email: user.email, password: user.password });
    setTimeout(() => {
      document.querySelector('form').dispatchEvent(new Event('submit'));
    }, 100);
  };

  return (
    <div className="login-container">
      <div className="login-card">
        <div className="login-header">
          <div className="bbva-logo">
            <i className="fas fa-university"></i>
            <h1>BBVA Digital</h1>
          </div>
          <p>Laboratorio de Seguridad Bancaria</p>
        </div>

        <form onSubmit={handleLogin}>
          <div className="form-group">
            <label>Email</label>
            <input
              type="email"
              value={credentials.email}
              onChange={(e) => setCredentials({...credentials, email: e.target.value})}
              placeholder="usuario@bbva.es"
              required
            />
          </div>

          <div className="form-group">
            <label>Contraseña</label>
            <input
              type="password"
              value={credentials.password}
              onChange={(e) => setCredentials({...credentials, password: e.target.value})}
              placeholder="••••••••"
              required
            />
          </div>

          {error && <div className="error-message">{error}</div>}

          <button type="submit" className="login-button">
            <i className="fas fa-sign-in-alt"></i> Iniciar Sesión
          </button>
        </form>

        <div className="test-users">
          <h3>👥 Usuarios de Prueba</h3>
          {testUsers.map(user => (
            <button 
              key={user.email}
              className="user-button"
              onClick={() => handleQuickLogin(user)}
            >
              <div>
                <strong>{user.name}</strong>
                <small>{user.email}</small>
              </div>
              <span className="role-badge">{user.role}</span>
            </button>
          ))}
        </div>

        <div className="security-warning">
          <i className="fas fa-exclamation-triangle"></i>
          <p>Sistema de demostración con vulnerabilidades intencionales</p>
        </div>
      </div>
    </div>
  );
};

export default LoginPage;