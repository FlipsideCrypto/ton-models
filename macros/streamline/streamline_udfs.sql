{% macro create_udf_bulk_rest_api_v2() %}
    CREATE
    OR REPLACE EXTERNAL FUNCTION streamline.udf_bulk_rest_api_v2(
        json OBJECT
    ) returns ARRAY {% if target.database == 'TON' -%}
        api_integration = aws_ton_api_prod AS 'https://e2rz7s6i8j.execute-api.us-east-1.amazonaws.com/prod/udf_bulk_rest_api'
    {% else %}
        api_integration = aws_ton_api_stg_v2 AS 'https://f1nw4eppf9.execute-api.us-east-1.amazonaws.com/stg/udf_bulk_rest_api'
    {%- endif %}
{% endmacro %}
