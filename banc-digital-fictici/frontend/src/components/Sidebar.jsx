import React from 'react';
import { NavLink } from 'react-router-dom';

const Sidebar = () => {
  const menuItems = [
    { path: '/dashboard', icon: 'fas fa-home', label: 'Dashboard' },
    { path: '/accounts', icon: 'fas fa-wallet', label: 'Cuentas' },
    { path: '/transfers', icon: 'fas fa-exchange-alt', label: 'Transferencias' },
    { path: '/transactions', icon: 'fas fa-history', label: 'Transacciones' },
    { path: '/admin', icon: 'fas fa-cog', label: 'Administración' }
  ];

  return (
    <div className="sidebar">
      <div className="sidebar-header">
        <h3>Menú Principal</h3>
      </div>
      <nav className="sidebar-nav">
        {menuItems.map(item => (
          <NavLink
            key={item.path}
            to={item.path}
            className={({ isActive }) => 
              `sidebar-item ${isActive ? 'active' : ''}`
            }
          >
            <i className={item.icon}></i>
            <span>{item.label}</span>
          </NavLink>
        ))}
      </nav>
      
      <div className="sidebar-footer">
        <div className="security-lab">
          <i className="fas fa-flask"></i>
          <span>Laboratorio OWASP</span>
        </div>
      </div>
    </div>
  );
};

export default Sidebar;