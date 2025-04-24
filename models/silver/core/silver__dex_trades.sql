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
        volume_ton,
        referral_address,
        token_bought_address,
        pool_address,
        project_type,
        amount_bought_raw,
        router_address,
        version,
        trace_id,
        volume_usd,
        token_sold_address,
        project,
        event_time,
        tx_hash,
        trader_address,
        event_type,
        amount_sold_raw,
        platform_tag,
        query_id,
        _inserted_timestamp
    FROM
        {{ ref('bronze__dex_trades') }}
        {# qualify ROW_NUMBER() over (
        PARTITION BY tx_hash,
        trace_id
    ORDER BY
        _inserted_timestamp DESC
) = 1 #}
)
SELECT
    block_date,
    volume_ton,
    referral_address,
    token_bought_address,
    pool_address,
    project_type,
    amount_bought_raw,
    router_address,
    version,
    trace_id,
    volume_usd,
    token_sold_address,
    project,
    event_time,
    tx_hash,
    trader_address,
    event_type,
    amount_sold_raw,
    platform_tag,
    query_id,
    _inserted_timestamp,
    {{ dbt_utils.generate_surrogate_key(
        ['tx_hash','trace_id','event_type']
    ) }} AS dex_trades_id,
    SYSDATE() AS inserted_timestamp,
    SYSDATE() AS modified_timestamp,
    '{{ invocation_id }}' AS _invocation_id
FROM
    pre_final
