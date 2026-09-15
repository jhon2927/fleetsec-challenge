#!/bin/bash
# Playbook de Contencion - Incidente FleetSec
# Autor: FleetSec Security Team
# Fecha: 2026-09-13

set -e

COMPROMISED_USER="svc-monitoring"
COMPROMISED_INSTANCE="i-Oabc1234def56789"
FORENSICS_BUCKET="fleetsec-forensics-$(date +%Y%m%d)"

echo "INICIANDO CONTENCION - $(date)"

# PASO 1: Revocar credenciales
echo "Paso 1: Revocando credenciales de $COMPROMISED_USER"
KEYS=$(aws iam list-access-keys --user-name $COMPROMISED_USER \
       --query 'AccessKeyMetadata[].AccessKeyId' --output text)
for KEY in $KEYS; do
  aws iam update-access-key --user-name $COMPROMISED_USER \
    --access-key-id $KEY --status Inactive
  aws iam delete-access-key --user-name $COMPROMISED_USER \
    --access-key-id $KEY
done
# ROLLBACK: aws iam create-access-key --user-name $COMPROMISED_USER

# PASO 2: Desactivar usuario IAM
echo "Paso 2: Desactivando usuario IAM"
aws iam delete-login-profile --user-name $COMPROMISED_USER || true
aws iam attach-user-policy --user-name $COMPROMISED_USER \
  --policy-arn arn:aws:iam::aws:policy/AWSDenyAll
# ROLLBACK: aws iam detach-user-policy --user-name $COMPROMISED_USER \
#           --policy-arn arn:aws:iam::aws:policy/AWSDenyAll

# PASO 3: Revocar sesiones activas
echo "Paso 3: Revocando sesiones activas"
aws iam put-user-policy --user-name $COMPROMISED_USER \
  --policy-name RevokeOldSessions \
  --policy-document '{"Version":"2012-10-17","Statement":[{"Effect":"Deny","Action":"*","Resource":"*","Condition":{"DateLessThan":{"aws:TokenIssueTime":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"}}}]}'
# ROLLBACK: aws iam delete-user-policy --user-name $COMPROMISED_USER --policy-name RevokeOldSessions

# PASO 4: Aislar instancia EC2
echo "Paso 4: Aislando instancia $COMPROMISED_INSTANCE"
VPC_ID=$(aws ec2 describe-instances --instance-ids $COMPROMISED_INSTANCE \
  --query 'Reservations[0].Instances[0].VpcId' --output text)
QUARANTINE_SG_ID=$(aws ec2 create-security-group \
  --group-name "quarantine-$(date +%s)" \
  --description "Quarantine SG - IR" \
  --vpc-id $VPC_ID \
  --query 'GroupId' --output text)

aws ec2 describe-instances --instance-ids $COMPROMISED_INSTANCE \
  --query 'Reservations[0].Instances[0].SecurityGroups' \
  --output json > /tmp/original-sgs.json

aws ec2 modify-instance-attribute --instance-id $COMPROMISED_INSTANCE \
  --groups $QUARANTINE_SG_ID
# ROLLBACK: aws ec2 modify-instance-attribute --instance-id $COMPROMISED_INSTANCE --groups SG_ORIGINAL

# PASO 5: Preservar evidencia
echo "Paso 5: Preservando evidencia forense"
VOLUMES=$(aws ec2 describe-volumes \
  --filters "Name=attachment.instance-id,Values=$COMPROMISED_INSTANCE" \
  --query 'Volumes[].VolumeId' --output text)
for VOL in $VOLUMES; do
  aws ec2 create-snapshot --volume-id $VOL \
    --description "IR FleetSec - $(date)" \
    --tag-specifications 'ResourceType=snapshot,Tags=[{Key=Incident,Value=FleetSec-20260913}]'
done

aws s3 mb s3://$FORENSICS_BUCKET
aws s3api put-object-lock-configuration \
  --bucket $FORENSICS_BUCKET \
  --object-lock-configuration '{"ObjectLockEnabled":"Enabled","Rule":{"DefaultRetention":{"Mode":"COMPLIANCE","Days":365}}}'

aws s3 sync s3://fleetsec-logs-dev/AWSLogs/ s3://$FORENSICS_BUCKET/cloudtrail/ \
  --exclude "*" --include "*/2026/09/13/*"

echo "CONTENCION COMPLETADA - $(date)"
echo "Evidencia en: s3://$FORENSICS_BUCKET/"
