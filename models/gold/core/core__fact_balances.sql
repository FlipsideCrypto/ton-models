{{ config(
    materialized = 'incremental',
    unique_key = ['fact_balances_history_id'],
    incremental_strategy = 'merge',
    merge_exclude_columns = ['inserted_timestamp'],
    cluster_by = ['block_timestamp::DATE'],
    post_hook = "ALTER TABLE {{ this }} ADD SEARCH OPTIMIZATION ON EQUALITY(address);",
    tags = ['scheduled_core']
) }}

SELECT
    TO_TIMESTAMP(TIMESTAMP) AS block_timestamp,
    address,
    asset,
    amount,
    mintless_claimed,
    lt,
    balances_history_id AS fact_balances_history_id,
    SYSDATE() AS inserted_timestamp,
    SYSDATE() AS modified_timestamp
FROM
    {{ ref('silver__balances_history') }}

{% if is_incremental() %}
WHERE
    modified_timestamp >= (
        SELECT
            MAX(modified_timestamp)
        FROM
            {{ this }}
    )
{% endif %}
