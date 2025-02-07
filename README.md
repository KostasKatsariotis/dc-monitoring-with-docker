# Dockerized Monitoring and Notification System

## Overview
This project is a complete containerized solution for Proxmox monitoring (single host or cluster). It integrates:

- **Prometheus**: Monitoring and metrics collection.
- **Grafana**: Visualization and alerting.
- **RabbitMQ**: Message queue for notifications.
- **Node-RED**: Workflow automation for email notifications.
- **Keycloak**: Identity and access management.
- **PostgreSQL**: DB for Keycloak.
- **MinIO**: S3-compatible storage for Proxmox backups.

---

## Features
- Monitor Proxmox and services like RabbitMQ or MinIO with Prometheus and Grafana.
- Proxmox backups directly stored in MinIO.
- Automated email notifications for Proxmox backup statuses.

---

## Project Setup Using Docker Hub

Required services are pulled directly from Docker Hub (pve exporter that exposes Proxmox metrics to Prometheus is installed on Proxmox host, but it can also be deployed with docker).

### Docker Compose Services
1. **Prometheus**: `prom/prometheus:latest`
2. **Grafana**: `grafana/grafana:latest`
3. **RabbitMQ**: `rabbitmq:3-management`
4. **Node-RED**: `nodered/node-red:latest`
5. **MinIO**: `minio/minio`
6. **Keycloak**: `quay.io/keycloak/keycloak:latest`
7. **PostgreSQL**: `postgres:latest`

---

## How to Run

### Step 1: Clone the Repository
```bash
git clone https://github.com/KostasKatsariotis/dc-monitoring-with-docker.git
cd dc-monitoring-with-docker
```

---

### Step 2: Create Directories for Persistent Storage and set ownership and permissions for Grafana
```bash
mkdir -p data/prometheus data/grafana data/rabbitmq data/minio data/postgres
sudo chown -R 472:472 ./data/grafana
sudo chmod -R 755 ./data/grafana
```

---

### Step 3: Modify Files 

Customize files `dc-monitoring-with-docker/config/prometheus/prometheus.yml` and `dc-monitoring-with-docker/config/grafana/provisioning/datasources/datasources.yml` with IPs of server running Docker and Proxmox host(s), and the `.env` file with default credentials.

---

### Step 4: Start the Services
```bash
docker-compose up -d
```

This will start all services, including RabbitMQ, MinIO, Prometheus, Grafana, Node-RED, PostgreSQL, and Keycloak.

---

### Step 5: Access the Services

| Service          | URL                        | Credentials                |
|------------------|----------------------------|----------------------------|
| **Prometheus**   | `http://docker-server-ip:9090` | N/A                    |
| **Grafana**      | `http://docker-server-ip:3000` | admin/password123      |
| **RabbitMQ**     | `http://docker-server-ip:15672` | admin/password123      |
| **MinIO**        | `http://docker-server-ip:9000` | admin/password123      |
| **Node-RED**     | `http://docker-server-ip:1880` | N/A                    |
| **Keycloak**     | `http://docker-server-ip:8080` | admin/password123      |
| **PostgreSQL**   | `http://docker-server-ip:5432` | admin/password123      |

## Pre-deployed Grafana Dashboards
- Proxmox
- minio
- RabbitMQ

## Environment Variables

| Service    | Variable                      | Description         |
|------------|-------------------------------|---------------------|
| RabbitMQ   | `RABBITMQ_USER`               | Default username    |
| RabbitMQ   | `RABBITMQ_PASS`               | Default password    |
| MinIO      | `MINIO_USER`                  |                     |
| MinIO      | `MINIO_PASS`                  |                     |
| Keycloak   | `KEYCLOAK_ADMIN`              |                     |
| Keycloak   | `KEYCLOAK_ADMIN_PASS`         |                     |
| Grafana    | `GRAFANA_USER`                |                     |
| Grafana    | `GRAFANA_PASS`                |                     |
| PostgreSQL | `POSTGRES_USER`               |                     |
| PostgreSQL | `POSTGRES_PASSWORD`           |                     |

---

### Step 6: Configure Backup Notification System (Proxmox, RabbitMQ, Node-Red)

This section describes how to set up Proxmox to send backup notifications via RabbitMQ, process them in Node-Red, and send email alerts.

