{{ config(severity = 'warn') }}
select *
from {{ ref('fact_trips') }}
where trip_duration_in_minutes <= 0
