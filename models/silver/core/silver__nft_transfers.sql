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
        trace_id,
        tx_now,
        custom_payload,
        new_owner,
        forward_payload,
        COMMENT,
        old_owner,
        tx_aborted,
        query_id,
        tx_hash,
        tx_lt,
        response_destination,
        nft_collection_address,
        forward_amount,
        nft_item_address,
        nft_item_index,
        _inserted_timestamp
    FROM
        {{ ref('bronze__nft_transfers') }}
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
    trace_id,
    tx_now,
    custom_payload,
    new_owner,
    forward_payload,
    COMMENT,
    old_owner,
    tx_aborted,
    query_id,
    tx_hash,
    tx_lt,
    response_destination,
    nft_collection_address,
    forward_amount,
    nft_item_address,
    nft_item_index,
    _inserted_timestamp,
    {{ dbt_utils.generate_surrogate_key(
        ['tx_hash']
    ) }} AS nft_transfers_id,
    SYSDATE() AS inserted_timestamp,
    SYSDATE() AS modified_timestamp,
    '{{ invocation_id }}' AS _invocation_id
FROM
    pre_final
