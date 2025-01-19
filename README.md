
# Dockerized Monitoring and Notification System

## Overview
This project is a complete containerized solution for monitoring, alerting, and automated notifications for Proxmox backups stored in MinIO. It integrates:

- **Prometheus**: Monitoring and metrics collection.
- **Grafana**: Visualization and alerting.
- **RabbitMQ**: Message queue for notifications.
- **Node-RED**: Workflow automation for email and Slack notifications.
- **Keycloak**: Identity and access management.
- **MinIO**: S3-compatible storage for Proxmox backups.

---

## Features
- Monitor services like RabbitMQ, MinIO, and Node-RED with Prometheus and Grafana.
- Proxmox backups directly stored in MinIO.
- Automated email and Slack notifications for Proxmox backup statuses.
- Secure communication via TLS (optional).

---

## Project Setup Using Docker Hub

All required services are pulled directly from Docker Hub.

### Docker Compose Services
1. **Prometheus**: `prom/prometheus:latest`
2. **Grafana**: `grafana/grafana:latest`
3. **RabbitMQ**: `rabbitmq:3-management`
4. **Node-RED**: `nodered/node-red:latest`
5. **MinIO**: `minio/minio`
6. **Keycloak**: `quay.io/keycloak/keycloak:latest`

---

## How to Run

### Step 1: Clone or Download the Repository
```bash
mkdir dockerized-monitoring-system
cd dockerized-monitoring-system
```

Copy the provided `docker-compose.yml` and configuration files into the directory.

---

### Step 2: Start the Services
```bash
docker-compose up -d
```

This will start all services, including RabbitMQ, MinIO, Prometheus, Grafana, Node-RED, and Keycloak.

---

### Step 3: Access the Services

| Service         | URL                        | Credentials                |
|------------------|----------------------------|----------------------------|
| **Prometheus**   | [http://localhost:9090](http://localhost:9090) | N/A                        |
| **Grafana**      | [http://localhost:3000](http://localhost:3000) | admin/admin (default)      |
| **RabbitMQ**     | [http://localhost:15672](http://localhost:15672) | guest/guest               |
| **MinIO**        | [http://localhost:9000](http://localhost:9000) | admin/password123         |
| **Node-RED**     | [http://localhost:1880](http://localhost:1880) | N/A                        |
| **Keycloak**     | [http://localhost:8080](http://localhost:8080) | admin/admin               |

---

## Usage

### 1. Configure Proxmox with MinIO
1. Go to Proxmox **Datacenter > Storage > Add > S3**.
2. Configure the storage as follows:
   - **ID**: `minio-backups`
   - **Endpoint**: `http://minio:9000`
   - **Access Key**: `admin`
   - **Secret Key**: `password123`
   - **Bucket Name**: `proxmox-backups`.

### 2. Set Up Notifications
- The Proxmox hook script is configured to send RabbitMQ messages for backup events. Node-RED processes these messages and:
  - Sends email notifications via SMTP.
  - Sends Slack notifications using a webhook.

---

## Monitoring Dashboards

### Grafana Dashboards
1. Import dashboards for MinIO, RabbitMQ, and Node-RED from the Grafana Dashboard Repository:
   - **MinIO Dashboard**: [ID 13640](https://grafana.com/grafana/dashboards/13640).
   - **RabbitMQ Overview**: [ID 10991](https://grafana.com/grafana/dashboards/10991).

### Prometheus Targets
Ensure Prometheus is scraping metrics for RabbitMQ (`:15672`), MinIO (`:9000`), and Node-RED (`:1880`).

---

## Environment Variables

| Service    | Variable                      | Description                     |
|------------|-------------------------------|---------------------------------|
| RabbitMQ   | `RABBITMQ_DEFAULT_USER`       | Default username               |
| RabbitMQ   | `RABBITMQ_DEFAULT_PASS`       | Default password               |
| MinIO      | `MINIO_ROOT_USER`             | Admin access key               |
| MinIO      | `MINIO_ROOT_PASSWORD`         | Admin secret key               |
| Keycloak   | `KEYCLOAK_ADMIN`              | Admin username                 |
| Keycloak   | `KEYCLOAK_ADMIN_PASSWORD`     | Admin password                 |

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

3. **Persistent Volumes**:
   - Use Docker volumes for RabbitMQ, MinIO, and Grafana to retain data after container restarts.

---

## License

This project is licensed under the MIT License.
