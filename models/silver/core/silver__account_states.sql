{{ config(
    materialized = 'incremental',
    incremental_strategy = 'microbatch',
    event_time = 'block_date',
    begin = '2024-01-01',
    batch_size = 'day',
    cluster_by = ['block_date::DATE','modified_timestamp::DATE'],
    tags = ['scheduled_core'],
) }}

WITH pre_final AS (

    SELECT
        block_date,
        account,
        last_trans_lt,
        last_trans_hash,
        account_status,
        balance,
        data_boc,
        data_hash,
        frozen_hash,
        TIMESTAMP,
        code_hash,
        code_boc,
        HASH,
        _inserted_timestamp
    FROM
        {{ ref('bronze__account_states') }}
        {# qualify ROW_NUMBER() over (
        PARTITION BY account,
        TIMESTAMP
    ORDER BY
        _inserted_timestamp DESC
) = 1 #}
)
SELECT
    block_date,
    account,
    last_trans_lt,
    last_trans_hash,
    account_status,
    balance,
    data_boc,
    data_hash,
    frozen_hash,
    TIMESTAMP,
    code_hash,
    code_boc,
    HASH,
    _inserted_timestamp,
    {{ dbt_utils.generate_surrogate_key(
        ['account','timestamp']
    ) }} AS account_states_id,
    SYSDATE() AS inserted_timestamp,
    SYSDATE() AS modified_timestamp,
    '{{ invocation_id }}' AS _invocation_id
FROM
    pre_final
