{{ config(
    materialized = 'incremental',
    unique_key = ['fact_transactions_id'],
    incremental_strategy = 'merge',
    merge_exclude_columns = ['inserted_timestamp'],
    cluster_by = ['block_timestamp::DATE'],
    post_hook = "ALTER TABLE {{ this }} ADD SEARCH OPTIMIZATION ON EQUALITY(tx_hash,prev_tx_hash,account);",
    tags = ['scheduled_core']
) }}

SELECT
    TO_TIMESTAMP(now) AS block_timestamp,
    HASH AS tx_hash,
    prev_trans_hash AS prev_tx_hash,
    CASE
        WHEN aborted THEN FALSE
        ELSE TRUE
    END tx_succeeded,
    aborted,
    account,
    orig_status,
    end_status,
    compute_success,
    compute_skipped,
    compute_gas_fees,
    action_result_code,
    action_success,
    action_spec_actions,
    action_result_arg,
    action_skipped_actions,
    action_valid,
    action_tot_actions,
    action_no_funds,
    action_status_change,
    compute_msg_state_used,
    descr,
    block_workchain,
    block_seqno,
    block_shard,
    mc_block_seqno,
    total_fees,
    storage_fees_collected,
    credit_due_fees_collected,
    action_total_fwd_fees,
    storage_fees_due,
    action_total_action_fees,
    account_state_balance_before,
    account_state_balance_after,
    account_state_hash_before,
    account_state_hash_after,
    account_state_code_hash_before,
    account_state_code_hash_after,
    installed,
    destroyed,
    is_tock,
    credit_first,
    compute_account_activated,
    compute_vm_steps,
    compute_exit_arg,
    compute_gas_credit,
    compute_gas_limit,
    compute_gas_used,
    compute_vm_init_state_hash,
    compute_vm_final_state_hash,
    skipped_reason,
    compute_exit_code,
    storage_status_change,
    compute_mode,
    credit,
    trace_id,
    lt,
    prev_trans_lt,
    now,
    transactions_id AS fact_transactions_id,
    SYSDATE() AS inserted_timestamp,
    SYSDATE() AS modified_timestamp
FROM
    {{ ref('silver__transactions') }}

{% if is_incremental() %}
WHERE
    modified_timestamp >= (
        SELECT
            MAX(modified_timestamp)
        FROM
            {{ this }}
    )
{% endif %}
