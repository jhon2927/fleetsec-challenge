const express = require('express');
const jwt = require('jsonwebtoken');
const app = express();
app.use(express.json());

// V-01: SQL Injection - Query sin parametrizar
app.get('/users', (req, res) => {
  const id = req.query.id;
  const query = `SELECT * FROM users WHERE id = ${id}`;
  res.json({ query, message: 'Endpoint vulnerable a SQL Injection' });
});

// V-02: JWT alg:none - Token sin firma válida
app.post('/login', (req, res) => {
  const token = jwt.sign(
    { user: req.body.username || 'guest' },
    'secret',
    { algorithm: 'none' }
  );
  res.json({ token });
});

// V-03: SSRF - Sin validación de URL
app.get('/fetch', async (req, res) => {
  const url = req.query.url;
  try {
    const response = await fetch(url);
    const data = await response.text();
    res.send(data);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Endpoint raíz
app.get('/', (req, res) => res.send('FleetSec S.A.S. - Security Challenge'));

app.listen(3000, () => console.log('App running on port 3000'));
