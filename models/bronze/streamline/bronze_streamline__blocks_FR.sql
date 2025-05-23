{{ config (
    materialized = 'view',
    enabled = false
) }}
{{ streamline_external_table_FR_query_v2(
    model = 'blocks',
    partition_function = "CAST(SPLIT_PART(SPLIT_PART(file_name, '/', 3), '_', 1) AS INTEGER)",
    partition_name = "partition_key",
    other_cols = "value:SEQUENCE_NUMBER::BIGINT as SEQUENCE_NUMBER, value:SHARD::STRING as SHARD, value:WORKCHAIN::INT as WORKCHAIN"
) }}
