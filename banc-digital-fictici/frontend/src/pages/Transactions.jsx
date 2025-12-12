import React, { useState } from 'react';

const Transactions = ({ user }) => {
  const [transactions, setTransactions] = useState([
    { id: 1, date: '2024-01-15', description: 'Compra Amazon', amount: -89.99, type: 'Compra' },
    { id: 2, date: '2024-01-14', description: 'Ingreso nómina', amount: 1500.00, type: 'Ingreso' },
    { id: 3, date: '2024-01-13', description: 'Supermercado', amount: -65.50, type: 'Compra' },
    { id: 4, date: '2024-01-12', description: 'Transferencia recibida', amount: 200.00, type: 'Transferencia' },
    { id: 5, date: '2024-01-11', description: 'Pago luz', amount: -45.30, type: 'Factura' }
  ]);

  return (
    <div className="transactions-container">
      <h1>Historial de Transacciones</h1>
      <table className="transactions-table">
        <thead>
          <tr>
            <th>Fecha</th>
            <th>Descripción</th>
            <th>Tipo</th>
            <th>Cantidad</th>
          </tr>
        </thead>
        <tbody>
          {transactions.map(t => (
            <tr key={t.id}>
              <td>{t.date}</td>
              <td>{t.description}</td>
              <td>{t.type}</td>
              <td className={t.amount > 0 ? 'positive' : 'negative'}>
                {t.amount > 0 ? '+' : ''}{t.amount.toLocaleString('es-ES', { style: 'currency', currency: 'EUR' })}
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
};

export default Transactions;