{% macro normalizare_statie_id(column_name) %}
case
    when {{ column_name }} is null then null
    when trim(cast({{ column_name }} as varchar)) = '' then null
    else
        regexp_replace(
            trim(cast({{ column_name }} as varchar)),
            '\.0$',
            ''
        )
end
{% endmacro %}