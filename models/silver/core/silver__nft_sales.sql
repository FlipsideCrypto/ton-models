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
        is_canceled,
        marketplace_fee_address,
        end_time,
        is_complete,
        last_member,
        marketplace_address,
        royalty_amount,
        created_at,
        nft_address,
        marketplace_fee,
        asset,
        price,
        nft_owner_address,
        address,
        min_bid,
        TIMESTAMP,
        royalty_address,
        min_step,
        max_bid,
        last_bid_at,
        lt,
        TYPE,
        _inserted_timestamp
    FROM
        {{ ref('bronze__nft_sales') }}
        {# qualify ROW_NUMBER() over (
        PARTITION BY seqno,
        shard,
        workchain
    ORDER BY
        _inserted_timestamp DESC
) = 1 #}
)
SELECT
    block_date,
    is_canceled,
    marketplace_fee_address,
    end_time,
    is_complete,
    last_member,
    marketplace_address,
    royalty_amount,
    created_at,
    nft_address,
    marketplace_fee,
    asset,
    price,
    nft_owner_address,
    address,
    min_bid,
    TIMESTAMP,
    royalty_address,
    min_step,
    max_bid,
    last_bid_at,
    lt,
    TYPE,
    _inserted_timestamp,
    {{ dbt_utils.generate_surrogate_key(
        ['address','nft_address','timestamp']
    ) }} AS nft_sales_id,
    SYSDATE() AS inserted_timestamp,
    SYSDATE() AS modified_timestamp,
    '{{ invocation_id }}' AS _invocation_id
FROM
    pre_final
