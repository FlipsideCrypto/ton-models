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
        reserves_right,
        project,
        pool,
        protocol_fee,
        last_updated,
        discovered_at,
        version,
        jetton_right,
        tvl_ton,
        jetton_left,
        reserves_left,
        referral_fee,
        is_liquid,
        total_supply,
        tvl_usd,
        lp_fee,
        _inserted_timestamp
    FROM
        {{ ref('bronze__dex_pools') }}
        {# qualify ROW_NUMBER() over (
        PARTITION BY pool,
        last_updated
    ORDER BY
        _inserted_timestamp DESC
) = 1 #}
)
SELECT
    block_date,
    reserves_right,
    project,
    pool,
    protocol_fee,
    last_updated,
    discovered_at,
    version,
    jetton_right,
    tvl_ton,
    jetton_left,
    reserves_left,
    referral_fee,
    is_liquid,
    total_supply,
    tvl_usd,
    lp_fee,
    _inserted_timestamp,
    {{ dbt_utils.generate_surrogate_key(
        ['pool','last_updated']
    ) }} AS dex_pools_id,
    SYSDATE() AS inserted_timestamp,
    SYSDATE() AS modified_timestamp,
    '{{ invocation_id }}' AS _invocation_id
FROM
    pre_final
