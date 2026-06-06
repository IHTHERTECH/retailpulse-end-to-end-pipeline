# 🛒 RetailPulse — End-to-End Retail Analytics Pipeline

> A beginner-friendly, production-realistic data engineering project built on the Databricks Lakehouse ecosystem.

---

## 📖 Project Overview

**RetailPulse** is a complete, end-to-end data pipeline that ingests raw retail transaction data (orders, products, customers) from Amazon S3, processes and transforms it through a **Bronze → Silver → Gold** medallion architecture using **Delta Lake** on **Databricks**, transforms it with **dbt**, governs it via **Unity Catalog**, and finally visualizes it in **Power BI**.

This project is designed for **first-time data engineers** who want hands-on experience with a modern, production-grade lakehouse stack — without the noise of unnecessary tools.

---

## 🎯 What You Will Learn

By completing this project, you will have hands-on experience with:

* Ingesting raw files incrementally from S3 using **Databricks Auto Loader**
* Building a **Medallion Architecture** (Bronze / Silver / Gold) with **Delta Lake**
* Writing scalable data transformations with **Apache Spark** on **Databricks**
* Modeling and testing data transformations with **dbt**
* Governing data assets (lineage, access control, tagging) using **Unity Catalog**
* Orchestrating pipeline runs with **Apache Airflow** (or **Databricks Workflows**)
* Provisioning cloud infrastructure as code with **Terraform**
* Automating deployment with **GitHub Actions**
* Visualizing business KPIs in **Power BI**

---

## 🗂️ Dataset

We use a **synthetic retail dataset** that simulates a small e-commerce business. You can generate it locally using the provided script, or download the CSV files from the `/data/sample/` folder in this repo.

| File | Description | Rows (sample) |
| --- | --- | --- |
| `orders.csv` | Order transactions (order_id, customer\_id, product\_id, amount, date) | ~500K |
| `customers.csv` | Customer profiles (customer\_id, name, city, country, signup\_date) | ~50K |
| `products.csv` | Product catalog (product\_id, name, category, price, stock\_qty) | ~5K |

Upload these files to your S3 bucket under the path: `s3://<your-bucket>/raw/retail/`

---

## 🏗️ Architecture

```
┌────────────────────────────────────────────────────────────────────┐
│                         DATA SOURCES                               │
│              CSV Files (Orders, Customers, Products)               │
└──────────────────────────────┬─────────────────────────────────────┘
                            Upload
                               │  
                               ▼
 ┌─────────────────────────────────────────────────────────────────┐
 │                          AMAZON S3                              │
 │                   s3://<bucket>/raw/retail/                     │
 └──────────────────────────────┬──────────────────────────────────┘
                                │
                Auto Loader (incremental ingestion)
                                │
                                ▼
 ┌─────────────────────────────────────────────────────────────────┐
 │                    DELTA LAKE — BRONZE                          │
 │         Raw, unmodified data. Append-only. Schema inferred.     │
 │   Tables: bronze.orders | bronze.customers | bronze.products    │
 └──────────────────────────────┬──────────────────────────────────┘
                                │
                       Spark Transformations
                                │
                                ▼
 ┌─────────────────────────────────────────────────────────────────┐
 │                    DELTA LAKE — SILVER                          │
 │    Cleaned, deduplicated, type-cast, joined data.               │
 │   Tables: silver.orders | silver.customers | silver.products    │
 └──────────────────────────────┬──────────────────────────────────┘
                                │
                            dbt Models
                                │
                                ▼
 ┌─────────────────────────────────────────────────────────────────┐
 │                    DELTA LAKE — GOLD                            │
 │    Business-level aggregates ready for reporting.               │
 │   Tables: gold.daily_sales | gold.top_customers | gold.revenue  │
 └──────────────────────────────┬──────────────────────────────────┘
                                │
                  ┌─────────────┴──────────────┐
                  ▼                            ▼
      ┌─────────────────────┐       ┌────────────────────────┐
      │   UNITY CATALOG     │       │      POWER BI          │
      │  Governance,        │       │  Sales Dashboard       │
      │  Lineage, Access    │       │  Customer Analytics    │
      └─────────────────────┘       └────────────────────────┘

         Orchestration: Airflow / Databricks Workflows
         IaC: Terraform  |  CI/CD: GitHub Actions
```

---

## 🧰 Tech Stack

