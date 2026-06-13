# 🛒 RetailPulse — End-to-End Retail Analytics Pipeline

![Python](https://img.shields.io/badge/Python-3.11-blue?logo=python)
![Databricks](https://img.shields.io/badge/Databricks-Free%20Edition-red?logo=databricks)
![Delta Lake](https://img.shields.io/badge/Delta%20Lake-Medallion%20Architecture-blue)
![dbt](https://img.shields.io/badge/dbt-1.12.0-orange?logo=dbt)
![Terraform](https://img.shields.io/badge/Terraform-IaC-purple?logo=terraform)
![AWS S3](https://img.shields.io/badge/AWS-S3-yellow?logo=amazons3)
![Power BI](https://img.shields.io/badge/Power%20BI-Dashboard-gold?logo=powerbi)

> A complete, production-realistic data engineering portfolio project built on the Databricks Lakehouse ecosystem.

---

## 📖 Overview

**RetailPulse** is a full end-to-end data pipeline that ingests raw retail transaction data (orders, customers, products) from **Amazon S3**, processes it through a **Bronze → Silver → Gold medallion architecture** using **Delta Lake** on **Databricks**, transforms it with **dbt**, governs it via **Unity Catalog**, orchestrates it with **Databricks Workflows**, and visualises business KPIs in **Power BI**.

The project is built ticket-by-ticket on a Jira Kanban board, mirroring real team workflows.

---

## 📊 Dashboard

![RetailPulse Sales Dashboard](dashboards/retailpulse_dashboard_screenshot.png)

Four Gold-layer visuals built in Power BI:
- **Daily Revenue Trend** — line chart from `gold.daily_sales`
- **Top 10 Customers by Revenue** — bar chart from `gold.top_customers`
- **Revenue by Product Category** — donut chart from `gold.revenue_by_category`
- **Orders by Country** — bubble map from `gold.orders_by_country`

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        DATA SOURCES                         │
│         Synthetic CSVs: orders, customers, products         │
│                   (500K / 50K / 5K rows)                    │
└──────────────────────────────┬──────────────────────────────┘
                               │  scripts/generate_data.py
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                         AMAZON S3                           │
│             s3://retailpulse-raw-data-landing/              │
│                  Provisioned via Terraform                  │
└──────────────────────────────┬──────────────────────────────┘
                               │  Auto Loader (cloudFiles)
                               ▼
┌─────────────────────────────────────────────────────────────┐
│              DELTA LAKE — BRONZE (Unity Catalog)            │
│     Raw, append-only ingestion. Schema inferred.            │
│  workspace.retailpulse_bronze.orders / customers / products │
└──────────────────────────────┬──────────────────────────────┘
                               │  PySpark (Silver notebook)
                               ▼
┌─────────────────────────────────────────────────────────────┐
│              DELTA LAKE — SILVER (Unity Catalog)            │
│   Cleaned, deduped, type-cast, _rescued_data dropped.       │
│  workspace.retailpulse_silver.orders / customers / products │
└──────────────────────────────┬──────────────────────────────┘
                               │  dbt-databricks 1.12.0
                               ▼
┌─────────────────────────────────────────────────────────────┐
│              DELTA LAKE — GOLD (Unity Catalog)              │
│        Business aggregates ready for reporting.             │
│   workspace.retailpulse_gold.daily_sales / top_customers /  │
│              revenue_by_category / orders_by_country        │
└────────────────┬────────────────────────────┬───────────────┘
                 │                            │
                 ▼                            ▼
   ┌─────────────────────┐        ┌───────────────────────┐
   │   UNITY CATALOG     │        │       POWER BI        │
   │  Lineage, access    │        │   Sales Dashboard     │
   │  control, PII tags  │        │   (CSV import mode)   │
   └─────────────────────┘        └───────────────────────┘

        Orchestration: Databricks Workflows (3-task DAG)
        IaC: Terraform (S3) | Dev: VS Code + Windows
```

---

## 🧰 Tech Stack

| Layer | Tool |
|---|---|
| Infrastructure as Code | Terraform (AMD64, v1.3+) |
| Cloud Storage | Amazon S3 |
| Ingestion | Databricks Auto Loader (`cloudFiles`) |
| Lakehouse Format | Delta Lake |
| Processing | Databricks Free Edition (PySpark) |
| Transformation & Testing | dbt-databricks 1.12.0, dbt_utils |
| Data Governance | Unity Catalog (lineage, access control, table tagging) |
| Orchestration | Databricks Workflows (GitHub integration) |
| Visualization | Power BI Desktop |
| Version Control | GitHub |
| Project Management | Jira (KAN board) |

---

## 📁 Repository Structure

```
retailpulse-end-to-end-pipeline/
│
├── terraform/                        # S3 bucket provisioning
│   ├── main.tf
│   ├── variables.tf
│   ├── providers.tf
│   └── versions.tf
│
├── scripts/
│   └── generate_data.py              # Generates 500K orders, 50K customers, 5K products
│
├── notebooks/
│   ├── pipeline/
│   │   └── retailpulse_01_bronze_ingestion   # Auto Loader → Bronze Delta tables
│   └── explorations/                         # Silver/Gold Spark notebooks (reference)
│
├── dbt_retailpulse/                  # dbt project (primary transformation layer)
│   ├── models/
│   │   ├── staging/                  # Silver refs via source() macro
│   │   └── marts/                    # Gold aggregation models via ref()
│   ├── tests/                        # 21 dbt tests (unique, not_null, accepted_range)
│   ├── dbt_project.yml
│   └── profiles.yml
│
├── data/
│   └── sample/                       # Sample CSVs for local testing
│
├── dashboards/
│   ├── retailpulse_dashboard.pbix    # Power BI dashboard file
│   └── retailpulse_dashboard_screenshot.png
│
├── airflow/dags/                     # Reference Airflow DAG (not used; see note below)
├── requirements.txt
├── .gitignore
└── README.md
```

---

## 🚀 Getting Started

### Prerequisites

- AWS account with S3 access
- Databricks account (Free Edition works — see note below)
- Terraform `>= 1.3` — [download Windows AMD64](https://developer.hashicorp.com/terraform/install)
- AWS CLI configured (`aws configure`)
- Python 3.11 and pip
- Power BI Desktop (Windows)
- Git

---

### Step 1 — Clone and install

```bash
git clone https://github.com/IHTHERTECH/retailpulse-end-to-end-pipeline.git
cd retailpulse-end-to-end-pipeline
pip install -r requirements.txt
```

---

### Step 2 — Provision S3 with Terraform

```bash
cd terraform/
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

This provisions the S3 bucket `retailpulse-raw-data-landing`.

> **Infrastructure note:** In a production environment, Terraform would also provision the Databricks workspace, Unity Catalog metastore, and IAM roles. For this project, Databricks Free Edition is provisioned manually and schemas are created via SQL. This is the pragmatic approach for a personal/learning project.

---

### Step 3 — Create Unity Catalog schemas

In your Databricks SQL Editor:

```sql
CREATE SCHEMA IF NOT EXISTS workspace.retailpulse_bronze;
CREATE SCHEMA IF NOT EXISTS workspace.retailpulse_silver;
CREATE SCHEMA IF NOT EXISTS workspace.retailpulse_gold;
CREATE SCHEMA IF NOT EXISTS workspace.retailpulse_staging;
```

---

### Step 4 — Generate and upload data

```bash
python scripts/generate_data.py

aws s3 cp data/sample/ s3://retailpulse-raw-data-landing/raw/retail/ --recursive
```

---

### Step 5 — Run Bronze ingestion

Import `notebooks/pipeline/retailpulse_01_bronze_ingestion` into your Databricks workspace and run it. This uses **Auto Loader** to incrementally read CSV files from S3 into Bronze Delta tables, with checkpoints stored in Unity Catalog Volumes.

```python
df = (spark.readStream
    .format("cloudFiles")
    .option("cloudFiles.format", "csv")
    .option("cloudFiles.schemaLocation", schema_path)
    .load(raw_path))

df.writeStream
    .format("delta")
    .option("checkpointLocation", checkpoint_path)
    .toTable("workspace.retailpulse_bronze.orders")
```

---

### Step 6 — Run dbt transformations

```bash
# Activate virtual environment
source dbt_venv/Scripts/activate  # Windows

cd dbt_retailpulse/
dbt debug        # verify connection
dbt run          # build staging + mart models
dbt test         # run 21 data quality tests
dbt docs generate && dbt docs serve   # explore lineage graph
```

The dbt project targets a **Databricks SQL Warehouse** (`/sql/1.0/warehouses/d253a655584a182c`) and writes models to `workspace.retailpulse_staging` (staging) and `workspace.retailpulse_gold` (marts).

---

### Step 7 — Orchestrate with Databricks Workflows

The `retailpulse_pipeline` workflow in Databricks runs the full pipeline:

| Task | Type | What it does |
|---|---|---|
| `ingest_bronze` | Notebook | Auto Loader → Bronze Delta tables |
| `run_dbt_models` | dbt (GitHub) | `dbt deps` + `dbt run` → Staging + Gold |
| `run_dbt_tests` | dbt (GitHub) | `dbt test` → 21 data quality checks |

Tasks 2 and 3 pull directly from the `main` branch of this repo, so the workflow always runs the latest committed code.

> **Why not Airflow?** Airflow requires the `fcntl` module, which is unavailable on Windows. Databricks Workflows is the native, zero-infra alternative. A reference Airflow DAG is available in `airflow/dags/` for non-Windows environments.

---

### Step 8 — Unity Catalog governance

Navigate to **Catalog** in your Databricks workspace to explore:
- **Lineage**: trace `gold.daily_sales` back to `bronze.orders`
- **Access control**: table-level GRANT/REVOKE
- **Tags**: tables tagged `pii` (customers), `financial` (orders), `public` (products)

---

### Step 9 — Power BI dashboard

> **Note for Databricks Free Edition users:** The native Power BI → Databricks connector does not support Free Edition. Export Gold tables as CSV from a Databricks notebook and load them via **Get Data → Text/CSV** in Power BI Desktop.

```python
# Export Gold tables from Databricks notebook
tables = ["daily_sales", "top_customers", "revenue_by_category", "orders_by_country"]
for table in tables:
    df = spark.table(f"workspace.retailpulse_gold.{table}")
    df.toPandas().to_csv(f"/Volumes/workspace/retailpulse_bronze/checkpoints/{table}.csv", index=False)
```

Then open `dashboards/retailpulse_dashboard.pbix` or build fresh from the 4 CSV files.

---

## 🧪 dbt Tests (21 total)

Tests are defined across staging and mart models in `schema.yml` files. Examples:

```yaml
- name: stg_orders
  columns:
    - name: order_id
      tests:
        - unique
        - not_null
    - name: amount
      tests:
        - not_null
        - dbt_utils.accepted_range:
            arguments:
              min_value: 0
```

Run `dbt test` to validate all 21 tests. The Databricks Workflow also runs tests as a dedicated task after every model run.

---

## 📊 Gold Layer — Data Models

| Model | Description | Power BI Visual |
|---|---|---|
| `gold.daily_sales` | Revenue aggregated by order date | Daily Revenue Trend (line) |
| `gold.top_customers` | Lifetime value per customer | Top 10 Customers (bar) |
| `gold.revenue_by_category` | Revenue by product category | Category breakdown (donut) |
| `gold.orders_by_country` | Order count by customer country | Orders by Country (map) |

---

## 💡 Stretch Goals

- **Streaming layer** — Structured Streaming for real-time order ingestion
- **dbt contracts** — enforce column types at the model level
- **Great Expectations** — richer data profiling beyond dbt tests
- **GitHub Actions CI** — run `dbt test` on pull requests automatically
- **Cost monitoring** — track Databricks compute cost per pipeline run

---

## 📄 License

GPL-3.0 — free to use, modify, and share for learning purposes.

---

## 🙏 Acknowledgements

- [Databricks Documentation](https://docs.databricks.com)
- [dbt Documentation](https://docs.getdbt.com)
- [Delta Lake Documentation](https://docs.delta.io)
- [The Data Engineering Cookbook](https://github.com/andkret/Cookbook) by Andreas Kretz

---

*Built as a hands-on portfolio project for data engineering. Each component maps to a Jira ticket (KAN-6 through KAN-16) in the [RetailPulse Kanban board](https://ihthertech.atlassian.net/jira/software/projects/KAN/list).*