### **MinIO - Proxmox Configuration**
1. Create a MinIO bucket for storing Proxmox backups.
2. Create a MinIO user with access to the bucket.
3. Go to Access keys, create a new Access key and take note of the ID and password
4. Go to your Proxmox PVE server and open the Shell console
5. Create a variable with the Access Key you've just noted down (replace ACCESS_KEY_ID and SECRET_ACCESS_KEY with the ones created before): `echo ACCESS_KEY_ID:SECRET_ACCESS_KEY > /etc/passwd-s3fs`
6. Change permissions: `chmod 600 /etc/passwd-s3fs`
7. Install `s3fs` (`apt install -y s3fs`) 
8. Create the folder where you want to mount the s3 bucket: `mkdir /mnt/minio-backups`
9. Enable user_allow_other option by removing the trailing # in the Fuse config file: `nano /etc/fuse.conf`
10. Mount the bucket: s3fs BUCKET_NAME /mnt/minio -o passwd_file=/root/.passwd-s3fs -o allow_other -o url=http://MINIO_SERVER:9000 -o use_path_request_style -o curldbg
11. Put an entry into fstab to mount the folder at startup: `s3fs#proxmox-backups /mnt/minio-s3-backups fuse _netdev,passwd_file=/etc/passwd-s3fs,allow_other,url=http://192.168.20.131:9000,use_path_request_style,nonempty 0 0`
12. On Proxmox UI go to **Datacenter > Storage > Add > Directory** and configure the storage as follows:
   - **ID**: `minio-backups`
   - **Directory**: `/mnt/minio-backups`
   - **Content**: `VZDump backup file`
13. Go to **Datacenter > Backup > Add** and configure the backup job:

### **Backup Hook Script to Send Messages to RabbitMQ**
1. Create a Proxmox backup hook script at `/var/lib/pve-manager/hooks/backup-rabbitmq.sh`:

```bash
#!/bin/bash

PHASE=$1  # e.g., job-end, backup-end, log-end
VMID=$2
MODE=$3
STARTTIME=$4

RABBITMQ_HOST="localhost"
RABBITMQ_USER="backup_user"
RABBITMQ_PASS="password123"
EXCHANGE="proxmox.backup.notifications"
ROUTING_KEY="backup.status"

PAYLOAD="{"phase":"$PHASE", "vmid":"$VMID", "mode":"$MODE", "start_time":"$STARTTIME", "status":"completed"}"

curl -u "$RABBITMQ_USER:$RABBITMQ_PASS" -X POST      -H "Content-Type: application/json"      -d "{"properties":{}, "routing_key":"$ROUTING_KEY", "payload":"$PAYLOAD", "payload_encoding":"string"}"      "http://$RABBITMQ_HOST:15672/api/exchanges/%2f/$EXCHANGE/publish"
```

2. Make it executable:
```bash
chmod +x /var/lib/pve-manager/hooks/backup-rabbitmq.sh
```

---

## 2. Configure RabbitMQ

1. **Create RabbitMQ User & Queue**
```bash
docker exec -it rabbitmq rabbitmqctl add_user backup_user password123
docker exec -it rabbitmq rabbitmqctl set_permissions -p / backup_user ".*" ".*" ".*"
docker exec -it rabbitmq rabbitmqctl add_queue proxmox.backup.notifications
docker exec -it rabbitmq rabbitmqctl bind_queue proxmox.backup.notifications proxmox.backup.notifications "backup.status"
```

---

## 3. Configure Node-Red

### **Flow Overview**
1. **AMQP In Node** → **Function Node** → **Switch Node** → **Change Nodes** → **Email Node**

### **Node Configurations**
- **AMQP In Node**:
  - Queue: `proxmox.backup.notifications`
  - Host: `amqp://localhost`

- **Function Node (Filter Phases)**:
```javascript
if (msg.payload.phase === "job-end") {
    return msg;
}
return null;
```

- **Switch Node (Check Status)**:
  - `msg.payload.status == "started"` → Output 1
  - `msg.payload.status == "completed"` → Output 2
  - `msg.payload.status == "failed"` → Output 3

- **Change Nodes**: Format `msg.topic` and `msg.payload` for email.

- **Email Node**:
  - SMTP Server: `localhost`
  - Subject: `msg.topic`
  - Body: `msg.payload`

---

# Troubleshooting

1. **Services Not Starting**:
   - Run `docker-compose logs <service-name>` to debug issues
2. **Grafana Dashboards not loading mitrics**
   - Ensure Prometheus is scraping metrics.
3. **Proxmox Not Storing Backups**:
   - Ensure MinIO credentials and bucket configuration are correct.
4. **Email Notifications Failing**:
- Use **Debug nodes** to inspect message flow.
- Verify SMTP credentials and ensure the mail server allows access.
- If multiple emails are sent, ensure the **Function node** filters only `job-end`.

---

## License
- This project is licensed under the MIT License.