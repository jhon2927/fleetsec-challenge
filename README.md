# FleetSec Security Challenge

Prueba tecnica de Ingeniero de Ciberseguridad — FleetSec S.A.S.

## Descripcion

Repositorio con el pipeline DevSecOps, analisis de vulnerabilidades (VAPT), hardening de infraestructura AWS con Terraform, deteccion de amenazas y respuesta a incidentes.

## Estructura del Repositorio

- .github/workflows/ → Pipeline DevSecOps (GitHub Actions)
- .semgrep-rules/ → Reglas SAST personalizadas
- .zap/ → Configuracion OWASP ZAP
- src/ → Aplicacion vulnerable (Node.js)
- modules/security-baseline/ → Modulo Terraform hardening AWS
- sigma-rules/ → Reglas de deteccion (SIEM)
- playbooks/ → Playbooks de respuesta a incidentes
- threat-intel/ → IOCs para GuardDuty
- docs/vapt/ → Reporte VAPT (10 vulnerabilidades)
- docs/ir/ → IOCs, MITRE ATT&CK, RCA, resumen CEO
- docs/compliance-matrix.md → Mapeo CIS/ISO/Ley 1581
- reports/ → Reportes generados

## Setup

### Prerrequisitos

- Docker y Docker Compose
- Terraform v1.0+
- Node.js 18+
- Python 3.10+
- Git

### Instalacion

Clonar repositorio:

    git clone https://github.com/jhon2927/fleetsec-challenge.git
    cd fleetsec-challenge

Levantar app vulnerable:

    docker run -d --name juice-shop -p 3000:3000 bkimminich/juice-shop

Validar Terraform:

    cd modules/security-baseline
    terraform init
    terraform validate
    checkov -d .

## Arquitectura de Seguridad

### Estado Actual vs. Objetivo

| Capa | Estado Actual | Estado Objetivo |
|------|---------------|-----------------|
| CI/CD | Pipeline basico | DevSecOps con SAST+SCA+DAST+SBOM |
| IaC | Sin control | Terraform con hardening + Checkov |
| Deteccion | Sin SIEM | 4 reglas Sigma + GuardDuty |
| IR | Sin playbook | Playbook con rollback + MITRE mapping |
| Cumplimiento | Sin mapeo | Tabla CIS/ISO/Ley 1581 |

### Pipeline DevSecOps

Stages del pipeline:

1. SAST con Semgrep (2 reglas personalizadas)
2. SCA con Trivy filesystem
3. SBOM con CycloneDX via Trivy
4. Secrets con Gitleaks
5. DAST con OWASP ZAP Baseline
6. Container Scan con Trivy image

## ADRs (Architectural Decision Records)

### ADR-001: Ejecucion sin cuenta AWS real

- Contexto: La prueba indica que no se requiere cuenta AWS
- Decision: Usar terraform validate + checkov en local con provider mockeado
- Consecuencias: Menor costo, mayor velocidad, validacion estatica completa

### ADR-002: Stack Node.js + Docker + Terraform

- Contexto: Stack libre segun la prueba
- Decision: Node.js (Express) por simplicidad y ecosistema maduro
- Consecuencias: Rapido desarrollo, amplia disponibilidad de herramientas

### ADR-003: SBOM con Trivy en lugar de CycloneDX CLI

- Contexto: CycloneDX CLI tenia sintaxis compleja en GitHub Actions
- Decision: Usar Trivy con --format cyclonedx (nativo y confiable)
- Consecuencias: Menos dependencias, formato CycloneDX valido

### ADR-004: Terraform con skip_credentials_validation

- Contexto: Validacion local sin credenciales AWS
- Decision: Usar skip_credentials_validation = true y access_key mock
- Consecuencias: terraform validate y plan -refresh=false funcionan sin AWS

## Reporte de IA

### Herramientas utilizadas

- ChatGPT 4 / Claude: Generacion de plantillas YAML (Sigma, Terraform, workflow), sugerencias de remediacion, revision de CVSS vectors.

### Alucinacion detectada y corregida

Prompt: Como corrijo JWT alg:none en Node.js?

Respuesta de la IA:

    jwt.verify(token, 'secret', { algorithms: ['none'] });

Error detectado: La IA sugirio INCLUIR 'none' en la lista de algoritmos permitidos, lo cual es exactamente la vulnerabilidad.

Correccion aplicada:

    jwt.verify(token, process.env.JWT_SECRET, { algorithms: ['HS256'] });

Leccion: La IA puede sugerir codigo sintacticamente valido pero inseguro. Es indispensable validar contra OWASP y documentacion oficial.

### Tareas NO delegadas a IA

No delegaria a IA sin supervision las siguientes tareas:

