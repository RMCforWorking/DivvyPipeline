from __future__ import annotations

from datetime import datetime

from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.empty import EmptyOperator
from airflow.operators.python import PythonOperator

from load_trips import load_trips, validate_bronze

DBT_DIR = "/opt/airflow/dbt"

default_args = {
    "owner": "divvy",
    "depends_on_past": False,
    "retries": 1,
}

with DAG(
    dag_id='divvy_ingest_pipeline',
    start_date=datetime(2026,1,1),
    schedule_interval=None,
    catchup=False
) as dag:
    extract_load = PythonOperator(
        task_id="extract_and_load",
        python_callable=load_trips,
    )

    validate_bronze_task = PythonOperator(
        task_id='validate_bronze',
        python_callable=validate_bronze,
    )

    dbt_snapshot= BashOperator(
        task_id='dbt_snapshot_for_dim_station',
        bash_command=f"cd {DBT_DIR} && dbt snapshot"
    )

    dbt_run_staging_intermediate =BashOperator(
        task_id='dbt_run_with_staging_and_intermediate',
        bash_command=f"cd {DBT_DIR} && dbt run --select staging intermediate"
    )

    dbt_run_marts = BashOperator(
        task_id='dbt_run_marts',
        bash_command=f"cd {DBT_DIR} && dbt run --select marts"
    )

    dbt_test=BashOperator(
        task_id='test_dbt',
        bash_command=f"cd {DBT_DIR} && dbt test"
    )

    dbt_docs = BashOperator(
        task_id="dbt_docs_generate",
        bash_command=f"cd {DBT_DIR} && dbt docs generate",
    )

    extract_load >> validate_bronze_task >> dbt_run_staging_intermediate >> dbt_snapshot >> dbt_run_marts >> dbt_test >> dbt_docs

