{{ config(
    materialized = 'incremental',
    unique_key = ['fact_nft_events_id'],
    incremental_strategy = 'merge',
    merge_exclude_columns = ['inserted_timestamp'],
    cluster_by = ['block_timestamp::DATE'],
    post_hook = "ALTER TABLE {{ this }} ADD SEARCH OPTIMIZATION ON EQUALITY(tx_hash,nft_item_address,sale_contract,marketplace_address );",
    tags = ['scheduled_core']
) }}

SELECT
    TO_TIMESTAMP(TIMESTAMP) AS block_timestamp,
    tx_hash,
    TYPE,
    sale_type,
    nft_item_address,
    nft_item_index,
    payment_asset,
    sale_price,
    forward_amount,
    royalty_amount,
    marketplace_fee,
    auction_max_bid,
    auction_min_bid,
    sale_contract,
    royalty_address,
    marketplace_address,
    marketplace_fee_address,
    owner_address,
    collection_address,
    content_onchain,
    trace_id,
    query_id,
    is_init,
    custom_payload,
    COMMENT,
    sale_end_time,
    forward_payload,
    auction_min_step,
    prev_owner,
    TIMESTAMP,
    lt,
    nft_events_id AS fact_nft_events_id,
    SYSDATE() AS inserted_timestamp,
    SYSDATE() AS modified_timestamp
FROM
    {{ ref('silver__nft_events') }}

{% if is_incremental() %}
WHERE
    modified_timestamp >= (
        SELECT
            MAX(modified_timestamp)
        FROM
            {{ this }}
    )
{% endif %}
