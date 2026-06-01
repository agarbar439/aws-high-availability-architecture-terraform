#!/bin/bash

yum install -y amazon-efs-utils httpd

mkdir -p /mnt/efs

mount -t efs ${efs_id}:/ /mnt/efs

echo "${efs_id}:/ /mnt/efs efs defaults,_netdev 0 0" >> /etc/fstab

echo "Hola! Desde EC2 $HOSTNAME" > /var/www/html/index.html
echo "OK" > /var/www/html/health

systemctl enable httpd
systemctl start httpd