1. **Analisis de CVSS scoring**: la IA suele sobreestimar vectores sin entender el contexto del activo.
2. **Decisiones de impacto en Ley 1581**: requiere conocimiento legal colombiano y criterio sobre notificacion a la SIC.
3. **Validacion de PoC funcionales**: un PoC debe ejecutarse en entorno real; la IA puede generar payloads que no funcionan.
4. **Priorizacion de remediacion**: depende del contexto de negocio y criticidad del activo.
5. **Interpretacion de resultados de Checkov**: los FAIL deben evaluarse caso por caso; algunos son falsos positivos.
6. **Respuesta a incidentes en vivo**: las decisiones de contencion tienen impacto legal y operativo que requiere criterio humano.

La IA es una herramienta de apoyo, no un reemplazo del criterio profesional.

## Desafios y Proximos Pasos

### Desafios encontrados

1. Sin AWS real: Validacion estatica en lugar de despliegue
2. Tiempo limitado: 5 dias para completar los 5 bloques
3. DAST en CI: ZAP requiere app corriendo, resuelto con continue-on-error

### Proximos pasos

- Desplegar Terraform en cuenta AWS sandbox real
- Implementar WAF v2 con rate limiting
- Integrar SIEM (Elastic/OpenSearch) con las 4 reglas Sigma
- Automatizar rotacion de credenciales con Secrets Manager
- Configurar Security Hub con FSBP + CIS v1.4

## Video Demo

Enlace al video: YouTube - No listado (PENDIENTE)

## Entregables

- [x] Pipeline DevSecOps funcional
- [x] SBOM CycloneDX en cada build
- [x] Reglas Semgrep personalizadas (2)
- [x] Reporte VAPT (10 vulnerabilidades, 10/10 remediadas)
- [x] Modulo Terraform security-baseline
- [x] Checkov scan ejecutado (46 PASS)
- [x] Tabla compliance CIS/ISO/Ley 1581
- [x] 4 reglas Sigma
- [x] Playbook contencion con rollback
- [x] MITRE ATT&CK mapping (8 tecnicas)
- [x] IOCs enriquecidos
- [x] RCA + Resumen CEO
- [x] Reporte IA

## Licencia

Este proyecto es parte de una prueba tecnica.

### Diagrama de Arquitectura

    ┌─────────────────────────────────────────────────────────────┐
    │                       INTERNET                               │
    └──────────────────────────┬──────────────────────────────────┘
                               │
                ┌──────────────┴──────────────┐
                │      WAF v2 (CloudFront)    │
                │  - SQLi Rule Set (BLOCK)    │
                │  - Known Bad Inputs (BLOCK) │
                │  - Rate limiting 1000/5min  │
                └──────────────┬──────────────┘
                               │
                ┌──────────────┴──────────────┐
                │    ALB (Public Subnets)     │
                │    - SG: 80/443 from 0.0.0.0│
                └──────────────┬──────────────┘
                               │
        ┌──────────────────────┴──────────────────────┐
        │                                             │
   ┌────┴─────┐                                 ┌─────┴─────┐
   │  ECS     │                                 │  ECS      │
   │  Task A  │                                 │  Task B   │
   │ (App     │                                 │ (App      │
   │ Subnet)  │                                 │ Subnet)   │
   └────┬─────┘                                 └─────┬─────┘
        │                                             │
        └──────────────────┬──────────────────────────┘
                           │
                  ┌────────┴────────┐
                  │   RDS (Multi-AZ)│
                  │   - Cifrado KMS │
                  │   - Sin público │
                  │   - Backup 7d   │
                  └─────────────────┘

    Monitoreo:
    - CloudTrail (multi-región + log validation)
    - GuardDuty (S3 Protection + Malware)
    - Security Hub (FSBP + CIS v1.4)
    - VPC Flow Logs → S3
    - KMS CMK con rotación anual
    - Secrets Manager con rotación 30d

## Bonus Implementados

### Bonus 1: docker-compose funcional (+5%)

Un comando levanta el entorno completo:

    docker compose up -d

Servicios:
- App vulnerable (puerto 3000)
- OWASP Juice Shop (puerto 3001)
- PostgreSQL (puerto 5432)

Detener:

    docker compose down

### Bonus 2: Hallazgos adicionales (+5%)

5 vulnerabilidades extra mas alla de los 10 tipos base:

- V-11: HTTP Parameter Pollution (CWE-235)
- V-12: Missing Rate Limiting (CWE-770)
- V-13: Insecure Deserialization (CWE-502)
- V-14: Missing Security Headers (CWE-693)
- V-15: Information Disclosure via Errors (CWE-209)

Ver: docs/vapt/02-hallazgos-adicionales.md
