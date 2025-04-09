{{ config(
    materialized = 'incremental',
    unique_key = ['fact_nft_metadata_id'],
    incremental_strategy = 'merge',
    merge_exclude_columns = ['inserted_timestamp'],
    cluster_by = ['update_timestamp_onchain::DATE'],
    post_hook = "ALTER TABLE {{ this }} ADD SEARCH OPTIMIZATION ON EQUALITY(address,parent_address);",
    tags = ['scheduled_core']
) }}

SELECT
    address,
    parent_address,
    TO_TIMESTAMP(update_time_onchain) AS update_timestamp_onchain,
    TYPE,
    NAME,
    description,
    metadata_status,
    attributes,
    image,
    image_data,
    tonapi_image_url,
    content_onchain,
    sources,
    update_time_onchain,
    update_time_metadata,
    adding_at,
    nft_metadata_id AS fact_nft_metadata_id,
    SYSDATE() AS inserted_timestamp,
    SYSDATE() AS modified_timestamp
FROM
    {{ ref('silver__nft_metadata') }}

{% if is_incremental() %}
WHERE
    modified_timestamp >= (
        SELECT
            MAX(modified_timestamp)
        FROM
            {{ this }}
    )
{% endif %}
