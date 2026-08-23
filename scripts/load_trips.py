from __future__ import annotations

import os
from pathlib import Path

import duckdb


def _paths() -> tuple[Path, Path]:
    duckdb_path = Path(
        os.environ.get(
            "DIVVY_DUCKDB_PATH",
            "/opt/airflow/warehouse/divvy.duckdb",
        )
    )
    data_dir = Path(os.environ.get("DIVVY_DATA_DIR", "/opt/airflow/data"))
    return duckdb_path, data_dir


def load_trips() -> str:
    duckdb_path, data_dir = _paths()
    duckdb_path.parent.mkdir(parents=True, exist_ok=True)

    trips_glob = str(data_dir / "*-divvy-tripdata.parquet")

    con = duckdb.connect(str(duckdb_path))
    try:
        con.execute("CREATE SCHEMA IF NOT EXISTS bronze")

        con.execute(
            f"""
                CREATE OR REPLACE TABLE bronze.trips AS
                SELECT
                    *,
                    -- keep the source month visible, useful later for
                    -- partition-level checks and incremental logic
                    regexp_extract(filename, '(\\d{{6}})-divvy-tripdata', 1) AS source_month
                FROM read_parquet('{trips_glob}', union_by_name=True, filename=True)
                """
        )

        n = con.execute("SELECT COUNT(*) FROM bronze.trips").fetchone()[0]
        months = con.execute(
            "SELECT COUNT(DISTINCT source_month) FROM bronze.trips"
        ).fetchone()[0]
        print(f"Loaded bronze.trips → {n} rows across {months} months")
        print(f"Warehouse → {duckdb_path}")
    finally:
        con.close()

    return str(duckdb_path)


def validate_bronze() -> None:
    duckdb_path, _ = _paths()
    if not duckdb_path.exists():
        raise FileNotFoundError(f"DuckDB file not found: {duckdb_path}")

    con = duckdb.connect(str(duckdb_path), read_only=True)
    try:
        exists = con.execute(
            """
            SELECT COUNT(*)
            FROM information_schema.tables
            WHERE table_schema = 'bronze' AND table_name = 'trips'
            """
        ).fetchone()[0]
        if not exists:
            raise RuntimeError("Missing table bronze.trips")

        n = con.execute("SELECT COUNT(*) FROM bronze.trips").fetchone()[0]
        if n == 0:
            raise RuntimeError("bronze.trips is empty")

        dup_n = con.execute(
            """
            SELECT COUNT(*) FROM (
                SELECT ride_id, COUNT(*) AS c
                FROM bronze.trips
                GROUP BY ride_id
                HAVING COUNT(*) > 1
            )
            """
        ).fetchone()[0]
        if dup_n > 0:
            print(f"WARNING bronze.trips → {dup_n} duplicated ride_id values")

        print(f"OK bronze.trips → {n} rows")
    finally:
        con.close()


if __name__ == "__main__":
    load_trips()
    validate_bronze()