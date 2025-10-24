import { useState, useEffect } from 'react'
import './App.css'

function App() {
  const [insumos, setInsumos] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:3001';
    
    console.log('API_URL:', API_URL); 
    fetch(`${API_URL}/insumos`)
      .then(response => {
        console.log('Response status:', response.status);
        if (!response.ok) {
          throw new Error(`Error al cargar los datos: ${response.status}`);
        }
        return response.json();
      })
      .then(data => {
        console.log('Data received:', data);
        setInsumos(data.insumos);
        setLoading(false);
      })
      .catch(err => {
        console.error('Error:', err);
        setError(err.message);
        setLoading(false);
      });
  }, []);

  if (loading) {
    return (
      <div className="container">
        <div className="loading">Cargando insumos...</div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="container">
        <div className="error">Error: {error}</div>
      </div>
    );
  }

  return (
    <div className="container">
      <h1>Lista de Compras - Insumos de Oficina</h1>
      <ul className="lista-compras">
        {insumos.map(item => (
          <li key={item.id} className="item-compra">
            <div className="item-nombre">{item.nombre}</div>
            <div className="item-detalles">
              <span className="item-cantidad">
                Cantidad: {item.cantidad}
              </span>
              <span className="item-precio">
                ${parseFloat(item.precio).toFixed(2)}
              </span>
            </div>
          </li>
        ))}
      </ul>
    </div>
  );
}

export default App