| Layer | Tool |
| --- | --- |
| Cloud Storage | Amazon S3 |
| Ingestion | Databricks Auto Loader |
| Lakehouse Format | Delta Lake |
| Big Data Processing | Databricks (Apache Spark) |
| Transformation | dbt (Data Build Tool) |
| Warehousing / SQL | Databricks SQL |
| Governance | Unity Catalog |
| Orchestration | Apache Airflow (or Databricks Workflows) |
| Infrastructure as Code | Terraform |
| CI/CD | GitHub Actions |
| Visualization | Power BI |

---

## 📁 Repository Structure

```
retailpulse/
│
├── terraform/                    # Infrastructure provisioning
│   ├── versions.tf               # Terraform and provider version constraints
│   ├── providers.tf              # AWS provider configuration
│   ├── variables.tf              # Input variable declarations
│   ├── terraform.tfvars          # Variable values (excluded from version control)
│   └── main.tf                   # S3 bucket and resource definitions
│
├── notebooks/                    # Databricks notebooks
│   ├── explorations/             
│   │   ├── retailpulse_01_delta_lake_exploration     
│   └── pipeline/                   
│       ├── retailpulse_01_bronze_ingestion       # Auto Loader → Bronze Delta tables
│       ├── retailpulse_02_silver_cleaning.py     # Bronze → Silver transformations (Spark)
│       └── retailpulse_03_gold_aggregation.py    # Silver → Gold aggregations (Spark)
│
├── dbt_retailpulse/              # dbt project for Gold layer modeling
│   ├── models/
│   │   ├── staging/              # Lightweight Silver layer refs
│   │   ├── intermediate/         # Business logic joins
│   │   └── marts/                # Final Gold tables for reporting
│   ├── tests/                    # dbt data quality tests
│   ├── dbt_project.yml
│   └── profiles.yml
│
├── airflow/                      # Airflow DAGs for orchestration
│   └── dags/
│       └── retailpulse_dag.py    # Full pipeline DAG
│
├── data/
│   └── sample/                   # Sample CSV files for local testing
│       ├── orders.csv
│       ├── customers.csv
│       └── products.csv
│
├── scripts/
│   └── generate_data.py          # Script to generate synthetic dataset
│
├── .github/
│   └── workflows/
│       ├── ci.yml                # Run dbt tests + linting on pull requests
│       └── deploy.yml            # Deploy notebooks + dbt models on merge to main
│
├── powerbi/
│   └── RetailPulse.pbix          # Power BI dashboard file
│
├── .gitignore
├── requirements.txt
└── README.md
```

---

## 🚀 Getting Started

### Prerequisites

Before you begin, make sure you have:

