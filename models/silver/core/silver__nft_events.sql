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
        sale_price,
        royalty_address,
        payment_asset,
        marketplace_fee_address,
        owner_address,
        collection_address,
        content_onchain,
        trace_id,
        sale_contract,
        forward_amount,
        nft_item_index,
        query_id,
        is_init,
        TIMESTAMP,
        nft_item_address,
        custom_payload,
        COMMENT,
        sale_end_time,
        sale_type,
        auction_max_bid,
        auction_min_bid,
        marketplace_address,
        forward_payload,
        royalty_amount,
        auction_min_step,
        TYPE,
        prev_owner,
        tx_hash,
        marketplace_fee,
        lt,
        _inserted_timestamp
    FROM
        {{ ref('bronze__nft_events') }}
        {# qualify ROW_NUMBER() over (
        PARTITION BY tx_hash,
        nft_item_index,
        TIMESTAMP,
        TYPE
    ORDER BY
        _inserted_timestamp DESC
) = 1 #}
)
SELECT
    block_date,
    sale_price,
    royalty_address,
    payment_asset,
    marketplace_fee_address,
    owner_address,
    collection_address,
    content_onchain,
    trace_id,
    sale_contract,
    forward_amount,
    nft_item_index,
    query_id,
    is_init,
    TIMESTAMP,
    nft_item_address,
    custom_payload,
    COMMENT,
    sale_end_time,
    sale_type,
    auction_max_bid,
    auction_min_bid,
    marketplace_address,
    forward_payload,
    royalty_amount,
    auction_min_step,
    TYPE,
    prev_owner,
    tx_hash,
    marketplace_fee,
    lt,
    _inserted_timestamp,
    {{ dbt_utils.generate_surrogate_key(
        ['tx_hash','nft_item_index','timestamp','type']
    ) }} AS nft_events_id,
    SYSDATE() AS inserted_timestamp,
    SYSDATE() AS modified_timestamp,
    '{{ invocation_id }}' AS _invocation_id
FROM
    pre_final
