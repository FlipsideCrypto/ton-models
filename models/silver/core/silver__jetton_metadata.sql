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
        tonapi_image_url,
        image_data,
        image,
        update_time_onchain,
        symbol,
        jetton_content_onchain,
        update_time_metadata,
        NAME,
        jetton_wallet_code_hash,
        code_hash,
        admin_address,
        adding_at,
        address,
        sources,
        mintable,
        decimals,
        metadata_status,
        description,
        _inserted_timestamp
    FROM
        {{ ref('bronze__jetton_metadata') }}
        qualify ROW_NUMBER() over (
            PARTITION BY address,
            update_time_metadata,
            update_time_onchain
            ORDER BY
                _inserted_timestamp DESC
        ) = 1
)
SELECT
    adding_date,
    tonapi_image_url,
    image_data,
    image,
    update_time_onchain,
    symbol,
    jetton_content_onchain,
    update_time_metadata,
    NAME,
    jetton_wallet_code_hash,
    code_hash,
    admin_address,
    adding_at,
    address,
    sources,
    mintable,
    decimals,
    metadata_status,
    description,
    _inserted_timestamp,
    {{ dbt_utils.generate_surrogate_key(
        ['address','update_time_metadata','update_time_onchain']
    ) }} AS jetton_metadata_id,
    SYSDATE() AS inserted_timestamp,
    SYSDATE() AS modified_timestamp,
    '{{ invocation_id }}' AS _invocation_id
FROM
    pre_final
