import React, { useState, useEffect } from 'react';
// CORRECTO: Importa desde la raíz de src
import { supabase } from '../../App';
// O mejor, importa directamente el cliente:
import { createClient } from '@supabase/supabase-js';
import '../styles/dashboard.css';

const Dashboard = ({ user }) => {
  const [accounts, setAccounts] = useState([]);
  const [balance, setBalance] = useState(0);
  const [recentTransactions, setRecentTransactions] = useState([]);

  useEffect(() => {
    fetchUserData();
  }, []);

  // Vulnerabilidad A01: IDOR - Permite cambiar user_id
  const fetchUserData = async () => {
    // URL vulnerable: puede cambiarse el user_id para ver datos de otros usuarios
    const url = `/rest/v1/accounts?user_id=eq.${user.sub}&select=*`;
    
    try {
      const response = await fetch(`${process.env.REACT_APP_SUPABASE_URL}${url}`, {
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('jwt_token')}`,
          'apikey': process.env.REACT_APP_SUPABASE_ANON_KEY
        }
      });
      
      const data = await response.json();
      setAccounts(data);
      
      if (data.length > 0) {
        setBalance(data[0].balance);
        
        // Fetch transactions (vulnerable a IDOR)
        fetchTransactions(data[0].account_number);
      }
    } catch (error) {
      console.error('Error fetching data:', error);
    }
  };

  // Vulnerabilidad A03: SQL Injection a través de PostgREST
  const fetchTransactions = async (accountNumber) => {
    // Campo vulnerable a inyección SQL
    const searchParam = new URLSearchParams(window.location.search).get('search') || '';
    
    // Vulnerable a RQL injection
    const url = `/rest/v1/transactions?account_number=eq.${accountNumber}&order=created_at.desc&limit=10`;
    
    try {
      const response = await fetch(`${process.env.REACT_APP_SUPABASE_URL}${url}`, {
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('jwt_token')}`,
          'apikey': process.env.REACT_APP_SUPABASE_ANON_KEY
        }
      });
      
      const data = await response.json();
      setRecentTransactions(data);
    } catch (error) {
      console.error('Error fetching transactions:', error);
    }
  };

  // Función para explotar IDOR
  const exploitIDOR = async (targetUserId) => {
    // Vulnerabilidad: Cambiar user_id para acceder a datos de otros
    const url = `/rest/v1/accounts?user_id=eq.${targetUserId}&select=*`;
    
    try {
      const response = await fetch(`${process.env.REACT_APP_SUPABASE_URL}${url}`, {
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('jwt_token')}`,
          'apikey': process.env.REACT_APP_SUPABASE_ANON_KEY
        }
      });
      
      const data = await response.json();
      alert(`Datos del usuario ${targetUserId}: ${JSON.stringify(data)}`);
    } catch (error) {
      console.error('Error en IDOR:', error);
    }
  };

  return (
    <div className="dashboard-container">
      <div className="welcome-banner">
        <h1>Bienvenido, {user.name || 'Cliente'}</h1>
        <p>BBVA Digital - Tu banca online segura</p>
      </div>
      
      <div className="dashboard-grid">
        {/* Tarjeta de Saldo Principal */}
        <div className="balance-card bbva-blue">
          <h3>Saldo Total</h3>
          <h1>{balance.toLocaleString('es-ES', { style: 'currency', currency: 'EUR' })}</h1>
          <p>Disponible para transferencias</p>
          <div className="balance-actions">
            <button className="btn-primary">Ingresar</button>
            <button className="btn-outline">Retirar</button>
          </div>
        </div>
        
        {/* Cuentas */}
        <div className="accounts-card">
          <h3>Mis Cuentas</h3>
          {accounts.map(account => (
            <div key={account.id} className="account-item">
              <div>
                <strong>{account.account_type}</strong>
                <p>ES12 {account.account_number}</p>
              </div>
              <div className="account-balance">
                {account.balance.toLocaleString('es-ES', { style: 'currency', currency: 'EUR' })}
              </div>
            </div>
          ))}
        </div>
        
        {/* Últimas Transacciones */}
        <div className="transactions-card">
          <h3>Últimas Transacciones</h3>
          {recentTransactions.map(transaction => (
            <div key={transaction.id} className="transaction-item">
              <div>
                <strong>{transaction.description}</strong>
                <p>{new Date(transaction.created_at).toLocaleDateString()}</p>
              </div>
              <div className={`transaction-amount ${transaction.amount > 0 ? 'positive' : 'negative'}`}>
                {transaction.amount > 0 ? '+' : ''}
                {transaction.amount.toLocaleString('es-ES', { style: 'currency', currency: 'EUR' })}
              </div>
            </div>
          ))}
        </div>
        
        {/* Panel de Explotación (para el laboratorio) */}
        <div className="exploit-panel">
          <h3>🧪 Laboratorio de Seguridad</h3>
          <div className="exploit-actions">
            <button 
              className="btn-warning"
              onClick={() => exploitIDOR(101)}
            >
              Explotar IDOR (Usuario 101)
            </button>
            <button 
              className="btn-warning"
              onClick={() => exploitIDOR(102)}
            >
              Explotar IDOR (Usuario 102)
            </button>
            <button 
              className="btn-danger"
              onClick={() => {
                // Ejemplo de modificación de JWT
                const token = localStorage.getItem('jwt_token');
                if (token) {
                  const parts = token.split('.');
                  const payload = JSON.parse(atob(parts[1]));
                  payload.role = 'service_role'; // Escalada de privilegios
                  parts[1] = btoa(JSON.stringify(payload));
                  localStorage.setItem('jwt_token', parts.join('.'));
                  alert('JWT modificado! Recarga la página');
                }
              }}
            >
              Modificar JWT (A02)
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Dashboard;