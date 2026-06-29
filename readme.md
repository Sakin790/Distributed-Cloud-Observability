# Distributed Cloud Observability Pipeline

A highly scalable, infrastructure-as-code (IaC) driven distributed observability pipeline. This project provisions multi-node Linux infrastructure using Terraform and establishes an automated telemetry collection system utilizing OpenTelemetry (OTel), Prometheus (TSDB), and Grafana.

The architecture captures distributed system metrics (CPU, Memory, Network, Disk) without manual intervention, delivering a dynamic, production-ready monitoring experience.


## 🚀 Key Features

    Infrastructure as Code: 100% automated multi-node Linux instance provisioning using Terraform.

    Zero-Touch Telemetry (GitOps/Cloud-init): OTel Agents automatically deploy and register as systemd daemons upon instance launch.

    Centralized Telemetry Gateway: A dedicated OpenTelemetry Collector Gateway that ingests, processes (batching/filtering), and exports metrics.

    Dynamic Target Discovery: Real-time host discovery on Grafana dashboards as infrastructure scales up or down via Terraform.

    Proactive Alerting: Configured automated alert thresholds for infrastructure anomalies (e.g., CPU spikes, memory exhaustion) routed to modern alerting channels.

## 🏗️ System Architecture
Plaintext

[ Linux Host 01 ] ──(OTel Agent)──┐
[ Linux Host 02 ] ──(OTel Agent)──┼──► [ OTel Central Gateway ] ──► [ Prometheus (TSDB) ] ──► [ Grafana Dashboard ]
[ Linux Host 03 ] ──(OTel Agent)──┘

    Collection Layer: Light-weight otel-collector daemons scrape native host metrics via the hostmetrics receiver.

    Gateway Layer: The Central OTel Gateway receives distributed telemetry data via high-performance OTLP (gRPC/HTTP), batches the data to optimize memory, and transforms it.

    Storage Layer (TSDB): Prometheus scrapes or receives metrics from the gateway, storing time-series data locally with custom retention profiles.

    Visualization Layer: Grafana queries Prometheus to map real-time performance analytics on dynamic dashboards.

## 🛠️ Tech Stack & Tools

    Infrastructure: Terraform (AWS / Local Providers like Multipass or Docker)

    OS Target: Linux (Ubuntu / Debian / Arch-based hosts)

    Instrumentation: OpenTelemetry (OTel Collector & Agents)

    Storage Engine: Prometheus (Time-Series Database)

    Visualization: Grafana (Data-driven Dashboards)

## 📂 Repository Structure
Plaintext

├── terraform/
│   ├── main.tf            # Core infrastructure logic
│   ├── variables.tf       # Configurable scaling variables (e.g., node count)
│   └── outputs.tf         # Dynamic IP and endpoint tracking
├── telemetry/
│   ├── agent-config.yaml  # OTel Agent configurations for remote nodes
│   └── gateway-config.yaml# Central OTel Collector pipeline logic
├── monitoring/
│   ├── prometheus.yml     # TSDB scrape intervals and storage profiles
│   └── grafana-dashboard.json # Pre-configured JSON dashboard for host metrics
└── README.md