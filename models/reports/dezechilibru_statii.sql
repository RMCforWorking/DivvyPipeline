with arrivals as(
    select
        end_station_id as station_id,
        end_station_name as station_name,
        type_of_rider,
        count(*) as n_arrivals
    from {{ref('fact_trips')}}
        where end_station_id is not null and extract(dow from ended_at) between 1 and 5
        group by station_id,station_name,type_of_rider
),
departures as(
    select
        start_station_id as station_id,
        start_station_name as station_name,
        type_of_rider,
        count(*) as n_departures
    from {{ref('fact_trips')}}
        where start_station_id is not null and extract(dow from started_at) between 1 and 5
        group by station_id,station_name,type_of_rider
)
select
    coalesce(d.station_id,a.station_id) as station_id,
    coalesce(d.station_name,a.station_name) as station_name,
    coalesce(d.type_of_rider,a.type_of_rider) as type_of_rider,
    coalesce(d.n_departures,0) as n_departures,
    coalesce(a.n_arrivals,0) as n_arrivals,
    coalesce(d.n_departures,0) - coalesce(a.n_arrivals,0) as net_imbalance
from departures d
full outer join arrivals a
    on d.station_id=a.station_id
    and d.type_of_rider=a.type_of_rider
    order by abs(net_imbalance) desc