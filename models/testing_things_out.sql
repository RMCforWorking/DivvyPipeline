select
    ride_id,
    end_lat, end_lng,
    distance_from_center_to_end,
    distance_from_center_to_start
from {{ ref('int_trips_enriched') }}
where distance_from_center_to_start > 100 or distance_from_center_to_end > 100
order by greatest(distance_from_center_to_start, distance_from_center_to_end) desc