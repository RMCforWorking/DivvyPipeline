with data_tmp as (
    select
        unnest(
            generate_series(
                (select min(cast(started_at as date)) from {{ref('int_trips_enriched')}}),
                (select max(cast(started_at as date)) from {{ref('int_trips_enriched')}}),
                interval 1 day
            )
        ) as fulldate
)

select
    cast(strftime(fulldate,'%Y%m%d') as integer) as date_key,
    fulldate,
    extract(year from fulldate) as year,
    extract(month from fulldate) as month,
    strftime(fulldate,'%B') as month_name,
    extract(day from fulldate) as day_of_month,
    dayofweek(fulldate) as day_of_week,
    strftime(fulldate,'%A') as day_name
    from data_tmp