{{ config(severity = 'warn') }}
select *
from {{ref('int_trips_enriched')}}
where start_lat is null or start_lng is null
or end_lat is null or end_lng is null