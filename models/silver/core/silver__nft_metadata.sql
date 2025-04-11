{{ config(
    materialized = 'incremental',
    incremental_strategy = 'microbatch',
    event_time = 'adding_date',
    begin = '2024-11-14',
    batch_size = 'day',
    cluster_by = ['adding_date::DATE','modified_timestamp::DATE'],
    tags = ['scheduled_core']
) }}

WITH pre_final AS (

    SELECT
        adding_date,
        description,
        image,
        metadata_status,
        parent_address,
        update_time_metadata,
        adding_at,
        update_time_onchain,
        address,
        tonapi_image_url,
        content_onchain,
        TYPE,
        attributes,
        NAME,
        sources,
        image_data,
        _inserted_timestamp
    FROM
        {{ ref('bronze__nft_metadata') }}
        {# qualify ROW_NUMBER() over (
        PARTITION BY address,
        update_time_metadata,
        update_time_onchain
    ORDER BY
        _inserted_timestamp DESC
) = 1 #}
)
SELECT
    adding_date,
    description,
    image,
    metadata_status,
    parent_address,
    update_time_metadata,
    adding_at,
    update_time_onchain,
    address,
    tonapi_image_url,
    content_onchain,
    TYPE,
    attributes,
    NAME,
    sources,
    image_data,
    _inserted_timestamp,
    {{ dbt_utils.generate_surrogate_key(
        ['parent_address','address','update_time_metadata','update_time_onchain']
    ) }} AS nft_metadata_id,
    SYSDATE() AS inserted_timestamp,
    SYSDATE() AS modified_timestamp,
    '{{ invocation_id }}' AS _invocation_id
FROM
    pre_final
