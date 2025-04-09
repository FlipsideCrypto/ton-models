{{ config(
    materialized = 'incremental',
    unique_key = ['fact_messages_id'],
    incremental_strategy = 'merge',
    merge_exclude_columns = ['inserted_timestamp'],
    cluster_by = ['block_timestamp::DATE'],
    post_hook = "ALTER TABLE {{ this }} ADD SEARCH OPTIMIZATION ON EQUALITY(tx_hash,msg_hash,source,destination);",
    tags = ['scheduled_core']
) }}

SELECT
    TO_TIMESTAMP(tx_now) AS block_timestamp,
    tx_hash,
    msg_hash,
    body_hash,
    trace_id,
    direction,
    source,
    destination,
    _VALUE AS VALUE,
    opcode,
    created_at,
    tx_now,
    ihr_fee,
    import_fee,
    fwd_fee,
    ihr_disabled,
    bounced,
    bounce,
    COMMENT,
    tx_lt,
    created_lt,
    init_state_hash,
    init_state_boc,
    body_boc,
    messages_with_data_id AS fact_messages_id,
    SYSDATE() AS inserted_timestamp,
    SYSDATE() AS modified_timestamp
FROM
    {{ ref('silver__messages_with_data') }}

{% if is_incremental() %}
WHERE
    modified_timestamp >= (
        SELECT
            MAX(modified_timestamp)
        FROM
            {{ this }}
    )
{% endif %}
