with stations_from_start as (
select
    start_station_id as station_id,
    start_station_name as station_name,
    start_lat as latitude,
    start_lng as longitude
    from {{ref('stg_trips')}}
    where start_station_id is not null
),

stations_to_end as (
select
    end_station_id as station_id,
    end_station_name as station_name,
    end_lat as latitude,
    end_lng as longitude
    from {{ref('stg_trips')}}
    where end_station_id is not null
),

all_stations_observations as (
select * from stations_from_start
union all
select * from stations_to_end
),

ranked as(
select
    station_id,
    station_name,
    latitude,
    longitude,
    count(*) as observation_count,
    row_number() over (
        partition by station_id
        order by count(*) desc, station_name, latitude, longitude
    ) as rn
    from all_stations_observations
    group by station_id, station_name, latitude, longitude
)

select
    station_id,
    station_name,
    latitude,
    longitude
from ranked
where rn = 1
