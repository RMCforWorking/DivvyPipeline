from __future__ import annotations

from datetime import datetime, timedelta

from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.python import PythonOperator
from airflow.utils.task_group import TaskGroup

from load_trips import load_trips, validate_bronze

DBT_DIR = "/opt/airflow/dbt"

default_args = {
    "owner": "divvy",
    "depends_on_past": False,
    "retries": 1,
    "retry_delay": timedelta(seconds=30),
}

with DAG(
    dag_id="divvy_ingest_pipeline",
    description="Divvy bikeshare pipeline: Airflow + DuckDB + dbt",
    default_args=default_args,
    start_date=datetime(2026, 1, 1),
    schedule=None,
    catchup=False,
    tags=["divvy", "dbt", "duckdb"],
    doc_md="""
    ### Divvy Bikeshare pipeline

    1. **Extract + load** raw monthly trip parquet files into DuckDB (`bronze.trips`)
    2. **Validate** bronze data (table exists, non-empty, basic sanity checks)
    3. **Build** staging + intermediate models, then snapshot the station
       dimension (SCD Type 2 — tracks renames/relocations over time)
    4. **Build marts** (`fact_trips`, `dim_station`, `dim_date`)
    5. **Finalize** — build reporting models and run dbt tests in parallel
       (reports only depend on marts, not on each other's test results),
       then generate dbt docs once both are done
    """,
) as dag:

    extract_load = PythonOperator(
        task_id="extract_and_load",
        python_callable=load_trips,
    )

    validate_bronze_task = PythonOperator(
        task_id="validate_bronze",
        python_callable=validate_bronze,
    )

    with TaskGroup("dbt_build") as dbt_build:
        dbt_run_staging_intermediate = BashOperator(
            task_id="dbt_run_staging_intermediate",
            bash_command=f"cd {DBT_DIR} && dbt run --select staging intermediate",
        )

        dbt_snapshot = BashOperator(
            task_id="dbt_snapshot_dim_station",
            bash_command=f"cd {DBT_DIR} && dbt snapshot",
        )

        dbt_run_marts = BashOperator(
            task_id="dbt_run_marts",
            bash_command=f"cd {DBT_DIR} && dbt run --select marts",
        )

        dbt_run_staging_intermediate >> dbt_snapshot >> dbt_run_marts

    with TaskGroup("dbt_finalize") as dbt_finalize:
        dbt_run_reports = BashOperator(
            task_id="dbt_run_reports",
            bash_command=f"cd {DBT_DIR} && dbt run --select reports",
        )

        dbt_test = BashOperator(
            task_id="dbt_test",
            bash_command=f"cd {DBT_DIR} && dbt test",
        )

        dbt_docs = BashOperator(
            task_id="dbt_docs_generate",
            bash_command=f"cd {DBT_DIR} && dbt docs generate",
        )

        [dbt_run_reports, dbt_test] >> dbt_docs

    extract_load >> validate_bronze_task >> dbt_build >> dbt_finalize