{{ config(severity = 'warn') }}
select *
from {{ref('fact_trips')}}
where avrage_speed_km > 45