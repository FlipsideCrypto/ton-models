{{ config (
    materialized = "view",
    tags = ['streamline_view'],
    enabled = false
) }}

SELECT
    sequence_number AS mastechain_sequence_number,
    VALUE :seqno AS sequence_number,
    VALUE :shard :: STRING AS shard,
    VALUE :workchain AS workchain
FROM
    {{ ref('streamline__shards_complete') }},
    LATERAL FLATTEN(shards)
UNION ALL
SELECT
    sequence_number AS mastechain_sequence_number,
    sequence_number AS sequence_number,
    '8000000000000000' AS shard,
    -1 AS workchain
FROM
    {{ ref('streamline__sequences') }}
