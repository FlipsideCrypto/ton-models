{{ config(
    materialized = 'incremental',
    unique_key = ['fact_dex_trades_id'],
    incremental_strategy = 'merge',
    merge_exclude_columns = ['inserted_timestamp'],
    cluster_by = ['block_timestamp::DATE'],
    post_hook = "ALTER TABLE {{ this }} ADD SEARCH OPTIMIZATION ON EQUALITY(tx_hash,pool_address,trader_address,token_bought_address,token_sold_address);",
    tags = ['scheduled_core']
) }}

SELECT
    TO_TIMESTAMP(event_time) AS block_timestamp,
    event_type,
    tx_hash,
    project_type,
    project,
    pool_address,
    version,
    trader_address,
    token_bought_address,
    token_sold_address,
    amount_bought_raw,
    amount_sold_raw,
    router_address,
    volume_ton,
    volume_usd,
    referral_address,
    platform_tag,
    trace_id,
    query_id,
    event_time,
    dex_trades_id AS fact_dex_trades_id,
    SYSDATE() AS inserted_timestamp,
    SYSDATE() AS modified_timestamp
FROM
    {{ ref('silver__dex_trades') }}

{% if is_incremental() %}
WHERE
    modified_timestamp >= (
        SELECT
            MAX(modified_timestamp)
        FROM
            {{ this }}
    )
{% endif %}
