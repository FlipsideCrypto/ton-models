{{ config(
    materialized = 'incremental',
    full_refresh = false,
    tags = ['noncore']
) }}

WITH tokens_base AS (

    SELECT
        DISTINCT token_address
    FROM
        {{ ref('bronze__complete_provider_asset_metadata') }}
    UNION
    SELECT
        DISTINCT token_address
    FROM
        {{ ref('bronze__complete_token_asset_metadata') }}
),
tokens AS (
    SELECT
        token_address
    FROM
        tokens_base A

{% if is_incremental() %}
LEFT JOIN {{ this }}
b USING(token_address)
{% endif %}

{% if is_incremental() %}
WHERE
    b.token_address IS NULL
{% endif %}
LIMIT
    20
), res AS (
    SELECT
        token_address,
        {{ target.database }}.live.udf_api(
            'GET',
            '{Service}/{Authentication}/detectAddress?address=' || token_address,
            OBJECT_CONSTRUCT(
                'Content-Type',
                'application/json'
            ),
            OBJECT_CONSTRUCT(),
            'Vault/prod/ton/quicknode/mainnet'
        ) :data :result AS DATA
    FROM
        tokens
)
SELECT
    token_address,
    DATA,
    DATA :bounceable AS bounceable,
    DATA :given_type :: STRING AS given_type,
    DATA :non_bounceable AS non_bounceable,
    DATA :raw_form :: STRING AS raw_form,
    DATA :test_only AS test_only,
    SYSDATE() AS _inserted_timestamp
FROM
    res
WHERE
    raw_form IS NOT NULL
