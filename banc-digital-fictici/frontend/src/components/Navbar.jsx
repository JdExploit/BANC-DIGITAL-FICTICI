import React from 'react';

const Navbar = ({ user, onLogout }) => {
  return (
    <nav className="navbar">
      <div className="navbar-brand">
        <i className="fas fa-university"></i>
        <span className="navbar-logo">BBVA Digital</span>
      </div>
      
      <div className="navbar-user">
        <div className="user-info">
          <i className="fas fa-user-circle"></i>
          <div>
            <strong>{user?.name || 'Usuario'}</strong>
            <small>{user?.email}</small>
          </div>
        </div>
        <button className="logout-button" onClick={onLogout}>
          <i className="fas fa-sign-out-alt"></i> Salir
        </button>
      </div>
    </nav>
  );
};

export default Navbar;