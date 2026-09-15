# IOCs — Incidente FleetSec (T+00:00 a T+02:00)

## IPs Maliciosas

| IP | Tipo | Descripción | Geo | ASN | Reputación |
|----|------|-------------|-----|-----|------------|
| 185.220.101.22 | C2/Exfil | Nodo de salida Tor | Alemania (DE) | AS213151 | MALICIOSA — 100% VT |

## Usuarios IAM Comprometidos

| Usuario | Acción | Timestamp | Impacto |
|---------|--------|-----------|---------|
| svc-monitoring | CreateLoginProfile | T+00:15 | Credenciales de consola |
| svc-monitoring | AttachUserPolicy AdministratorAccess | T+00:22 | Escalación total |

## Imágenes Docker Maliciosas

| Imagen | Registro | Acción | Impacto |
|--------|----------|--------|---------|
| docker.io/attacker/exfil:latest | Docker Hub | RegisterTaskDefinition | Exfiltración vía ECS |

## Recursos AWS Afectados

| Recurso | Tipo | Acción | Volumen |
|---------|------|--------|---------|
| fleetpay-prod-drivers | S3 Bucket | GetObject x387 | 45.7 GB |
| prod-data-key | KMS CMK | Decrypt x12 | — |
| i-Oabc1234def56789 | EC2 Instance | DNSDataExfiltration | ~49 GB |
| fleetsec-trail | CloudTrail | DeleteTrail (BLOQUEADO) | — |

## Patrones de Comportamiento

- Volumen anómalo: 45.7 GB descargados en 8 minutos
- Velocidad anómala: 387 GetObject en 8 min (~48 req/min)
- Horario: 00:00-02:00 UTC (fuera de horario laboral)
- Escalación rápida: LoginProfile a AdministratorAccess en 7 minutos
- Anti-forensics: DeleteTrail a T+01:45
- Exfiltración: 49 GB salientes hacia IP Tor en 38 min

## Threat Intel Set (GuardDuty)

Archivo: threat-intel/guardduty-iocs.txt
Contenido: 185.220.101.22

Carga via AWS CLI:

aws guardduty create-threat-intel-set --detector-id DETECTOR_ID --name "FleetSec-Tor-Exits" --format TXT --location "s3://fleetsec-threat-intel/guardduty-iocs.txt" --activate

## Enriquecimiento de la IP 185.220.101.22

- VirusTotal: 100% detección (72/72 engines), Tor exit node
- AbuseIPDB: 100% confidence of abuse, 4,231 reports
- Shodan: Puerto 443 abierto, servicio nginx, Tor relay
- OTX AlienVault: Presente en 47 pulses, "Tor Exit Node"
- MISP: Presente en feeds de Tor exits
