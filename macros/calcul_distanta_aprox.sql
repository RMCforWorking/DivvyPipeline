{% macro calcul_distanta_aprox(lat1, lng1, lat2, lng2) %}
    (
        6371 * acos(
            least(1.0, greatest(-1.0,
                cos({{ lat1 }} * 0.017453292519943295) * cos({{ lat2 }} * 0.017453292519943295) *
                cos(({{ lng2 }} - {{ lng1 }}) * 0.017453292519943295) +
                sin({{ lat1 }} * 0.017453292519943295) * sin({{ lat2 }} * 0.017453292519943295)
            ))
        )
    )
{% endmacro %}