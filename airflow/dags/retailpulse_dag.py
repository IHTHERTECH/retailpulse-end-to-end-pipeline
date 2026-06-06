"""
retailpulse_dag.py
==================
Airflow DAG equivalent of the RetailPulse Databricks Workflow.

NOTE: This project uses Databricks Workflows for orchestration since
Airflow does not natively support Windows. This DAG is provided as
the equivalent implementation for reference and portfolio purposes.

In a production Linux/cloud environment, this DAG would be deployed
to an Airflow instance (e.g. AWS MWAA, Google Cloud Composer, or
self-hosted) and would orchestrate the same pipeline:

    ingest_bronze → run_dbt_models → run_dbt_tests

Prerequisites (production setup):
    pip install apache-airflow
    pip install apache-airflow-providers-databricks
    pip install apache-airflow-providers-dbt-cloud  (optional)

Airflow Connections required:
    - databricks_default: Databricks workspace connection
      (host, token)
"""

from datetime import datetime, timedelta

from airflow import DAG
from airflow.providers.databricks.operators.databricks import DatabricksRunNowOperator
from airflow.providers.databricks.operators.databricks_workflow import (
    DatabricksWorkflowTaskGroup,
)
from airflow.operators.bash import BashOperator

# ── Default arguments ─────────────────────────────────────────────────────────
default_args = {
    "owner":            "ihtheram",
    "depends_on_past":  False,
    "email_on_failure": False,
    "email_on_retry":   False,
    "retries":          1,
    "retry_delay":      timedelta(minutes=5),
}

# ── DAG definition ────────────────────────────────────────────────────────────
with DAG(
    dag_id="retailpulse_pipeline",
    description="End-to-end RetailPulse data pipeline: Bronze ingestion → dbt models → dbt tests",
    default_args=default_args,
    start_date=datetime(2024, 1, 1),
    schedule_interval="@daily",          # run once per day
    catchup=False,
    tags=["retailpulse", "databricks", "dbt", "delta-lake"],
) as dag:

    # ── Task 1: Bronze Ingestion ───────────────────────────────────────────────
    # Runs the Auto Loader notebook that reads CSV files from S3
    # and writes them as Delta tables to workspace.retailpulse_bronze
    ingest_bronze = DatabricksRunNowOperator(
        task_id="ingest_bronze",
        databricks_conn_id="databricks_default",
        job_id="{{ var.value.databricks_bronze_job_id }}",   # set in Airflow Variables
        notebook_params={
            "source_path":      "s3://retailpulse-raw-data-landing/raw/retail/",
            "bronze_schema":    "workspace.retailpulse_bronze",
            "checkpoint_base":  "/Volumes/workspace/retailpulse_bronze/checkpoints/",
        },
    )

    # ── Task 2: dbt Models ────────────────────────────────────────────────────
    # Runs dbt deps + dbt run to build:
    #   - workspace.retailpulse_staging.stg_orders
    #   - workspace.retailpulse_staging.stg_customers
    #   - workspace.retailpulse_staging.stg_products
    #   - workspace.retailpulse_gold.daily_sales
    #   - workspace.retailpulse_gold.top_customers
    #   - workspace.retailpulse_gold.revenue_by_category
    #   - workspace.retailpulse_gold.orders_by_country
    run_dbt_models = BashOperator(
        task_id="run_dbt_models",
        bash_command=(
            "cd /opt/airflow/dbt_retailpulse && "
            "dbt deps && "
            "dbt run --profiles-dir /opt/airflow/dbt_retailpulse"
        ),
        env={
            "DBT_DATABRICKS_HOST":      "{{ var.value.databricks_host }}",
            "DBT_DATABRICKS_TOKEN":     "{{ var.value.databricks_token }}",
            "DBT_DATABRICKS_HTTP_PATH": "{{ var.value.databricks_http_path }}",
        },
    )

    # ── Task 3: dbt Tests ─────────────────────────────────────────────────────
    # Runs dbt test to validate all 21 data quality tests:
    #   - unique / not_null on primary keys
    #   - accepted_range (min=0) on amount and price
    run_dbt_tests = BashOperator(
        task_id="run_dbt_tests",
        bash_command=(
            "cd /opt/airflow/dbt_retailpulse && "
            "dbt test --profiles-dir /opt/airflow/dbt_retailpulse"
        ),
        env={
            "DBT_DATABRICKS_HOST":      "{{ var.value.databricks_host }}",
            "DBT_DATABRICKS_TOKEN":     "{{ var.value.databricks_token }}",
            "DBT_DATABRICKS_HTTP_PATH": "{{ var.value.databricks_http_path }}",
        },
    )

    # ── Dependencies ──────────────────────────────────────────────────────────
    ingest_bronze >> run_dbt_models >> run_dbt_tests
