# Hallazgos Adicionales (BONUS)

Vulnerabilidades mas alla de los 10 tipos base, con evidencia reproducible.

---

## V-11: HTTP Parameter Pollution (CWE-235)

- **CVSS v3:** 5.3 MEDIUM
- **Vector:** CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:N/I:L/A:N
- **OWASP:** A03 - Injection
- **CWE:** CWE-235

### PoC

Enviar el mismo parametro multiple veces:

    curl "http://localhost:3001/rest/products/search?q=apple&q=admin"

### Impacto

El backend procesa solo el ultimo valor, permitiendo bypass de filtros.

### Remediacion

    const q = Array.isArray(req.query.q) ? req.query.q[0] : req.query.q;

---

## V-12: Missing Rate Limiting (CWE-770)

- **CVSS v3:** 7.5 HIGH
- **Vector:** CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:N/A:N
- **OWASP:** A04 - Insecure Design
- **CWE:** CWE-770

### PoC

Brute force sin restricciones:

    for i in $(seq 1 1000); do
      curl -X POST http://localhost:3001/rest/user/login \
        -H "Content-Type: application/json" \
        -d '{"email":"admin","password":"pass'$i'"}'
    done

### Remediacion

    const rateLimit = require('express-rate-limit');
    const loginLimiter = rateLimit({
      windowMs: 5 * 60 * 1000,
      max: 5,
      message: 'Demasiados intentos'
    });
    app.use('/rest/user/login', loginLimiter);

---

## V-13: Insecure Deserialization (CWE-502)

- **CVSS v3:** 8.1 HIGH
- **OWASP:** A08 - Software and Data Integrity Failures
- **CWE:** CWE-502

### PoC

Cookie manipulada:

    curl -X POST http://localhost:3001/rest/user/login \
      -H "Cookie: session={\"user\":\"admin\",\"isAdmin\":true}"

### Remediacion

    const decoded = jwt.verify(cookie, process.env.JWT_SECRET);
    if (typeof decoded !== 'object' || !decoded.user) {
      return res.status(401).json({ error: 'Sesion invalida' });
    }

---

## V-14: Missing Security Headers (CWE-693)

- **CVSS v3:** 4.3 MEDIUM
- **OWASP:** A05 - Security Misconfiguration
- **CWE:** CWE-693

### PoC

    curl -I http://localhost:3001

### Headers faltantes

- X-Content-Type-Options
- X-Frame-Options
- Content-Security-Policy
- Strict-Transport-Security
- Referrer-Policy

### Remediacion

    const helmet = require('helmet');
    app.use(helmet());

---

## V-15: Information Disclosure via Errors (CWE-209)

- **CVSS v3:** 5.3 MEDIUM
- **OWASP:** A04 - Insecure Design
- **CWE:** CWE-209

### PoC

Error que filtra stack trace:

    curl "http://localhost:3001/rest/user/login" -X POST \
      -H "Content-Type: application/json" \
      -d '{"email":"invalid"}'

### Remediacion

    app.use((err, req, res, next) => {
      console.error(err.stack);
      res.status(500).json({ error: 'Error interno del servidor' });
    });

---

## Resumen Hallazgos Adicionales

| ID | Vulnerabilidad | CVSS | CWE |
|----|----------------|------|-----|
| V-11 | HTTP Parameter Pollution | 5.3 MEDIUM | CWE-235 |
| V-12 | Missing Rate Limiting | 7.5 HIGH | CWE-770 |
| V-13 | Insecure Deserialization | 8.1 HIGH | CWE-502 |
| V-14 | Missing Security Headers | 4.3 MEDIUM | CWE-693 |
| V-15 | Information Disclosure | 5.3 MEDIUM | CWE-209 |

**Total: 5 vulnerabilidades adicionales.**
