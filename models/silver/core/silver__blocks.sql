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
        version,
        created_by,
        end_lt,
        want_merge,
        gen_utime,
        tx_count,
        global_id,
        root_hash,
        key_block,
        mc_block_seqno,
        vert_seqno_incr,
        validator_list_hash_short,
        after_merge,
        want_split,
        after_split,
        master_ref_seqno,
        mc_block_workchain,
        file_hash,
        prev_key_block_seqno,
        shard,
        seqno,
        vert_seqno,
        flags,
        rand_seed,
        gen_catchain_seqno,
        min_ref_mc_seqno,
        start_lt,
        mc_block_shard,
        before_split,
        workchain,
        _inserted_timestamp
    FROM
        {{ ref('bronze__blocks') }}
        qualify ROW_NUMBER() over (
            PARTITION BY seqno,
            shard,
            workchain
            ORDER BY
                _inserted_timestamp DESC
        ) = 1
)
SELECT
    block_date,
    version,
    created_by,
    end_lt,
    want_merge,
    gen_utime,
    tx_count,
    global_id,
    root_hash,
    key_block,
    mc_block_seqno,
    vert_seqno_incr,
    validator_list_hash_short,
    after_merge,
    want_split,
    after_split,
    master_ref_seqno,
    mc_block_workchain,
    file_hash,
    prev_key_block_seqno,
    shard,
    seqno,
    vert_seqno,
    flags,
    rand_seed,
    gen_catchain_seqno,
    min_ref_mc_seqno,
    start_lt,
    mc_block_shard,
    before_split,
    workchain,
    _inserted_timestamp,
    {{ dbt_utils.generate_surrogate_key(
        ['shard','seqno','workchain']
    ) }} AS blocks_id,
    SYSDATE() AS inserted_timestamp,
    SYSDATE() AS modified_timestamp,
    '{{ invocation_id }}' AS _invocation_id
FROM
    pre_final
