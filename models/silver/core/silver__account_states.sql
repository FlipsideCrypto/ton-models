-- depends_on: {{ ref('bronze__accounts') }}
{{ config(
    materialized = 'incremental',
    unique_key = ["account_id","closed_at"],
    incremental_predicates = ["dynamic_range_predicate", "partition_id::date"],
    merge_exclude_columns = ["inserted_timestamp"],
    cluster_by = ['closed_at::DATE','partition_id','modified_timestamp::DATE'],
    tags = ['scheduled_core'],
) }}

{% if execute %}

{% if is_incremental() %}
{% set max_is_query %}

SELECT
    MAX(_inserted_timestamp) AS _inserted_timestamp
FROM
    {{ this }}

    {% endset %}
    {% set result = run_query(max_is_query) %}
    {% set max_is = result [0] [0] %}
    {% set max_part = result [0] [1] %}
{% endif %}
{% endif %}

WITH pre_final AS (
    SELECT
        block_date,
        account,
        last_trans_lt,
        last_trans_hash,
        account_status,
        balance,
        data_boc,
        data_hash,
        frozen_hash,
        TIMESTAMP,
        code_hash,
        code_boc,
        HASH,
        _inserted_timestamp
    FROM

{% if is_incremental() %}
{{ ref('bronze__account_states') }}
{% else %}
    {{ ref('bronze__account_states_FR') }}
{% endif %}

{% if is_incremental() %}
WHERE
    _inserted_timestamp > '{{ max_is }}'
{% endif %}

qualify ROW_NUMBER() over (
    PARTITION BY account,
    TIMESTAMP
    ORDER BY
        _inserted_timestamp DESC
) = 1
)
SELECT
    block_date,
    account,
    last_trans_lt,
    last_trans_hash,
    account_status,
    balance,
    data_boc,
    data_hash,
    frozen_hash,
    TIMESTAMP,
    code_hash,
    code_boc,
    HASH,
    _inserted_timestamp,
    {{ dbt_utils.generate_surrogate_key(
        ['account','timestamp']
    ) }} AS account_states_id,
    SYSDATE() AS inserted_timestamp,
    SYSDATE() AS modified_timestamp,
    '{{ invocation_id }}' AS _invocation_id
FROM
    pre_final
