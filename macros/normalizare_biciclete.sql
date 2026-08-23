{% macro normalizare_biciclete(column_name) %}
case
    when {{ column_name }} = 'docked_bike'
        then 'classic_bike'
    else
        {{ column_name }}
end
{% endmacro %}