
# Dockerized Monitoring and Notification System

## Overview
This project is a complete containerized solution for Proxmox monitoring (single host or cluster). It integrates:

- **Prometheus**: Monitoring and metrics collection.
- **Grafana**: Visualization and alerting.
- **RabbitMQ**: Message queue for notifications.
- **Node-RED**: Workflow automation for email notifications.
- **Keycloak**: Identity and access management.
- **MinIO**: S3-compatible storage for Proxmox backups.

---

## Features
- Monitor Proxmox and services like RabbitMQ or MinIO with Prometheus and Grafana.
- Proxmox backups directly stored in MinIO.
- Automated email notifications for Proxmox backup statuses.
- Secure communication via TLS (optional).

---

## Project Setup Using Docker Hub

Required services are pulled directly from Docker Hub (pve exporter that exposes Proxmox metrix to Prometheus is installed on Proxmox host, but it can also be deployed with docker).

### Docker Compose Services
1. **Prometheus**: `prom/prometheus:latest`
2. **Grafana**: `grafana/grafana:latest`
3. **RabbitMQ**: `rabbitmq:3-management`
4. **Node-RED**: `nodered/node-red:latest`
5. **MinIO**: `minio/minio`
6. **Keycloak**: `quay.io/keycloak/keycloak:latest`

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
mkdir -p data/prometheus data/grafana data/rabbitmq data/minio
sudo chown -R 472:472 ./data/grafana
sudo chmod -R 755 ./data/grafana
```

---

### Step 3: Start the Services
```bash
docker-compose up -d
```

This will start all services, including RabbitMQ, MinIO, Prometheus, Grafana, Node-RED, and Keycloak.

---

### Step 4: Access the Services

| Service          | URL                        | Credentials                |
|------------------|----------------------------|----------------------------|
| **Prometheus**   | [http://docker-server-ip:9090] | N/A                    |
| **Grafana**      | [http://docker-server-ip:3000] | admin/password123      |
| **RabbitMQ**     | [http://docker-server-ip:15672] | admin/password123     |
| **MinIO**        | [http://docker-server-ip:9000] | admin/password123      |
| **Node-RED**     | [http://docker-server-ip:1880] | N/A                    |
| **Keycloak**     | [http://docker-server-ip:8080] | admin/password123      |

---

## Usage

### 1. Configure Proxmox with MinIO
1. Go to minio and create the bucket for Proxmox and a user to access it.
2. Go to Proxmox, install s3fs and add the the minio bucket: **Datacenter > Storage > Add > Directory**
3. Configure the storage as follows:
   - **ID**: `minio-backups`
   - **Endpoint**: `http://minio:9000`
   - **Access Key**: `bucket user`
   - **Secret Key**: `password`
   - **Bucket Name**: `proxmox-backups`.
4. Enter the RabbitMQ container and run the script:
   docker exec -it rabbitmq bash
   /docker-entrypoint-initdb.d/rabbitmq-setup.sh

### 2. Set Up Notifications
- The Proxmox hook script is configured to send RabbitMQ messages for backup events. Node-RED processes these messages and:
  - Sends email notifications via SMTP.

---

## Monitoring Dashboards

### Prometheus Targets
Ensure Prometheus is scraping metrics.

### Grafana Dashboards
Dashboards for MinIO, RabbitMQ, and Proxmox are impported during setup.


---

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

---

## Troubleshooting

1. **Services Not Starting**:
   - Run `docker-compose logs <service-name>` to debug issues.

2. **Email Notifications Failing**:
   - Verify SMTP credentials and ensure the mail server allows access.

3. **Proxmox Not Storing Backups**:
   - Ensure MinIO credentials and bucket configuration are correct.

4. **Grafana Alerts Not Triggering**:
   - Check the webhook URL and payload format.

---

## Extending the Project

1. **Add TLS for Secure Communication**:
   - Configure certificates for RabbitMQ, MinIO, and Keycloak.

2. **Additional Alerts**:
   - Add Grafana alerts for backup failure rates, queue lengths, and storage usage.

---

## License

This project is licensed under the MIT License.
