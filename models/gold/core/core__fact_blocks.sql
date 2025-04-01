{{ config(
    materialized = 'incremental',
    unique_key = ['fact_blocks_id'],
    incremental_strategy = 'merge',
    merge_exclude_columns = ['inserted_timestamp'],
    cluster_by = ['block_timestamp::DATE','workchain'],
    tags = ['scheduled_core']
) }}

SELECT
    TO_TIMESTAMP(gen_utime) AS block_timestamp,
    gen_utime,
    workchain,
    version,
    shard,
    seqno,
    vert_seqno,
    start_lt,
    end_lt,
    mc_block_seqno,
    mc_block_shard,
    tx_count,
    global_id,
    created_by,
    want_merge,
    root_hash,
    key_block,
    vert_seqno_incr,
    validator_list_hash_short,
    after_merge,
    want_split,
    after_split,
    master_ref_seqno,
    mc_block_workchain,
    file_hash,
    prev_key_block_seqno,
    flags,
    rand_seed,
    gen_catchain_seqno,
    min_ref_mc_seqno,
    before_split,
    {{ dbt_utils.generate_surrogate_key(
        ['shard','seqno','workchain']
    ) }} AS fact_blocks_id,
    SYSDATE() AS inserted_timestamp,
    SYSDATE() AS modified_timestamp
FROM
    {{ ref('silver__blocks') }}

{% if is_incremental() %}
WHERE
    modified_timestamp >= (
        SELECT
            MAX(modified_timestamp)
        FROM
            {{ this }}
    )
{% endif %}
