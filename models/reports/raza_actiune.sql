select
    rideable_type,
    round(max(distance_from_center_to_start),2) as max_start_range,
    round(max(distance_from_center_to_end),2) as max_end_range,
    greatest(max_start_range,max_end_range) as raza_de_actiune
from {{ref('fact_trips')}}
group by rideable_type