{{ config(
    materialized = 'incremental',
    unique_key = ['fact_nft_transfers_id'],
    incremental_strategy = 'merge',
    merge_exclude_columns = ['inserted_timestamp'],
    cluster_by = ['block_timestamp::DATE'],
    post_hook = "ALTER TABLE {{ this }} ADD SEARCH OPTIMIZATION ON EQUALITY(tx_hash,old_owner,new_owner,nft_collection_address,nft_item_address);",
    tags = ['scheduled_core']
) }}

SELECT
    TO_TIMESTAMP(tx_now) AS block_timestamp,
    tx_hash,
    CASE
        WHEN tx_aborted THEN FALSE
        ELSE TRUE
    END tx_succeeded,
    tx_aborted,
    old_owner,
    new_owner,
    nft_collection_address,
    nft_item_address,
    nft_item_index,
    response_destination,
    forward_amount,
    custom_payload,
    forward_payload,
    COMMENT,
    trace_id,
    query_id,
    tx_now,
    tx_lt,
    nft_transfers_id AS fact_nft_transfers_id,
    SYSDATE() AS inserted_timestamp,
    SYSDATE() AS modified_timestamp
FROM
    {{ ref('silver__nft_transfers') }}

{% if is_incremental() %}
WHERE
    modified_timestamp >= (
        SELECT
            MAX(modified_timestamp)
        FROM
            {{ this }}
    )
{% endif %}
