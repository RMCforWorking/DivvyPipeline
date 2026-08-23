with monthly as(
    select
        date_trunc('month',started_at) as month,
        count(*) as total_trips,
        count(*) filter(where rideable_type='electric_bike') as electric_bikes,
        count(*) filter(where rideable_type='classic_bike') as classic_bikes
    from {{ref('fact_trips')}}
    group by month
)

select
    month,
    total_trips,
    round(100.0*electric_bikes/total_trips,2) as procent_electric,
    round(100.0*classic_bikes/total_trips,2) as procent_classic,
    lag(procent_electric) over(order by month) as last_months_electric_bikes,
    round(procent_electric-last_months_electric_bikes,2) as monthly_diff_electric_ussage
from monthly
order by month