with resurse as (
    select
        rideable_type,
        case
            when distance_in_km < 1 then '0-1 km'
            when distance_in_km < 2 then '1-2 km'
            when distance_in_km < 3 then '2-3 km'
            when distance_in_km < 5 then '3-5 km'
            when distance_in_km < 8 then '5-8 km'
            else '8+ km'
        end as distance_bucket,
        avrage_speed_kmh,
        trip_duration_in_minutes
    from {{ ref('fact_trips') }}
    where trip_duration_in_minutes > 0
      and distance_in_km > 0
      and avrage_speed_kmh is not null
)

select
    distance_bucket,
    rideable_type,
    count(*) as n_trips,
    round(avg(avrage_speed_kmh), 2) as avrage_speed_kmh,
    round(avg(trip_duration_in_minutes), 2) as avg_duration_min

from resurse
group by distance_bucket,rideable_type
order by
    case distance_bucket
        when '0-1 km' then 1
        when '1-2 km' then 2
        when '2-3 km' then 3
        when '3-5 km' then 4
        when '5-8 km' then 5
        else 6
    end,
    rideable_type