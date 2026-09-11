import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import { App } from './App.js';
import './styles.css';
import './design.css';
import { ThemeProvider } from './components/ThemeProvider.js';

const contenedor = document.getElementById('root');
if (!contenedor) {
  throw new Error('No existe el elemento #root en index.html');
}

createRoot(contenedor).render(
  <StrictMode>
    <ThemeProvider>
      <App />
    </ThemeProvider>
  </StrictMode>,
);
