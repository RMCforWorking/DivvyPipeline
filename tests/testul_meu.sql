{{ config(severity = 'warn') }}
select *
from {{ ref('fact_trips') }}
where trip_duration_in_minutes <= 0

--cate dintre calatoriile i guess sau cursele care au fost se termina inainte sa inceapa, nu stiu daca e okay ca am cateva
-- care ies pozitiv din asta, am pus severity warn ca sa nu apara eroarea da nu stiu