{{ config(
    materialized = 'incremental',
    unique_key = ['fact_jetton_events_id'],
    incremental_strategy = 'merge',
    merge_exclude_columns = ['inserted_timestamp'],
    cluster_by = ['block_timestamp::DATE','source','destination'],
    tags = ['scheduled_core']
) }}

SELECT
    TO_TIMESTAMP(utime) AS block_timestamp,
    tx_hash,
    CASE
        WHEN tx_aborted THEN FALSE
        ELSE TRUE
    END tx_succeeded,
    TYPE,
    source,
    destination,
    forward_ton_amount,
    amount,
    jetton,
    COMMENT,
    query_id,
    tx_lt,
    utime,
    tx_aborted,
    jetton_events_id AS fact_jetton_events_id,
    SYSDATE() AS inserted_timestamp,
    SYSDATE() AS modified_timestamp
FROM
    {{ ref('silver__jetton_events') }}

{% if is_incremental() %}
WHERE
    modified_timestamp >= (
        SELECT
            MAX(modified_timestamp)
        FROM
            {{ this }}
    )
{% endif %}
