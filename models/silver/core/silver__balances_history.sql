{{ config(
    materialized = 'incremental',
    incremental_strategy = 'microbatch',
    event_time = 'block_date',
    begin = '2024-01-01',
    batch_size = 'day',
    cluster_by = ['block_date::DATE','modified_timestamp::DATE'],
    tags = ['scheduled_core']
) }}

WITH pre_final AS (

    SELECT
        block_date,
        lt,
        asset,
        address,
        amount,
        TIMESTAMP,
        mintless_claimed,
        _inserted_timestamp
    FROM
        {{ ref('bronze__balances_history') }}
        {# qualify ROW_NUMBER() over (
        PARTITION BY address,
        asset,
        TIMESTAMP
    ORDER BY
        _inserted_timestamp DESC
) = 1 #}
)
SELECT
    block_date,
    lt,
    asset,
    address,
    amount,
    TIMESTAMP,
    mintless_claimed,
    _inserted_timestamp,
    {{ dbt_utils.generate_surrogate_key(
        ['address','asset','TIMESTAMP']
    ) }} AS balances_history_id,
    SYSDATE() AS inserted_timestamp,
    SYSDATE() AS modified_timestamp,
    '{{ invocation_id }}' AS _invocation_id
FROM
    pre_final
