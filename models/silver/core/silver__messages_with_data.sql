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
        body_boc,
        created_lt,
        init_state_hash,
        opcode,
        trace_id,
        bounced,
        body_hash,
        direction,
        tx_lt,
        tx_hash,
        ihr_fee,
        init_state_boc,
        created_at,
        source,
        msg_hash,
        ihr_disabled,
        tx_now,
        bounce,
        _VALUE,
        import_fee,
        destination,
        COMMENT,
        fwd_fee,
        _inserted_timestamp
    FROM
        {{ ref('bronze__messages_with_data') }}
        {# qualify ROW_NUMBER() over (
        PARTITION BY tx_hash,
        msg_hash
    ORDER BY
        _inserted_timestamp DESC
) = 1 #}
)
SELECT
    block_date,
    body_boc,
    created_lt,
    init_state_hash,
    opcode,
    trace_id,
    bounced,
    body_hash,
    direction,
    tx_lt,
    tx_hash,
    ihr_fee,
    init_state_boc,
    created_at,
    source,
    msg_hash,
    ihr_disabled,
    tx_now,
    bounce,
    _VALUE,
    import_fee,
    destination,
    COMMENT,
    fwd_fee,
    _inserted_timestamp,
    {{ dbt_utils.generate_surrogate_key(
        ['tx_hash','msg_hash']
    ) }} AS messages_with_data_id,
    SYSDATE() AS inserted_timestamp,
    SYSDATE() AS modified_timestamp,
    '{{ invocation_id }}' AS _invocation_id
FROM
    pre_final
