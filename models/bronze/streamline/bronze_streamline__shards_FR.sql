{{ config (
    materialized = 'view'
) }}
{{ streamline_external_table_FR_query_v2(
    model = 'shards',
    partition_function = "CAST(SPLIT_PART(SPLIT_PART(file_name, '/', 3), '_', 1) AS INTEGER)",
    partition_name = "partition_key",
    other_cols = "value:SEQUENCE_NUMBER::BIGINT as SEQUENCE_NUMBER",
    enabled = false
) }}