* An **AWS account** with S3 access
* A **Databricks account** (Free Edition works for learning; see infrastructure note below)
* **Terraform** installed locally (`>= 1.3`) — download the **Windows AMD64** binary from [developer.hashicorp.com/terraform/install](https://developer.hashicorp.com/terraform/install)
* **AWS CLI** installed and configured (`aws configure`) — download from [aws.amazon.com/cli](https://aws.amazon.com/cli)
* **Python 3.9+** and **pip** installed
* **dbt-databricks** adapter installed (`pip install dbt-databricks`)
* **Apache Airflow** installed locally or via Docker (`pip install apache-airflow`)
* **Power BI Desktop** installed (Windows only; use Power BI web on Mac)
* **Git** and a **GitHub account**

---

### Step 1 — Clone the Repository

```bash
git clone https://github.com/<your-username>/retailpulse.git
cd retailpulse
pip install -r requirements.txt
```

---

### Step 2 — Provision Infrastructure with Terraform

```bash
cd terraform/
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

This provisions:

* ✅ An **S3 bucket** (`retailpulse-raw-data-landing`) for the raw data landing zone

> **⚠️ Infrastructure Note — Databricks & Unity Catalog**
>
> In a **production environment**, this Terraform configuration would also provision:
> - A **Databricks workspace** on AWS (via the `databricks/databricks` Terraform provider)
> - A **Unity Catalog metastore** for data governance, lineage, and access control
> - Three managed **schemas**: `bronze`, `silver`, `gold`
>
> This requires AWS networking resources (VPC, subnets, NAT Gateway, IAM cross-account roles)
> and incurs ongoing AWS costs even when idle.
>
> For this project, **Databricks Free Edition** is used instead:
> - The workspace is provisioned manually via [databricks.com](https://databricks.com)
> - The `bronze`, `silver`, and `gold` schemas are created directly via SQL (see below)
> - Unity Catalog is not available in Free Edition; governance features are documented only
>
> This is a common and accepted approach for personal/learning projects. The Terraform
> provider configuration for a full production setup would include the `databricks` provider
> in `versions.tf` and workspace + metastore resource blocks in `main.tf`.

---

### Step 2b — Create Databricks Schemas (Free Edition)

Since Unity Catalog is not available in Databricks Free Edition, create the medallion schemas manually. Open the **SQL Editor** in your Databricks workspace and run:

```sql
CREATE DATABASE IF NOT EXISTS bronze;
CREATE DATABASE IF NOT EXISTS silver;
CREATE DATABASE IF NOT EXISTS gold;
```

Verify by navigating to **Catalog** in the left sidebar — all three schemas should appear.

---

### Step 3 — Upload Sample Data to S3

```bash
# Generate synthetic data
python scripts/generate_data.py

# Upload to S3 (requires AWS CLI configured)
aws s3 cp data/sample/ s3://<your-bucket>/raw/retail/ --recursive
```

---

### Step 4 — Run the Bronze Ingestion Notebook

Open **Databricks workspace** → Import `notebooks/01_bronze_ingestion.py`.

This notebook uses **Auto Loader** to read new files from S3 incrementally and write them to Delta Lake Bronze tables.

```python
# Example: Auto Loader pattern used in the notebook
df = (spark.readStream
    .format("cloudFiles")
    .option("cloudFiles.format", "csv")
    .option("cloudFiles.schemaLocation", schema_path)
    .load(raw_path))

df.writeStream
    .format("delta")
    .option("checkpointLocation", checkpoint_path)
    .toTable("bronze.orders")
```

---

### Step 5 — Run Silver and Gold Notebooks

Run the notebooks in order:

```
01_bronze_ingestion.py   →  Raw data lands in Delta
02_silver_cleaning.py    →  Clean, deduplicate, cast types
03_gold_aggregation.py   →  Aggregate for business reporting
```

---

### Step 6 — Run dbt Transformations

```bash
cd dbt_retailpulse/

# Test your connection
dbt debug

# Run all models
dbt run

# Run data quality tests
dbt test

# Generate documentation
dbt docs generate
dbt docs serve
```

> 💡 **Key learning moment:** Open `dbt docs serve` in your browser and explore the **lineage graph**. You will see how each model depends on the ones before it — this is data lineage in action.

---

### Step 7 — Set Up Pipeline Orchestration

This project uses **Databricks Workflows** for orchestration, which is the
native and recommended approach when running pipelines on Databricks.

The workflow `retailpulse_pipeline` is configured directly in the Databricks
Workflows UI with three tasks running in sequence:

| Task | Type | What it does |
| --- | --- | --- |
| `ingest_bronze` | Notebook | Runs Auto Loader to read S3 CSV files → Bronze Delta tables |
| `run_dbt_models` | dbt (GitHub) | Runs `dbt deps` + `dbt run` → builds Staging and Gold mart models |
| `run_dbt_tests` | dbt (GitHub) | Runs `dbt test` → validates all 21 data quality tests |

The `run_dbt_models` and `run_dbt_tests` tasks pull the dbt project directly
from the GitHub repository (`dbt_retailpulse/` folder, `main` branch), so the
workflow always runs the latest committed code.

**To re-create the workflow in a new workspace:**
1. Go to Databricks → **Jobs & Pipelines** → **Create job**
2. Name it `retailpulse_pipeline`
3. Add Task 1: Notebook → `retailpulse_01_bronze_ingestion`
4. Add Task 2: dbt → Source: Git provider → `dbt_retailpulse` → commands: `dbt deps`, `dbt run`
5. Add Task 3: dbt → Source: Git provider → `dbt_retailpulse` → commands: `dbt deps`, `dbt test`
6. Set dependencies: Task 2 depends on Task 1, Task 3 depends on Task 2

> **Airflow equivalent:** For non-Databricks environments (AWS MWAA, Google
> Cloud Composer, self-hosted), an equivalent Airflow DAG is provided at
> `airflow/dags/retailpulse_dag.py`. Note that Airflow does not run natively
> on Windows — use WSL2 or Docker in that case.

---

### Step 8 — Explore Unity Catalog

> **Note:** Unity Catalog is not available in Databricks Free Edition. In a paid workspace,
> navigate to **Catalog** in the left sidebar to explore data lineage, access control, and tagging.

In a full workspace, you would explore:

* **Data lineage**: See how `gold.daily_sales` traces back to `bronze.orders`
* **Access control**: Grant and revoke table-level permissions
* **Tags**: Tag tables with `pii`, `financial`, or `public` labels

---

### Step 9 — Connect Power BI

1. Open **Power BI Desktop**
2. Click **Get Data** → **Databricks**
3. Enter your **Databricks SQL warehouse** HTTP path and server hostname (found in Databricks SQL → SQL Warehouses → Connection Details)
4. Connect to the `gold` schema tables
5. Open `powerbi/RetailPulse.pbix` or build your own dashboard with these suggested visuals:
   * 📊 Daily Revenue Trend (line chart)
   * 🏆 Top 10 Customers by Spend (bar chart)
   * 🗺️ Sales by Country (map)
   * 📦 Revenue by Product Category (donut chart)

---

### Step 10 — Set Up CI/CD with GitHub Actions

Push your code to GitHub. The workflows in `.github/workflows/` will automatically:

* **On Pull Request** (`ci.yml`): Run `dbt test` to validate your models don't break
* **On merge to `main`** (`deploy.yml`): Deploy updated notebooks and dbt models to Databricks

> 💡 You will need to add these GitHub Secrets in your repo settings:
> `DATABRICKS_HOST`, `DATABRICKS_TOKEN`, `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`

---

## 📊 Gold Layer — What You're Building Toward

| Table | Description | Used In Power BI |
| --- | --- | --- |
| `gold.daily_sales` | Revenue aggregated by day | Daily Revenue Trend chart |
| `gold.top_customers` | Lifetime value per customer | Top Customers bar chart |
| `gold.revenue_by_category` | Revenue broken down by product category | Category donut chart |
| `gold.orders_by_country` | Order count and revenue by customer country | Sales map |

---

## 🧪 Data Quality Tests (dbt)

The following tests are pre-configured in the dbt project:

```yaml
# Example from schema.yml
models:
  - name: silver_orders
    columns:
      - name: order_id
        tests:
          - unique
          - not_null
      - name: amount
        tests:
          - not_null
          - dbt_utils.accepted_range:
              min_value: 0
```

Run `dbt test` after every model change. Failing tests will also block deployment via GitHub Actions.

---

## 🗺️ Learning Roadmap

Follow this order to get the most out of this project:

```
Week 1 — Foundation
  ✅ Set up Terraform, S3, Databricks workspace
  ✅ Upload sample data, run Bronze ingestion with Auto Loader
  ✅ Understand Delta Lake: ACID, time travel (try RESTORE and VERSION AS OF)

Week 2 — Transformations
  ✅ Write Silver cleaning logic in Spark (handle nulls, dedup, cast types)
  ✅ Write Gold aggregations in Spark
  ✅ Set up dbt project, convert Gold logic to dbt models
  ✅ Write dbt tests

Week 3 — Governance & Orchestration
  ✅ Explore Unity Catalog lineage, tags, and access control
  ✅ Build Airflow DAG to run the full pipeline end-to-end
  ✅ Connect Power BI to Gold tables

Week 4 — DevOps
  ✅ Set up GitHub Actions CI (dbt test on PRs)
  ✅ Set up GitHub Actions CD (deploy on merge)
  ✅ Write your project retrospective in the repo Wiki
```

---

## 💡 Stretch Goals (After You Finish)

Once you've completed the core pipeline, try these to deepen your skills:

* **Add a streaming layer**: Use Databricks Structured Streaming to simulate real-time order ingestion
* **Add data contracts**: Use dbt contracts to enforce column types and constraints at the model level
* **Add Great Expectations**: Integrate GE for richer data quality profiling beyond dbt tests
* **Automate data generation**: Schedule `generate_data.py` to drop new files every hour to simulate continuous ingestion
* **Cost monitoring**: Use Databricks' cost management UI to understand what each notebook run costs

---

## 🤝 Contributing

This is a personal learning project, but PRs are welcome! If you find a bug, have a suggestion, or want to add a new Gold model, feel free to open an issue or submit a pull request.

---

## 📄 License

GPL-3.0 License — free to use, modify, and share for learning purposes.

---

## 🙏 Acknowledgements

* [Databricks Documentation](https://docs.databricks.com)
* [dbt Documentation](https://docs.getdbt.com)
* [The Data Engineering Cookbook](https://github.com/andkret/Cookbook) by Andreas Kretz
* [Delta Lake Documentation](https://docs.delta.io)

---

*Built with 💙 as a learning project for aspiring data engineers.*