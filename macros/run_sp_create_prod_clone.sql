{% macro run_sp_create_prod_clone() %}
    {% set clone_query %}
    call ton._internal.create_prod_clone(
        'ton',
        'ton_dev',
        'internal_dev'
    );
{% endset %}
    {% do run_query(clone_query) %}
{% endmacro %}
