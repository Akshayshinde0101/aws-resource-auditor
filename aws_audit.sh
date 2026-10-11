#!/bin/bash

REGION="ap-south-1"
REPORT_DIR="./reports"
TODAY=$(date +%F)
REPORT="$REPORT_DIR/audit_$TODAY.txt"

mkdir -p $REPORT_DIR

audit_ec2() {
  echo "--- Running EC2 instances with NO tags ---"
  aws ec2 describe-instances --region $REGION \
    --filters Name=instance-state-name,Values=running \
    --output json | jq -r '.Reservations[].Instances[] | select(.Tags == null) | .InstanceId'
}

audit_ebs() {
  echo "--- Unattached EBS volumes ---"
  aws ec2 describe-volumes --region $REGION \
    --filters Name=status,Values=available \
    --query 'Volumes[].[VolumeId,Size]' \
    --output text
}

audit_s3() {
  echo "--- S3 buckets ---"
  aws s3 ls
}

echo "AWS Audit Report - $TODAY" > $REPORT
audit_ec2 >> $REPORT
audit_ebs >> $REPORT
audit_s3 >> $REPORT

cat $REPORT
