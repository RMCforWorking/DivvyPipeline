select *
from {{ ref('dim_station_snapshot') }}
where dbt_valid_to is not null