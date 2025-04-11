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
        msg_hash,
        ihr_disabled,
        tx_now,
        opcode,
        created_lt,
        tx_hash,
        bounce,
        bounced,
        COMMENT,
        init_state_hash,
        import_fee,
        _VALUE,
        fwd_fee,
        tx_lt,
        ihr_fee,
        source,
        trace_id,
        direction,
        body_hash,
        created_at,
        destination,
        _inserted_timestamp
    FROM
        {{ ref('bronze__messages') }}
        qualify ROW_NUMBER() over (
            PARTITION BY tx_hash,
            msg_hash
            ORDER BY
                _inserted_timestamp DESC
        ) = 1
)
SELECT
    block_date,
    msg_hash,
    ihr_disabled,
    tx_now,
    opcode,
    created_lt,
    tx_hash,
    bounce,
    bounced,
    COMMENT,
    init_state_hash,
    import_fee,
    _VALUE,
    fwd_fee,
    tx_lt,
    ihr_fee,
    source,
    trace_id,
    direction,
    body_hash,
    created_at,
    destination,
    _inserted_timestamp,
    {{ dbt_utils.generate_surrogate_key(
        ['tx_hash','msg_hash']
    ) }} AS messages_id,
    SYSDATE() AS inserted_timestamp,
    SYSDATE() AS modified_timestamp,
    '{{ invocation_id }}' AS _invocation_id
FROM
    pre_final
