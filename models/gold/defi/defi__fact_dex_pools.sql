{{ config(
    materialized = 'incremental',
    unique_key = ['fact_dex_pools_id'],
    incremental_strategy = 'merge',
    merge_exclude_columns = ['inserted_timestamp'],
    cluster_by = ['block_timestamp_last_updated::DATE'],
    post_hook = "ALTER TABLE {{ this }} ADD SEARCH OPTIMIZATION ON EQUALITY(pool);",
    tags = ['scheduled_core']
) }}

SELECT
    TO_TIMESTAMP(last_updated) AS block_timestamp_last_updated,
    TO_TIMESTAMP(discovered_at) AS block_timestamp_discovered_at,
    project,
    pool,
    version,
    is_liquid,
    reserves_right,
    reserves_left,
    jetton_right,
    jetton_left,
    total_supply,
    protocol_fee,
    referral_fee,
    lp_fee,
    tvl_ton,
    tvl_usd,
    last_updated,
    discovered_at,
    dex_pools_id AS fact_dex_pools_id,
    SYSDATE() AS inserted_timestamp,
    SYSDATE() AS modified_timestamp
FROM
    {{ ref('silver__dex_pools') }}

{% if is_incremental() %}
WHERE
    modified_timestamp >= (
        SELECT
            MAX(modified_timestamp)
        FROM
            {{ this }}
    )
{% endif %}
