with monthly as(
    select
        date_trunc('month',started_at) as month,
        count(*) as total_trips,
        count(*) filter(where type_of_rider='member') as n_members,
        count(*) filter(where type_of_rider='casual') as n_casuals,
        round(avg(trip_duration_in_minutes),2) as avg_duration_min
    from {{ref('fact_trips')}}
    group by month
)

select
    month,
    total_trips,
    avg_duration_min,
    round(100.0*n_members/total_trips,1) as procent_member,
    round(100.0*n_casuals/total_trips,1) as procent_casual,
    lag(avg_duration_min) over(order by month) as last_months_duration,
    lag(procent_member) over(order by month) as last_month_members,
    round(avg_duration_min- last_months_duration,2) as duration_diff_from_last_month,
    round(procent_member-last_month_members,2) as members_diff_from_last_month
from monthly
order by month