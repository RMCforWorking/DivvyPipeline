select
    station_id,
    station_name,
    latitude,
    longitude,
    dbt_valid_from as valid_from,
    dbt_valid_to as valid_to
from {{ ref('dim_station_snapshot') }}