# RCA y Resumen Ejecutivo — Incidente FleetSec

## A. Root Cause Analysis

### Vector Inicial (Hipótesis Justificada)

Credenciales del usuario svc-monitoring comprometidas, probablemente por:
- Exposición en repositorio de código
- Phishing dirigido a administrador
- Reutilización de credenciales de breach previo

Evidencia: ConsoleLoginSuccess.B desde IP Tor a T+00:00, seguido de CreateLoginProfile 15 min después.

### Attack Path

T+00:00  Login desde Tor 185.220.101.22
T+00:15  CreateLoginProfile - credenciales persistentes
T+00:22  AttachUserPolicy AdministratorAccess - escalación total
T+00:35  S3 GetObject x387 - exfiltración de 45.7 GB
T+00:58  KMS Decrypt x12 - acceso a datos cifrados
T+01:10  VPC Flow Logs: 49 GB salientes a Tor
T+01:40  ECS RegisterTaskDefinition con imagen maliciosa
T+01:45  Intento de DeleteTrail - BLOQUEADO por SCP
T+01:50  GuardDuty detecta EC2/DNSDataExfiltration
T+02:00  Alerta recibida por equipo de seguridad

### Por Qué Fallaron los Controles

| Control Esperado | Estado Real | Por Qué Falló |
|------------------|-------------|---------------|
| MFA en cuenta de servicio | No implementado | Cuenta de servicio sin MFA |
| Detección impossible travel | No existía | Sin GuardDuty activo antes |
| Alertas de volumen S3 | No configuradas | Sin CloudWatch alarms |
| Egress filtering | Ausente | VPC sin NACL restrictivo |
| SCP completo | Parcial | Bloqueó DeleteTrail pero no AttachUserPolicy |

---

## B. Resumen Ejecutivo para CEO

Para: CEO FleetSec S.A.S.
De: Equipo de Seguridad
Asunto: Incidente de seguridad - Breach confirmado

### Qué ocurrió

El 13 de septiembre a las 00:00 UTC, un atacante externo accedió a nuestros sistemas usando credenciales comprometidas de una cuenta de servicio. En menos de dos horas logró:

1. Escalar privilegios hasta administrador total
2. Descargar 45.7 GB de datos del bucket fleetpay-prod-drivers
3. Exfiltrar 49 GB hacia un servidor en Alemania (red Tor)
4. Intentar borrar logs (bloqueado por nuestros controles)

### Qué datos se expusieron

El bucket comprometido contiene datos personales de conductores:
- Nombres completos
- Documentos de identidad
- Datos de contacto
- Información de vehículos

Clasificación Ley 1581: Datos personales - notificación obligatoria a la SIC en 15 días hábiles.

### Impacto Ley 1581

- Artículo 17: Deber de notificar a la SIC
- Artículo 18: Deber de informar a los titulares
- Plazo: 15 días hábiles desde detección
- Riesgo: Multas hasta 2,000 SMMLV + daño reputacional

### Acciones Inmediatas (próximas 24h)

1. Notificar a la SIC - iniciar trámite formal hoy
2. Notificar a los titulares afectados
3. Auditar cuentas de servicio - rotar credenciales y agregar MFA
4. Habilitar GuardDuty en todas las cuentas
5. Contratar forense externo

### Estado Actual

- Credenciales comprometidas revocadas
- Instancia EC2 aislada en cuarentena
- Evidencia preservada con Object Lock 365 días
- Investigación forense en curso
- Notificación a SIC pendiente (vence 4 octubre)

---

## C. Plan de Remediación Post-Incidente

| Prioridad | Acción | Esfuerzo | Responsable |
|-----------|--------|----------|-------------|
| P1 | Rotar TODAS las credenciales de cuentas de servicio | 1 día | DevOps + Sec |
| P1 | Habilitar MFA obligatorio en todas las cuentas IAM | 2 días | Sec |
| P1 | Notificar a SIC (Ley 1581) | 1 día | Legal + Sec |
| P1 | SCP que bloquee AttachUserPolicy sin aprobación | 3 días | Cloud Team |
| P2 | CloudWatch Alarms para S3 GetObject anómalo | 1 semana | Sec + DevOps |
| P2 | VPC NACLs restrictivos en subred data | 1 semana | Cloud Team |
| P2 | ECR privado + image scanning obligatorio | 2 semanas | DevOps |
| P3 | GuardDuty Malware Protection en todas las cuentas | 3 semanas | Sec |
| P3 | Rotación automática con Secrets Manager | 1 mes | Sec + DevOps |
| P3 | Auditoría de accesos IAM (últimos 90 días) | 1 mes | Sec |
