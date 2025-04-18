{{ config(
    materialized = 'incremental',
    tags = ['scheduled_core']
) }}

WITH base AS (

    SELECT
        {{ target.database }}.live.udf_api('https://ton-blockchain-public-datalake.s3.eu-central-1.amazonaws.com/v1/ton-labels/json/assets.json') :data AS DATA
)
SELECT
    TRY_PARSE_JSON(VALUE) AS DATA,
    SYSDATE() AS _inserted_timestamp
FROM
    TABLE(
        SPLIT_TO_TABLE(
            (
                SELECT
                    DATA :: STRING
                FROM
                    base
            ),
            '\n'
        )
    )
