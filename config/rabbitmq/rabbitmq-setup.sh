#!/bin/bash
rabbitmqadmin declare exchange name=proxmox_notifications type=direct durable=true -u admin -p password123
rabbitmqadmin declare queue name=proxmox_backup_notifications durable=true -u admin -p password123
rabbitmqadmin declare binding source=proxmox_notifications destination=proxmox_backup_notifications routing_key=backup_key -u admin -p password123
