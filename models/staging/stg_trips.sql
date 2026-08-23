select
    trim(ride_id) as ride_id,
    {{ normalizare_biciclete('rideable_type') }} as rideable_type,
    started_at,
    ended_at,
    {{ null_handle('start_station_name') }} as start_station_name,
    {{ normalizare_statie_id('start_station_id') }} as start_station_id,
    {{ null_handle('end_station_name') }} as end_station_name,
    {{ normalizare_statie_id('end_station_id') }} as end_station_id,
    start_lat,
    start_lng,
    end_lat,
    end_lng,
    member_casual as type_of_rider
from bronze.trips