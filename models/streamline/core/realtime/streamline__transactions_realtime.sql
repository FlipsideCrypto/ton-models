{{ config (
    materialized = "view",
    post_hook = fsc_utils.if_data_call_function_v2(
        func = 'streamline.udf_bulk_rest_api_v2',
        target = "{{this.schema}}.{{this.identifier}}",
        params ={ "external_table" :"transactions",
        "sql_limit" :"100000",
        "producer_batch_size" :"20000",
        "worker_batch_size" :"5000",
        "exploded_key": tojson(["result.transactions"]),
        "include_top_level_json": tojson(["result.incomplete","ok"]),
        "sql_source" :"{{this.identifier}}",
        "order_by_column": "sequence_number DESC" }
    ),
    tags = ['streamline_realtime'],
    enabled = false
) }}

WITH shards AS (

    SELECT
        sequence_number,
        shard,
        workchain
    FROM
        {{ ref("streamline__blocks") }}
    EXCEPT
    SELECT
        sequence_number,
        shard,
        workchain
    FROM
        {{ ref("streamline__transactions_complete") }}
)
SELECT
    sequence_number,
    shard,
    workchain,
    ROUND(
        sequence_number,
        -5
    ) :: INT AS partition_key,
    {{ target.database }}.live.udf_api(
        'GET',
        '{Service}/{Authentication}/getBlockTransactionsExt?workchain=' || workchain || '&shard=' || shard || '&seqno=' || sequence_number || '&count=256',
        --256 appears to be the max number of transactions per block that QN support - tbd on if there are blockc with > 256 transactions
        OBJECT_CONSTRUCT(
            'Content-Type',
            'application/json'
        ),
        OBJECT_CONSTRUCT(),
        'Vault/prod/ton/quicknode/mainnet'
    ) AS request
FROM
    shards
