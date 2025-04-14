{{ config(
    materialized = 'incremental',
    unique_key = ['fact_nft_items_id'],
    incremental_strategy = 'merge',
    merge_exclude_columns = ['inserted_timestamp'],
    cluster_by = ['block_timestamp::DATE'],
    post_hook = "ALTER TABLE {{ this }} ADD SEARCH OPTIMIZATION ON EQUALITY(address,collection_address,owner_address);",
    tags = ['scheduled_core']
) }}

SELECT
    TO_TIMESTAMP(TIMESTAMP) AS block_timestamp,
    address,
    INDEX,
    collection_address,
    owner_address,
    content_onchain,
    is_init,
    lt,
    TIMESTAMP,
    nft_items_id AS fact_nft_items_id,
    SYSDATE() AS inserted_timestamp,
    SYSDATE() AS modified_timestamp
FROM
    {{ ref('silver__nft_items') }}

{% if is_incremental() %}
WHERE
    modified_timestamp >= (
        SELECT
            MAX(modified_timestamp)
        FROM
            {{ this }}
    )
{% endif %}
