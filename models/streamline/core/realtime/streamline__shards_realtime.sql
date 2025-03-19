{{ config (
    materialized = "view",
    post_hook = fsc_utils.if_data_call_function_v2(
        func = 'streamline.udf_bulk_rest_api_v2',
        target = "{{this.schema}}.{{this.identifier}}",
        params ={ "external_table" :"shards",
        "sql_limit" :"100000",
        "producer_batch_size" :"100000",
        "worker_batch_size" :"50000",
        "sql_source" :"{{this.identifier}}",
        "order_by_column": "sequence_number DESC" }
    ),
    tags = ['streamline_realtime'],
    enabled = false
) }}

WITH sequences AS (

    SELECT
        sequence_number
    FROM
        {{ ref("streamline__sequences") }}
    EXCEPT
    SELECT
        sequence_number
    FROM
        {{ ref("streamline__shards_complete") }}
)
SELECT
    sequence_number,
    ROUND(
        sequence_number,
        -5
    ) :: INT AS partition_key,
    {{ target.database }}.live.udf_api(
        'GET',
        '{Service}/{Authentication}/shards?seqno=' || sequence_number,
        OBJECT_CONSTRUCT(
            'Content-Type',
            'application/json'
        ),
        OBJECT_CONSTRUCT(),
        'Vault/prod/ton/quicknode/mainnet'
    ) AS request
FROM
    sequences
