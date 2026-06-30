# AWS Centralized Monitoring Project

## What this project does
This project automatically sets up a centralized monitoring and logging system in AWS using Terraform. It provisions 6 EC2 instances:
* **Server 6 (Parent Node):** Acts as the central monitoring server running OpenTelemetry Collector, Prometheus, and Grafana.
* **Servers 1-5 (Child Nodes):** Act as application servers running OpenTelemetry Collector, which automatically collects logs and metrics and pushes them to Server 6.

---

## How it works
1. **Networking:** Terraform creates a secure VPC and Subnet. It opens specific ports (22, 3000, 9090) on Server 6 only for your IP address. Internal ports (4317, 4318) are kept open strictly within the VPC network for data transfer between servers.
2. **Provisioning:** Server 6 is created first and runs a setup script (`server_6_monitoring.sh`) to install the monitoring tools.
3. **Dynamic Configuration:** Servers 1-5 are created next. Terraform automatically detects Server 6's private IP and injects it into a template (`otel-config.yaml.tftpl`), configuring the child nodes to send data directly to the correct parent server.

---

## How to use it

### Prerequisites
* Ensure Terraform and AWS CLI are installed on your machine.
* Configure your AWS credentials (`aws configure`).

### Steps to Run
1. Initialize the Terraform project:
   ```bash
   terraform init


Review the infrastructure plan:
    Bash

    terraform plan

    Create the AWS resources:
    Bash

    terraform apply

    (Type yes when prompted and wait a few minutes for the setup to complete).

Accessing Dashboards

After the deployment finishes, use the outputs to get Server 6's public IP:

    Grafana Dashboard: http://<Server-6-Public-IP>:3000 (Default login: admin / admin)

    Prometheus UI: http://<Server-6-Public-IP>:9090

Cleanup (To avoid AWS charges)

When you are done testing, destroy all created resources:
Bash

terraform destroy