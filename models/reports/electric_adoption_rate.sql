with monthly as(
    select
        date_trunc('month',started_at) as month,
        count(*) as total_trips,
        count(*) filter(where type_of_rider = 'member') as nr_members,
        count(*) filter(where type_of_rider = 'casual') as nr_casuals
    from {{ref('fact_trips')}}
        where rideable_type = 'electric_bike'
    group by month
)

select
    month,
    total_trips,
    round(100.0*nr_members/total_trips,2) as percentage_of_members,
    round(100.0*nr_casuals/total_trips,2) as percentage_of_casuals,
    lag(percentage_of_members) over(order by month) as last_months_members,
    lag(percentage_of_casuals) over(order by month) as last_months_casuals,
    round(percentage_of_members-last_months_members,2) as percentaje_difference_between_types
from monthly
order by month