select
    t.ride_id,
    t.rideable_type,
    t.type_of_rider,
    t.started_at,
    t.ended_at,
    t.trip_duration_in_minutes,
    t.distance_in_km,
    t.distance_from_center_to_start,
    t.distance_from_center_to_end,
    t.avrage_speed_kmh,
    cast(strftime(t.started_at, '%Y%m%d') as integer) as start_date_key,
    cast(strftime(t.ended_at, '%Y%m%d') as integer) as end_date_key,
    ss.station_id as start_station_id,
    ss.station_name as start_station_name,
    es.station_id as end_station_id,
    es.station_name as end_station_name
from {{ref('int_trips_enriched')}} t
left join {{ ref('dim_station') }} ss
    on t.start_station_id = ss.station_id
    and (t.started_at < ss.valid_to or ss.valid_to is null)
left join {{ ref('dim_station') }} es
    on t.end_station_id = es.station_id
    and (t.ended_at < es.valid_to or es.valid_to is null)