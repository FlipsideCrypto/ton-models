{{ config(
    materialized = 'incremental',
    unique_key = ['fact_nft_sales_id'],
    incremental_strategy = 'merge',
    merge_exclude_columns = ['inserted_timestamp'],
    cluster_by = ['block_timestamp::DATE'],
    post_hook = "ALTER TABLE {{ this }} ADD SEARCH OPTIMIZATION ON EQUALITY(address,nft_address,asset,nft_owner_address);",
    tags = ['scheduled_core']
) }}

SELECT
    TO_TIMESTAMP(TIMESTAMP) AS block_timestamp,
    address,
    nft_address,
    TYPE,
    asset,
    price,
    marketplace_fee,
    royalty_amount,
    nft_owner_address,
    marketplace_address,
    marketplace_fee_address,
    royalty_address,
    is_complete,
    is_canceled,
    min_bid,
    max_bid,
    min_step,
    end_time,
    last_bid_at,
    last_member,
    created_at,
    TIMESTAMP,
    lt,
    nft_sales_id AS fact_nft_sales_id,
    SYSDATE() AS inserted_timestamp,
    SYSDATE() AS modified_timestamp
FROM
    {{ ref('silver__nft_sales') }}

{% if is_incremental() %}
WHERE
    modified_timestamp >= (
        SELECT
            MAX(modified_timestamp)
        FROM
            {{ this }}
    )
{% endif %}
