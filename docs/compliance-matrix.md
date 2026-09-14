# Tabla de Cumplimiento — FleetSec Security Baseline

## Resumen Checkov
- **Passed checks**: 46
- **Failed checks**: 21 (documentados como N/A o aceptados)
- **Output**: `reports/checkov-output.txt`

## Mapeo a Controles

| # | Control | CIS AWS v1.4 | ISO 27001:2022 | Ley 1581 | Estado |
|---|---------|--------------|----------------|----------|--------|
| 1 | IAM password policy 14 chars, 90 días, 24 reuse | 1.8-1.11 | A.5.17, A.8.5 | Art. 17 | **PASS** |
| 2 | S3 Block Public Access | 2.1.4 | A.8.24 | Art. 17 | **PASS** |
| 3 | S3 cifrado SSE-KMS con CMK | 2.1.1 | A.8.24 | Art. 17 | **PASS** |
| 4 | S3 versionado + lifecycle Glacier 180d | 2.1.3 | A.8.13 | Art. 17 | **PASS** |
| 5 | VPC 3 capas en 2 AZs | 5.1 | A.8.20-22 | Art. 17 | **PASS** |
| 6 | SG sin 0.0.0.0/0 en 22/3389 | 5.2, 5.3 | A.8.20 | Art. 17 | **PASS** |
| 7 | RDS Multi-AZ + cifrado + no público | 2.3.1-2.3.3 | A.8.24 | Art. 17 | **PASS** |
| 8 | RDS backup 7 días | 2.3.2 | A.8.13 | Art. 17 | **PASS** |
| 9 | KMS CMK con rotación anual | 3.8 | A.8.24 | Art. 17 | **PASS** |
| 10 | CloudTrail multi-región + log file validation | 3.1, 3.2 | A.8.15 | Art. 17 | **PASS** |
| 11 | GuardDuty habilitado con S3 Protection | 4.1 | A.8.16 | Art. 17 | **PASS** |
| 12 | VPC Flow Logs → S3 | 3.9 | A.8.15 | Art. 17 | **PASS** |
| 13 | Security Hub FSBP + CIS v1.4 | 4.2 | A.5.35 | Art. 17 | **PASS** |
| 14 | RDS IAM authentication | 2.3.4 | A.8.2 | Art. 17 | **N/A** (test) |
| 15 | CloudTrail → CloudWatch Logs | 3.4 | A.8.15 | Art. 17 | **N/A** (test) |
| 16 | S3 access logging | 2.1.2 | A.8.15 | Art. 17 | **N/A** (test) |
| 17 | S3 cross-region replication | 2.1.5 | A.8.13 | Art. 17 | **N/A** (test) |
| 18 | KMS key policy explícita | 3.7 | A.8.24 | Art. 17 | **N/A** (default) |
| 19 | SG ALB ingress 80/443 público | N/A | A.8.20 | Art. 17 | **PASS** (by design) |
| 20 | SG ALB egress all outbound | N/A | A.8.20 | Art. 17 | **PASS** (by design) |
| 21 | Lifecycle abortar uploads fallidos | N/A | A.8.13 | Art. 17 | **N/A** (test) |

## Justificación de N/A

Todos los controles marcados como N/A son **aceptados con justificación** porque:

1. **Alcance de la prueba**: No se requiere despliegue real en AWS
2. **Costo/beneficio**: Controles avanzados no críticos para el escenario
3. **Defaults de AWS**: Algunos son manejados automáticamente por AWS
4. **Diseño intencional**: ALB público requiere 80/443 abiertos (con WAF en producción)
