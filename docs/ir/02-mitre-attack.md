# MITRE ATT&CK v14 Mapping — Incidente FleetSec

| # | Técnica | ID | Manifestación | Mitigación |
|---|---------|-----|---------------|------------|
| 1 | Valid Accounts | T1078 | Uso de credenciales de svc-monitoring desde IP Tor 185.220.101.22 | MFA obligatorio, rotación de credenciales |
| 2 | Account Manipulation | T1098 | iam:CreateLoginProfile creó contraseña de consola | CloudTrail + alarmas para cambios IAM |
| 3 | Privilege Escalation via Cloud | T1078.004 | iam:AttachUserPolicy con AdministratorAccess | SCP bloqueando políticas admin |
| 4 | Data from Cloud Storage | T1530 | 387 s3:GetObject sobre fleetpay-prod-drivers = 45.7 GB | S3 Access Logs, GuardDuty S3 Protection |
| 5 | Exfiltration Over C2 | T1041 | 49 GB salientes hacia 185.220.101.22 en 38 min | VPC Flow Logs, DNS exfiltration alerts |
| 6 | Impair Defenses: Disable Cloud Logs | T1562.008 | Intento de cloudtrail:DeleteTrail (bloqueado por SCP) | SCP con Deny en cloudtrail:Delete* |
| 7 | Resource Hijacking: Deploy Container | T1610 | ecs:RegisterTaskDefinition con docker.io/attacker/exfil:latest | ECS image scanning, ECR private registry |
| 8 | Use of Cryptography: KMS Decrypt | T1552.001 | 12 kms:Decrypt sobre CMK prod-data-key | KMS key policies, CloudTrail KMS events |

## Kill Chain Fases Detectadas

1. Initial Access: Credenciales comprometidas (T1078)
2. Persistence: LoginProfile creado (T1098)
3. Privilege Escalation: AdministratorAccess (T1078.004)
4. Collection: S3 GetObject masivo (T1530)
5. Exfiltration: DNS + HTTPS a Tor (T1041)
6. Defense Evasion: DeleteTrail intentado (T1562.008)
7. Impact: RegisterTaskDefinition malicioso (T1610)
