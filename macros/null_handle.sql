{% macro null_handle(column_name) %}
    nullif(trim({{column_name}}),'')
{% endmacro %}