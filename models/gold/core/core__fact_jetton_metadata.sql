{{ config(
    materialized = 'incremental',
    unique_key = ['fact_jetton_metadata_id'],
    incremental_strategy = 'merge',
    merge_exclude_columns = ['inserted_timestamp'],
    cluster_by = ['update_timestamp_onchain::DATE'],
    post_hook = "ALTER TABLE {{ this }} ADD SEARCH OPTIMIZATION ON EQUALITY(address,symbol);",
    tags = ['scheduled_core']
) }}

SELECT
    address,
    TO_TIMESTAMP(update_time_onchain) AS update_timestamp_onchain,
    symbol,
    decimals,
    NAME,
    description,
    tonapi_image_url,
    image_data,
    image,
    admin_address,
    mintable,
    jetton_content_onchain,
    jetton_wallet_code_hash,
    code_hash,
    adding_at,
    sources,
    metadata_status,
    update_time_onchain,
    update_time_metadata,
    jetton_metadata_id AS fact_jetton_metadata_id,
    SYSDATE() AS inserted_timestamp,
    SYSDATE() AS modified_timestamp
FROM
    {{ ref('silver__jetton_metadata') }}

{% if is_incremental() %}
WHERE
    modified_timestamp >= (
        SELECT
            MAX(modified_timestamp)
        FROM
            {{ this }}
    )
{% endif %}
