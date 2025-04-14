{{ config(
    materialized = 'incremental',
    unique_key = ['fact_account_states_id'],
    incremental_strategy = 'merge',
    merge_exclude_columns = ['inserted_timestamp'],
    cluster_by = ['block_timestamp::DATE'],
    post_hook = "ALTER TABLE {{ this }} ADD SEARCH OPTIMIZATION ON EQUALITY(account);",
    tags = ['scheduled_core']
) }}

SELECT
    TO_TIMESTAMP(TIMESTAMP) AS block_timestamp,
    account,
    TIMESTAMP,
    last_trans_lt,
    last_trans_hash AS last_tx_hash,
    account_status,
    balance,
    frozen_hash,
    HASH AS account_state_hash,
    account_states_id AS fact_account_states_id,
    SYSDATE() AS inserted_timestamp,
    SYSDATE() AS modified_timestamp
FROM
    {{ ref('silver__account_states') }}

{% if is_incremental() %}
WHERE
    modified_timestamp >= (
        SELECT
            MAX(modified_timestamp)
        FROM
            {{ this }}
    )
{% endif %}
