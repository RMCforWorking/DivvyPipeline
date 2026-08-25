select
    ride_id,
    rideable_type,
    type_of_rider,
    started_at,
    ended_at,
    start_station_id,
    start_station_name,
    start_lat,
    start_lng,
    end_station_id,
    end_station_name,
    end_lat,
    end_lng,
    date_diff('minute', started_at, ended_at) as trip_duration_in_minutes,
    {{ calcul_distanta_aprox('start_lat', 'start_lng', 'end_lat', 'end_lng') }} as distance_in_km,
    case
        when start_lat is null or start_lng is null then null
        else {{ calcul_distanta_aprox('start_lat', 'start_lng', '41.8781', '-87.6298') }}
    end as distance_from_center_to_start,
    case
        when end_lat is null or end_lng is null then null
        else {{ calcul_distanta_aprox('41.8781', '-87.6298', 'end_lat', 'end_lng') }}
    end as distance_from_center_to_end,
    case
        when trip_duration_in_minutes>0 and round(distance_in_km/(trip_duration_in_minutes/60.0),2) <=45
            then round(distance_in_km/(trip_duration_in_minutes/60.0),2)
        else null
    end as avrage_speed_kmh
from {{ ref('stg_trips') }}
where date_diff('minute', started_at, ended_at) >= 0