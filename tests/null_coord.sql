{{ config(severity = 'warn') }}
select *
from {{ref('int_trips_enriched')}}
where start_lat = null or start_lng = null
or end_lat = null or end_lng = null