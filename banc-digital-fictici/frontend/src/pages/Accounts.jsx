import React, { useState, useEffect } from 'react';

const Accounts = ({ user }) => {
  const [accounts, setAccounts] = useState([]);

  useEffect(() => {
    // Datos de ejemplo
    setAccounts([
      { id: 1, type: 'Cuenta Corriente', number: 'ES12000123456789012345', balance: 15000.00, currency: 'EUR' },
      { id: 2, type: 'Cuenta Ahorro', number: 'ES12000123456789012346', balance: 5000.00, currency: 'EUR' },
      { id: 3, type: 'Cuenta Negocios', number: 'ES12000123456789012347', balance: 25000.00, currency: 'EUR' }
    ]);
  }, []);

  return (
    <div className="accounts-container">
      <h1>Mis Cuentas</h1>
      <div className="accounts-grid">
        {accounts.map(account => (
          <div key={account.id} className="account-card">
            <h3>{account.type}</h3>
            <p className="account-number">{account.number}</p>
            <p className="account-balance">
              {account.balance.toLocaleString('es-ES', { style: 'currency', currency: 'EUR' })}
            </p>
          </div>
        ))}
      </div>
    </div>
  );
};

export default Accounts;